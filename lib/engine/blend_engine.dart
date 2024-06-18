import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:trailblaze/constants/engine_constants.dart';

/*
  Uses a neural network to help user select the directness of a route.
  The model was trained on more than 200 routes (1km-40km) around Waterloo.
 */
class BlendEngine {
  OrtSession? _session;

  final Completer<void> _modelLoadCompleter = Completer<void>();

  Future<void> get modelLoaded => _modelLoadCompleter.future;

  BlendEngine() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    OrtEnv.instance.init();
    const assetFileName = 'assets/models/blend.onnx';
    final rawAssetFile = await rootBundle.load(assetFileName);
    final bytes = rawAssetFile.buffer.asUint8List();
    _session = OrtSession.fromBuffer(bytes, OrtSessionOptions());
    _modelLoadCompleter.complete();
  }

  List<List<double>> _scaleInputData(List<List<num>> inputData) {
    return inputData.map((row) {
      return [
        (row[0] - kBlendMean[0]) / kBlendScale[0],
        (row[1] - kBlendMean[1]) / kBlendScale[1],
        (row[2] - kBlendMean[2]) / kBlendScale[2],
      ];
    }).toList();
  }

  int _formatPredictedInfluences(List<double> predictions) {
    int maxIndex = 0;
    double maxValue = predictions[0];

    for (int i = 1; i < predictions.length; i++) {
      if (predictions[i] > maxValue) {
        maxValue = predictions[i];
        maxIndex = i;
      }
    }

    return kBlendInfluenceLevels[maxIndex];
  }

  Future<int> _predict(List<List<num>> inputData) async {
    final scaledInputData = _scaleInputData(inputData);
    final inputFloats = Float32List.fromList(
        scaledInputData.expand((e) => e).toList().cast<double>());
    final inputOrt =
        OrtValueTensor.createTensorWithDataList(inputFloats, [1, 3]);
    final inputs = {'input': inputOrt};
    final runOptions = OrtRunOptions();
    final outputs = await _session?.runAsync(runOptions, inputs);
    final predictedInfluences = _formatPredictedInfluences(
        (outputs?[0]?.value as List<List<double>>).first);

    // Free resources
    inputOrt.release();
    runOptions.release();
    outputs?.forEach((element) {
      element?.release();
    });

    return predictedInfluences;
  }

  Future<int> predictForData(
      num euclideanDistance, num manhattanDistance, num target) async {
    await modelLoaded;

    final inputData = [
      [
        euclideanDistance,
        manhattanDistance,
        target,
      ],
    ];
    return _predict(inputData);
  }

  void release() {
    Timer(const Duration(seconds: 1), () {
      try {
        _session?.release();
      } catch (e) {
        // Object may not have been fully initialized before being released.
        log('$e');
      }
      _session = null;
    });
  }
}
