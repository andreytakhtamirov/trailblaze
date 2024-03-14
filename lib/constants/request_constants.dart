import 'package:flutter_dotenv/flutter_dotenv.dart';

const kBaseUrl =
    'https://90a4-131-104-23-143.ngrok-free.app'; //'https://trailblaze.azurewebsites.net'; // TODO CHANGE BACK

final String kAppToken = dotenv.env['TRAILBLAZE_APP_TOKEN'] ?? '';

final kRequestHeaderBasic = <String, String>{
  'Content-Type': 'application/json',
  'TRAILBLAZE-APP-TOKEN': kAppToken,
};
