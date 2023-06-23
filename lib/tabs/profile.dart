import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/auth_constants.dart';
import '../managers/credential_manager.dart';

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

  void _mutateCredentials(Credentials? credentials) {
    ref.read(credentialsNotifierProvider.notifier).setCredentials(credentials);
  }

  Future<void> _onLoginPressed() async {
    _signIn();
  }

  void _signIn() async {
    final Credentials credentials;

    try {
      credentials =
          await _auth0.webAuthentication(scheme: kAuth0Scheme).login();
    } catch (e) {
      log('Authentication error: $e');
      return;
    }

    _storeCredentials(credentials);
  }

  void _storeCredentials(Credentials? credentials) {
    if (credentials == null) {
      _mutateCredentials(null);
    } else {
      _mutateCredentials(credentials);
    }
  }

  Future<void> _onLogoutPressed() async {
    await _auth0.webAuthentication(scheme: kAuth0Scheme).logout();
    _storeCredentials(null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final credentials = ref.watch(credentialsNotifierProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Profile'),
          ),
          body: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        height: 150,
                        fit: BoxFit.scaleDown,
                        imageUrl: credentials?.user.pictureUrl.toString() ?? '',
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fadeOutDuration: const Duration(milliseconds: 0),
                        fadeInDuration: const Duration(milliseconds: 0),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            credentials?.user.name ?? '',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile elements will go here (posts, routes).
                const SizedBox(
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Text(
                    'Expires At: ${credentials?.expiresAt.toIso8601String()}',
                    style: const TextStyle(height: 0, fontSize: 20),
                  ),
                ),
                Center(
                  child: Visibility(
                    visible: credentials == null,
                    replacement: ElevatedButton(
                      onPressed: _onLogoutPressed,
                      child: const Text('Log out'),
                    ),
                    child: ElevatedButton(
                      onPressed: _onLoginPressed,
                      child: const Text('Log in'),
                    ),
                  ),
                ),
              ]),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
