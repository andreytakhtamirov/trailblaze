import 'package:flutter_dotenv/flutter_dotenv.dart';

const baseUrl = 'https://trailblaze.azurewebsites.net';

final String appToken = dotenv.env['TRAILBLAZE_APP_TOKEN'] ?? '';

final requestHeaderBasic = <String, String>{
  'Content-Type': 'application/json',
  'TRAILBLAZE-APP-TOKEN': appToken,
};
