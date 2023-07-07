import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trailblaze/constants/validation_constants.dart';
import 'package:trailblaze/requests/user_profile.dart';
import 'package:trailblaze/widgets/profile/username_availability_widget.dart';
import 'package:trailblaze/widgets/profile/username_validity_widget.dart';

import '../data/profile.dart';
import '../managers/profile_manager.dart';
import '../util/ui_helper.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key, required this.credentials});

  final Credentials? credentials;

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  String? _username;
  Timer? _debounceTimer;
  bool _isAvailable = false;
  Future<bool>? _isAvailableFuture;
  List<int>? _changedProfilePicture;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  bool _isFormValid() {
    return _usernameValidator(_username) == null;
  }

  bool _isFormEmpty() {
    return _username == null || _username!.isEmpty;
  }

  String? _usernameValidator(String? username) {
    if (username == null) {
      return '';
    }

    // Minimum and maximum length.
    if (username.length < kMinUsernameLength) {
      return "Username must be at least 4 characters";
    } else if (username.length > kMaxUsernameLength) {
      return "Username must be shorter than 20 characters";
    }

    // Allowed characters (alphanumeric and underscore).
    final validCharacters = RegExp(kUsernameRegex);
    if (!validCharacters.hasMatch(username)) {
      return "Username must contain only letters, numbers, and/or underscore";
    }

    // No spaces.
    if (username.contains(kBannedCharacters)) {
      return "Username must not contain any spaces";
    }

    return null;
  }

  String? _formValidator(String? username, Profile? profile) {
    if (profile?.username != null &&
        _isFormEmpty() &&
        _changedProfilePicture != null) {
      // User has only changed profile picture and not username.
      return null;
    } else {
      return _usernameValidator(username);
    }
  }

  Future<bool> checkAvailability(String username) async {
    final response = await checkUsernameAvailability(username);

    bool isAvailable = false;
    response.fold((error) => null, (data) => isAvailable = true);

    setState(() {
      _isAvailable = _isFormValid() && isAvailable;
    });

    return isAvailable;
  }

  void _onUsernameChanged(String value) {
    if (_debounceTimer?.isActive ?? false) {
      setState(() {
        _isAvailableFuture = null;
      });
      _debounceTimer!.cancel();
    }

    setState(() {
      _username = value;
    });

    if (!_isFormValid()) {
      // Don't send availability request if form is invalid.
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _isAvailableFuture = checkAvailability(value);
    });
  }

  void _onChangeProfilePicture() {
    _openImagePicker();
  }

  void _openImagePicker() async {
    final picker = ImagePicker();
    final XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(
        requestFullMetadata: false,
        source: ImageSource.gallery,
      );
    } on PlatformException {
      UiHelper.showSnackBar(context, "There was a problem getting your image.");
      return;
    }

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await _cropImage(imageFile);
    }
  }

  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
      uiSettings: <PlatformUiSettings>[
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioLockEnabled: true,
          resetButtonHidden: true,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      List<int>? imageBytes = await croppedFile.readAsBytes();
      setState(() {
        _changedProfilePicture = imageBytes;
      });
    }
  }

  void _onSubmitForm() async {
    if (_formKey.currentState?.validate() == true) {
      String? base64Image;

      if (_changedProfilePicture != null) {
        base64Image = base64Encode(_changedProfilePicture!);
      }

      final response = await saveProfile(
        widget.credentials?.idToken ?? '',
        _username,
        base64Image,
      );

      response.fold(
        (error) => {
          if (error == 409)
            {
              UiHelper.showSnackBar(context, "That username is already taken"),
            }
          else if (error == 400)
            {
              UiHelper.showSnackBar(context, "Invalid username"),
            }
          else
            {
              UiHelper.showSnackBar(context, "An unknown error occurred"),
            }
        },
        (userProfile) => {
          UiHelper.showSnackBar(context, "Profile updated"),
          Navigator.pop(context, userProfile)
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    ImageProvider? userPicture;

    if (_changedProfilePicture != null) {
      userPicture = MemoryImage(Uint8List.fromList(_changedProfilePicture!));
    } else {
      userPicture = profile?.profilePicture;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Complete Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: userPicture != null
                              ? Image(
                                  image: userPicture,
                                  width: 200,
                                  fit: BoxFit.fitWidth,
                                )
                              : CachedNetworkImage(
                                  fit: BoxFit.fitWidth,
                                  width: 200,
                                  maxWidthDiskCache: 200,
                                  imageUrl: widget.credentials?.user.pictureUrl
                                          .toString() ??
                                      '',
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: _onChangeProfilePicture,
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 48),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: profile != null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  const Text(
                                    "Current username:",
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    profile?.username ?? '',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  errorStyle: TextStyle(
                                    // Don't show error message in form.
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                ),
                                validator: (value) =>
                                    _formValidator(value, profile),
                                onChanged: _onUsernameChanged,
                                controller: _usernameController,
                                // Focus by default if username on server is null.
                                autofocus: profile == null,
                                maxLength: kMaxUsernameLength,
                                scrollPadding:
                                    const EdgeInsets.only(bottom: 150),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 36,
                                child: UsernameAvailability(
                                  futureAvailability: _isAvailableFuture,
                                  bypassVerification: !_isFormValid(),
                                ),
                              ),
                            ],
                          ),
                          UsernameValidity(
                              errorMessage: _formValidator(_username, profile)),
                          const SizedBox(
                            height: 24,
                          ),
                          ElevatedButton(
                            onPressed: (_isAvailable &&
                                        _isAvailableFuture != null &&
                                        _isFormValid()) ||
                                    (profile?.username != null &&
                                        _isFormEmpty() &&
                                        _changedProfilePicture != null)
                                ? _onSubmitForm
                                : null,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
