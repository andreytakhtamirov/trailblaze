import 'package:trailblaze/secrets/env_tokens.dart';
import 'package:trailblaze/secrets/secrets.dart';

final String kAuth0Scheme = const Env(kEncryptionKey, kInitializationVector).auth0Scheme;
final String kAuth0Domain = const Env(kEncryptionKey, kInitializationVector).auth0Domain;
final String kAuth0ClientId = const Env(kEncryptionKey, kInitializationVector).auth0ClientId;

const kFlagProfileDeleted = "PROFILE_DELETED";
