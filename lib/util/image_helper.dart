import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trailblaze/util/ui_helper.dart';

class ImageHelper {

  Future<File?> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(
        requestFullMetadata: false,
        source: ImageSource.gallery,
      );
    } on PlatformException {
      UiHelper.showSnackBar(context, "There was a problem getting your image.");
      return null;
    }

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      return imageFile;
    }

    return null;
  }

  Future<CroppedFile?> cropImage(Color toolbarColor, File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: toolbarColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioLockEnabled: true,
          resetButtonHidden: true,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    return croppedFile;
  }
}
