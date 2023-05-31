import 'package:flutter_dotenv/flutter_dotenv.dart';

final String kAuth0Scheme = dotenv.env['AUTH0_SCHEME'] ?? '';
final String kAuth0Domain = dotenv.env['AUTH0_DOMAIN'] ?? '';
final String kAuth0ClientId = dotenv.env['AUTH0_CLIENT_ID'] ?? '';
