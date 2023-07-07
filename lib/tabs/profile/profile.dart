import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/constants/auth_constants.dart';
import 'package:trailblaze/data/profile.dart';
import 'package:trailblaze/managers/credential_manager.dart';
import 'package:trailblaze/managers/profile_manager.dart';
import 'package:trailblaze/requests/user_profile.dart';
import 'package:trailblaze/screens/create_profile_screen.dart';
import 'package:trailblaze/tabs/profile/widgets/login_widget.dart';
import 'package:trailblaze/tabs/profile/widgets/profile_header_widget.dart';
import 'package:trailblaze/tabs/profile/widgets/profile_menu_widget.dart';
import 'package:trailblaze/tabs/profile/widgets/profile_tabs_widget.dart';
import 'package:trailblaze/util/ui_helper.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  late Auth0 _auth0;

  @override
  void initState() {
    super.initState();
    _auth0 = Auth0(kAuth0Domain, kAuth0ClientId);
  }

  Future<void> refreshProfile(Credentials? credentials) async {
    final response = await getProfile(credentials?.idToken ?? '');
    response.fold(
      (error) => {
        if (error == 204)
          {
            _mutateProfile(Profile(null)),
          }
        else
          {
            UiHelper.showSnackBar(context, "An unknown error occurred."),
          }
      },
      (data) => {
        _mutateProfile(Profile(data)),
      },
    );
  }

  void _mutateCredentials(Credentials? credentials) {
    ref.read(credentialsProvider.notifier).setCredentials(credentials);
  }

  void _mutateProfile(Profile? profile) {
    ref.read(profileProvider.notifier).setProfile(profile);
  }

  void _onLoginPressed() async {
    final Credentials credentials;

    try {
      credentials =
          await _auth0.webAuthentication(scheme: kAuth0Scheme).login();
    } catch (e) {
      log('Authentication error: $e');
      return;
    }

    _storeCredentials(credentials);
    refreshProfile(credentials);
  }

  void _storeCredentials(Credentials? credentials) {
    if (credentials == null) {
      _mutateCredentials(null);
    } else {
      _mutateCredentials(credentials);
    }
  }

  Future<void> _onLogoutPressed() async {
    try {
      await _auth0.webAuthentication(scheme: kAuth0Scheme).logout();
    } on WebAuthenticationException {
      // This exception occurs if user cancels the browser prompt to log out.
      // Let's assume that this means they don't want to log out.
      return;
    } catch (e) {
      log('Log out error: $e');
    }

    _storeCredentials(null);
    _mutateProfile(null);
  }

  void _onEditProfilePressed(Credentials? credentials) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProfileScreen(
          credentials: credentials,
        ),
      ),
    );

    if (data == null) {
      return;
    }

    _mutateProfile(Profile(data));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final credentials = ref.watch(credentialsProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          ProfileMenuWidget(
            credentials: credentials,
            onLogoutPressed: _onLogoutPressed,
            onEditProfilePressed: _onEditProfilePressed,
          )
        ],
      ),
      body: Center(
        child: Visibility(
          visible: credentials != null,
          replacement: LoginView(
            onLoginPressed: _onLoginPressed,
          ),
          child: Column(
            children: [
              ProfileHeader(
                credentials: credentials,
                profile: profile,
                refreshProfile: refreshProfile,
                onEditProfilePressed: _onEditProfilePressed,
              ),
              Expanded(
                child: ProfileTabsWidget(
                  credentials: credentials,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
