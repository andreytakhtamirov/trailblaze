import 'dart:convert';
import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trailblaze/constants/storage_token_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trailblaze/extensions/auth0_credentials_extension.dart';

import '../constants/auth_constants.dart';

final credentialsProvider =
    StateNotifierProvider<CredentialsNotifier, Credentials?>((ref) {
  return CredentialsNotifier();
});

class CredentialsNotifier extends StateNotifier<Credentials?> {
  final CredentialManager _credentialManager = CredentialManager();

  CredentialsNotifier() : super(null);

  Future<Credentials?> renewUserToken() async {
    state = await _credentialManager.renewUserToken();
    return state;
  }

  void setCredentials(Credentials? state) {
    if (state == null) {
      _credentialManager.clearSession();
    } else if (state.expiresAt.isBefore(DateTime.now())) {
      log('Session expired at: ${state.expiresAt.toIso8601String()}.'
          ' Current: ${DateTime.now().toIso8601String()}');

      state = null;
      _credentialManager.clearSession();
    } else {
      _credentialManager.updateSession(state);
    }

    this.state = state;
  }
}

class CredentialManager {
  late final Auth0 _auth0;
  late final FlutterSecureStorage _storage;

  CredentialManager() {
    _auth0 = Auth0(kAuth0Domain, kAuth0ClientId);
    _storage = const FlutterSecureStorage(); // TODO store keys securely
  }

  Future<Credentials?> renewUserToken() async {
    String? refreshToken = await _storage.read(key: kRefreshTokenKey);
    if (refreshToken == null) {
      return null;
    }

    return await _renewSession(refreshToken);
  }

  Future<Credentials?> _renewSession(String refreshToken) async {
    Credentials? credentials;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Fall back to stored credentials.
        credentials = await _loadCredentialsFromStorage();
        log('Falling back on credentials in storage. '
            'Expiry: ${credentials?.expiresAt.toIso8601String()}');
      } else {
        credentials =
            await _auth0.api.renewCredentials(refreshToken: refreshToken);
      }
    } catch (e) {
      log('Authentication error: $e');
    }

    return credentials;
  }

  void updateSession(Credentials credentials) {
    _storeCredentialsInStorage(credentials);
  }

  void clearSession() {
    _storage.delete(key: kRefreshTokenKey);
    log('Cleared JWT from storage');
  }

  Future<Credentials?> _loadCredentialsFromStorage() async {
    final credentialsJson = await _storage.read(key: kCredentialsKey);
    if (credentialsJson != null) {
      final credentialsMap =
          jsonDecode(credentialsJson) as Map<String, dynamic>;
      return Credentials.fromMap(credentialsMap);
    }

    return null;
  }

  void _storeCredentialsInStorage(Credentials? credentials) async {
    if (credentials == null) {
      return;
    }

    _storage.write(
        key: kCredentialsKey,
        value: jsonEncode(credentials.toMapWithUserProfile()));
    _storage.write(key: kRefreshTokenKey, value: credentials.refreshToken);
    log('Updated JWT in storage. New expiry: ${credentials.expiresAt.toIso8601String()}');
  }
}
