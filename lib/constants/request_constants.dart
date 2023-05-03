import 'package:flutter_dotenv/flutter_dotenv.dart';

const baseUrl = 'https://6135-72-53-232-110.ngrok-free.app';

final String appToken = dotenv.env['TRAILBLAZE_APP_TOKEN'] ?? '';

final requestHeaderBasic = <String, String>{
  'Content-Type': 'application/json',
  'TRAILBLAZE-APP-TOKEN': appToken,
};
