import 'package:google_maps_flutter/google_maps_flutter.dart';

// Define UserType as an enum
enum UserType { commuter, driver, admin }

class User {
  // MODIFIED: Made fields non-final to allow editing on the profile page
  String email;
  String password;
  String firstName;
  String lastName;
  
  // MODIFIED: Added these two optional fields
  String? middleName;
  String? profileImageUrl;

  final UserType type;
  LatLng? currentLocation;

  User({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.middleName, // Added to constructor
    this.profileImageUrl, // Added to constructor
    required this.type,
    this.currentLocation,
  });

  // MODIFIED: Updated getter to handle an optional middle name gracefully
  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }
}