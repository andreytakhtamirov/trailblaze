import 'package:trailblaze/data/transportation_mode.dart';

class Post {
  final String title;
  final String description;
  final int likes;
  final double distance;
  final TransportationMode transportationMode;
  final String imageUrl;

  Post(
      {required this.title,
        required this.description,
        required this.likes,
        required this.distance,
        required this.transportationMode,
        required this.imageUrl});
}