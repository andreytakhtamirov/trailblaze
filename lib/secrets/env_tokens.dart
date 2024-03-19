import 'package:secure_dotenv/secure_dotenv.dart';
part 'env_tokens.g.dart';

@DotEnvGen(
  filename: '.env',
  fieldRename: FieldRename.screamingSnake,
)
abstract class Env {
  const factory Env(String encryptionKey, String initializationVector) = _$Env;

  const Env._();

  @FieldKey()
  String get mapboxAccessToken;

  @FieldKey()
  String get trailblazeAppToken;

  @FieldKey()
  String get auth0Scheme;

  @FieldKey()
  String get auth0Domain;

  @FieldKey()
  String get auth0ClientId;
}
