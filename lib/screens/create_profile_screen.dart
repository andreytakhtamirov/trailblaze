import 'dart:async';
import 'dart:io';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trailblaze/constants/validation_constants.dart';
import 'package:trailblaze/requests/user_profile.dart';
import 'package:trailblaze/widgets/profile/username_availability_widget.dart';
import 'package:trailblaze/widgets/profile/username_validity_widget.dart';

import '../util/ui_helper.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key, required this.credentials});

  final Credentials? credentials;

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  String? _username;
  Timer? _debounceTimer;
  bool _isAvailable = false;
  Future<bool>? _isAvailableFuture;

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
    return _formValidator(_username) == null;
  }

  String? _formValidator(String? username) {
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

  }

  void _onSubmitForm() async {
    if (_formKey.currentState?.validate() == true) {
      final response = await saveProfile(
        widget.credentials?.idToken ?? '',
        _username!,
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
                          child: CachedNetworkImage(
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
                                validator: _formValidator,
                                onChanged: _onUsernameChanged,
                                controller: _usernameController,
                                autofocus: true,
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
                              errorMessage: _formValidator(_username)),
                          const SizedBox(
                            height: 24,
                          ),
                          ElevatedButton(
                            onPressed: _isAvailable &&
                                    _isAvailableFuture != null &&
                                    _isFormValid()
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
