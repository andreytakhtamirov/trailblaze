import 'package:trailblaze/secrets/env_tokens.dart';
import 'package:trailblaze/secrets/secrets.dart';

const kBaseUrl = 'https://api.trailblaze.cc';

final String kAppToken =
    const Env(kEncryptionKey, kInitializationVector).trailblazeAppToken;

final kRequestHeaderBasic = <String, String>{
  'Content-Type': 'application/json',
  'TRAILBLAZE-APP-TOKEN': kAppToken,
};
