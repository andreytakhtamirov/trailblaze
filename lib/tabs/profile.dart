import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/auth_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin<ProfilePage> {
  Credentials? _credentials;
  bool _isLoggedIn = false;
  late Auth0 _auth0;

  @override
  void initState() {
    super.initState();
    _auth0 = Auth0(
        auth0Domain, auth0ClientId);
  }

  Future<void> _onLoginPressed() async {
    final credentials = await _auth0.webAuthentication(scheme: auth0Scheme).login();

    if (!credentials.expiresAt.isBefore(DateTime.now())) {
      setState(() {
        _credentials = credentials;
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _onLogoutPressed() async {
    await _auth0.webAuthentication(scheme: auth0Scheme).logout();

    setState(() {
      _credentials = null;
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text(
            "Your profile: ${_credentials?.accessToken}",
            style: const TextStyle(height: 0, fontSize: 20),
          ),
        ),
        Center(
          child: Visibility(
            visible: !_isLoggedIn,
            replacement: ElevatedButton(
              onPressed: _onLogoutPressed,
              child: const Text("Log out"),
            ),
            child: ElevatedButton(
              onPressed: _onLoginPressed,
              child: const Text("Log in"),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
