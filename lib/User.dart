import 'package:google_maps_flutter/google_maps_flutter.dart';

enum UserType { commuter, driver }

class User {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final UserType type;
  LatLng? currentLocation;

  User({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.type,
    this.currentLocation,
  });

  String get fullName => '$firstName $lastName';
}
