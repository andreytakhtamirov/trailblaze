import 'package:flutter_dotenv/flutter_dotenv.dart';

const kBaseUrl = 'https://46bc-72-53-232-110.ngrok-free.app';

final String kAppToken = dotenv.env['TRAILBLAZE_APP_TOKEN'] ?? '';

final kRequestHeaderBasic = <String, String>{
  'Content-Type': 'application/json',
  'TRAILBLAZE-APP-TOKEN': kAppToken,
};
