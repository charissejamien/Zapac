import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'User.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  User? _currentUser;
  User? _otherUser;
  Timer? _locationSimulationTimer;
  int _simulationStep = 0;
  StreamSubscription? _otherUserLocationFirestoreSubscription;

  // MODIFIED: Updated the user list to include all roles and fields.
  final List<User> _hardcodedUsers = [
    User(
      email: 'princess@gmail.com',
      password: 'superman',
      firstName: 'Princess Mikaela',
      lastName: 'Borbajo',
      middleName: 'E',
      profileImageUrl: 'https://i.pinimg.com/736x/a7/95/9b/a7959b661c47209214716938a11e8eda.jpg',
      type: UserType.commuter,
      currentLocation: const LatLng(10.314481680817886, 123.88813209917954),
    ),
    User(
      email: 'zoie@gmail.com',
      password: 'batman',
      firstName: 'Zoie Christle',
      lastName: 'Estorba',
      middleName: 'L',
      profileImageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&h=500&fit=crop',
      type: UserType.driver,
      currentLocation: const LatLng(10.314481680817886, 123.88813209917954),
    ),
    User(
      email: 'charisjmn@gmail.com',
      password: 'vanilla08',
      firstName: 'Charisse',
      lastName: 'T',
      middleName: 'Jamien',
      profileImageUrl: 'https://plus.unsplash.com/premium_vector-1744196876628-cdd656d88ed3?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=500&h=500&fit=crop',
      type: UserType.admin,
      currentLocation: const LatLng(10.314481680817886, 123.88813209917954),
    ),
  ];

  User? get currentUser => _currentUser;
  User? get otherUser => _otherUser;

  final StreamController<LatLng> _otherUserLocationController = StreamController<LatLng>.broadcast();
  Stream<LatLng> get otherUserLocationStream => _otherUserLocationController.stream;

  Future<bool> login(String email, String password) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    for (User user in _hardcodedUsers) {
      if (user.email == email && user.password == password) {
        _currentUser = user;

      print('[AuthManager] LOGIN SUCCESSFUL. Current user is now: ${_currentUser?.email}');

        _otherUser = _hardcodedUsers.firstWhere((u) => u.email != email, orElse: () => _hardcodedUsers.first);
        listenToOtherUserLocation();
        _startCurrentUserLocationSender();
        return true;
      }
    }
    _currentUser = null;
    _otherUser = null;
    return false;
  }

  Future<void> updateUser(User updatedUser) async {
    if (_currentUser == null) return;
    _currentUser = updatedUser;
    int userIndex = _hardcodedUsers.indexWhere((user) => user.email == updatedUser.email);
    if (userIndex != -1) {
      _hardcodedUsers[userIndex] = updatedUser;
    }
  }

  void logout() {
    _currentUser = null;
    _otherUser = null;
    _locationSimulationTimer?.cancel();
    _otherUserLocationFirestoreSubscription?.cancel();
  }

  Future<void> sendLocation(LatLng location) async {
    if (_currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('drivers_locations')
            .doc(_currentUser!.email.replaceAll('.', '_'))
            .set({
              'email': _currentUser!.email,
              'latitude': location.latitude,
              'longitude': location.longitude,
              'timestamp': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } catch (e) {
        print('Error sending location to Firestore: $e');
      }
    }
  }

  void listenToOtherUserLocation() {
    if (_otherUser != null) {
      _otherUserLocationFirestoreSubscription?.cancel();
      _otherUserLocationFirestoreSubscription = FirebaseFirestore.instance
          .collection('drivers_locations')
          .doc(_otherUser!.email.replaceAll('.', '_'))
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              final data = snapshot.data()!;
              final lat = data['latitude'];
              final lng = data['longitude'];
              if (lat != null && lng != null) {
                final newLocation = LatLng(lat, lng);
                _otherUser!.currentLocation = newLocation;
                if (!_otherUserLocationController.isClosed) {
                  _otherUserLocationController.add(newLocation);
                }
              }
            }
          });
    }
  }

  final List<LatLng> _driverPath = [
    const LatLng(10.3155, 123.8890),
    const LatLng(10.3160, 123.8905),
    const LatLng(10.3165, 123.8920),
  ];

  void _startCurrentUserLocationSender() {
    _locationSimulationTimer?.cancel();
    _simulationStep = 0;
    _locationSimulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentUser == null) {
        timer.cancel();
        return;
      }
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await sendLocation(LatLng(position.latitude, position.longitude));
      } catch (e) {
        if (_currentUser!.type == UserType.driver) {
          await sendLocation(_driverPath[_simulationStep % _driverPath.length]);
          _simulationStep++;
        }
      }
    });
  }
}