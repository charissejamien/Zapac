import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavoriteRoute {
  final String routeName;
  final String startAddress;
  final String endAddress;
  final LatLngBounds bounds;
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;

  FavoriteRoute({
    required this.routeName,
    required this.startAddress,
    required this.endAddress,
    required this.bounds,
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });
}