import 'package:flutter_dotenv/flutter_dotenv.dart';

final String auth0Scheme = dotenv.env['AUTH0_SCHEME'] ?? '';
final String auth0Domain = dotenv.env['AUTH0_DOMAIN'] ?? '';
final String auth0ClientId = dotenv.env['AUTH0_CLIENT_ID'] ?? '';
