import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trailblaze/constants/jwt_constants.dart';

import '../constants/auth_constants.dart';

final credentialsFutureProvider = FutureProvider<Credentials?>((ref) async {
  final credentialManager = ref.watch(credentialManagerProvider);
  return credentialManager.renewUserToken();
});

final credentialsNotifierProvider =
    StateNotifierProvider<CredentialsNotifier, Credentials?>((ref) {
  final credentialManager = ref.watch(credentialManagerProvider);
  return CredentialsNotifier(credentialManager);
});

class CredentialsNotifier extends StateNotifier<Credentials?> {
  final CredentialManager _credentialManager;

  CredentialsNotifier(this._credentialManager) : super(null);

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

      this.state = null;
      _credentialManager.clearSession();
    } else {
      _credentialManager.updateSession(state);
    }

    this.state = state;
  }
}

final credentialManagerProvider = Provider<CredentialManager>((ref) {
  return CredentialManager();
});

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
    Credentials credentials;

    try {
      credentials =
          await _auth0.api.renewCredentials(refreshToken: refreshToken);
    } catch (e) {
      log('Authentication error: $e');
      return null;
    }

    _storage.write(key: kJwtTokenKey, value: credentials.accessToken);
    _storage.write(key: kRefreshTokenKey, value: credentials.refreshToken);

    return credentials;
  }

  void updateSession(Credentials credentials) {
    _storage.write(key: kJwtTokenKey, value: credentials.accessToken);
    _storage.write(key: kRefreshTokenKey, value: credentials.refreshToken);
    log('Updated JWT in storage. New expiry: ${credentials.expiresAt.toIso8601String()}');
  }

  void clearSession() {
    _storage.delete(key: kJwtTokenKey);
    _storage.delete(key: kRefreshTokenKey);
    log('Cleared JWT from storage');
  }
}
