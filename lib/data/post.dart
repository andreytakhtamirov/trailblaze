import 'package:trailblaze/data/transportation_mode.dart';

class Post {
  final String title;
  final String description;
  final int likes;
  final num distance;
  final TransportationMode transportationMode;
  final String imageUrl;
  final dynamic route;

  Post(
      {required this.title,
      required this.description,
      required this.likes,
      required this.distance,
      required this.transportationMode,
      required this.imageUrl,
      required this.route});
}
