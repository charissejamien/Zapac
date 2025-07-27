import 'package:google_maps_flutter/google_maps_flutter.dart';

enum UserType { commuter, driver, admin }

class User {
  final String email;
  final String password;
  String firstName;
  String? middleName;
  String lastName;
  String? profileImageUrl;
  UserType type;
  LatLng currentLocation;

  // NEW FIELDS
  String? gender;
  String? dateOfBirth; // you could also use a DateTime, up to you

  User({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.profileImageUrl,
    required this.type,
    required this.currentLocation,
    this.gender,
    this.dateOfBirth,
  });

  String get fullName {
    final m = (middleName?.isNotEmpty ?? false) ? ' $middleName' : '';
    return '$firstName$m $lastName';
  }

  // If you later want Firestore serialization:
  Map<String, dynamic> toMap() => {
        'email': email,
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'profileImageUrl': profileImageUrl,
        'type': type.toString(),
        'currentLocation': {
          'lat': currentLocation.latitude,
          'lng': currentLocation.longitude,
        },
        'gender': gender,
        'dateOfBirth': dateOfBirth,
      };

  static User fromMap(Map<String, dynamic> m) => User(
        email: m['email'],
        password: '', // never store raw pw in Firestore
        firstName: m['firstName'],
        middleName: m['middleName'],
        lastName: m['lastName'],
        profileImageUrl: m['profileImageUrl'],
        type: UserType.values.firstWhere((e) => e.toString() == m['type']),
        currentLocation: LatLng(
          m['currentLocation']['lat'],
          m['currentLocation']['lng'],
        ),
        gender: m['gender'],
        dateOfBirth: m['dateOfBirth'],
      );
}