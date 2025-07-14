import 'user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  User? _currentUser;
  User? _otherUser;
  Timer? _locationSimulationTimer; // UNCOMMENT THIS
  int _simulationStep = 0; // UNCOMMENT THIS

  StreamSubscription?
  _otherUserLocationFirestoreSubscription; // New subscription for Firestore

  final List<User> _hardcodedUsers = [
    User(
      email: 'princess@gmail.com',
      password: 'superman',
      firstName: 'Princess Mikaela',
      lastName: 'Borbajo',
      type: UserType.commuter,
      currentLocation: const LatLng(10.314481680817886, 123.88813209917954),
    ),
    User(
      email: 'zoie@gmail.com',
      password: 'batman', // Corrected password for zoie
      firstName: 'Zoie Christle',
      lastName: 'Estorba',
      type: UserType.driver,
      currentLocation: const LatLng(10.314481680817886, 123.88813209917954),
    ),
  ];

  User? get currentUser => _currentUser;
  User? get otherUser => _otherUser;

  final StreamController<LatLng> _otherUserLocationController =
      StreamController<LatLng>.broadcast();
  Stream<LatLng> get otherUserLocationStream =>
      _otherUserLocationController.stream;

  // Method to send current user's location to Firestore
  Future<void> sendLocation(LatLng location) async {
    if (_currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('drivers_locations') // Example collection name
            .doc(
              _currentUser!.email.replaceAll('.', '_'),
            ) // Use email as doc ID (or UID)
            .set(
              {
                'email': _currentUser!.email,
                'latitude': location.latitude,
                'longitude': location.longitude,
                'timestamp':
                    FieldValue.serverTimestamp(), // Firestore server timestamp
              },
              SetOptions(merge: true),
            ); // Use merge: true to only update specified fields
        print(
          'Location sent to Firestore: ${location.latitude}, ${location.longitude}',
        );
      } catch (e) {
        print('Error sending location to Firestore: $e');
      }
    }
  }

  // Method to listen to other user's location from Firestore
  void listenToOtherUserLocation() {
    if (_otherUser != null) {
      _otherUserLocationFirestoreSubscription
          ?.cancel(); // Cancel any existing listener

      _otherUserLocationFirestoreSubscription = FirebaseFirestore.instance
          .collection('drivers_locations')
          .doc(_otherUser!.email.replaceAll('.', '_')) // Use email as doc ID
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.exists && snapshot.data() != null) {
                final data = snapshot.data();
                final lat = data!['latitude'];
                final lng = data['longitude'];
                final newLocation = LatLng(lat, lng);

                _otherUser!.currentLocation = newLocation;
                _otherUserLocationController.add(
                  newLocation,
                ); // Emit to stream for Dashboard
                // _notifyLocationListeners(); // Keep this if Dashboard still relies on it, but stream is better
                print(
                  'Received other user location from Firestore: $newLocation',
                );
              } else {
                print('Other user location document does not exist.');
              }
            },
            onError: (error) {
              print('Error listening to other user location: $error');
            },
          );
    }
  }

  @override
  Future<bool> login(String email, String password) async {
    // Ensure Firebase is initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    for (User user in _hardcodedUsers) {
      if (user.email == email && user.password == password) {
        _currentUser = user;
        _otherUser = _hardcodedUsers.firstWhere((u) => u.email != email);

        // Start listening to the other user's location from Firestore
        listenToOtherUserLocation();

        // Start sending current user's location periodically
        _startCurrentUserLocationSender(); // This method now calls sendLocation(LatLng)

        return true;
      }
    }
    _currentUser = null;
    _otherUser = null;
    return false;
  }

  @override
  void logout() {
    _currentUser = null;
    _otherUser = null;
    _locationSimulationTimer?.cancel();
    // _simulationStep = 0; // Might not need to reset this as much
    _otherUserLocationFirestoreSubscription
        ?.cancel(); // Cancel Firestore listener
    _otherUserLocationController.close(); // Close the stream controller
  }

  // ... (rest of the AuthManager, keep _driverPath and _startCurrentUserLocationSender
  //       but ensure _startCurrentUserLocationSender calls the new sendLocation method)
  //       You might need to adjust _startCurrentUserLocationSender to directly call sendLocation(LatLng)
  //       instead of interacting with a WebSocket sink.
  final List<LatLng> _driverPath = [
    const LatLng(10.314481680817886, 123.88813209917954),
    const LatLng(10.3155, 123.8890),
    const LatLng(10.3160, 123.8905),
    const LatLng(10.3165, 123.8920),
    const LatLng(10.3170, 123.8935),
    const LatLng(10.3175, 123.8950),
    const LatLng(10.3180, 123.8965),
    const LatLng(10.3185, 123.8980),
    const LatLng(10.3190, 123.8995),
    const LatLng(10.3195, 123.9010),
    const LatLng(10.3200, 123.9025),
  ];
  void _startCurrentUserLocationSender() {
    _locationSimulationTimer?.cancel(); // Cancel any existing timer
    // _simulationStep = 0; // Reset step if you're using the simulated path

    _locationSimulationTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      if (_currentUser != null) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          LatLng currentLocation = LatLng(
            position.latitude,
            position.longitude,
          );
          await sendLocation(
            currentLocation,
          ); // Calls the Firebase version of sendLocation
        } catch (e) {
          print('Error getting current user location for sending: $e');
          // Fallback to simulated path if GPS fails or for driver simulation
          if (_currentUser!.type == UserType.driver) {
            if (_simulationStep < _driverPath.length) {
              await sendLocation(_driverPath[_simulationStep]);
              _simulationStep++;
            } else {
              _simulationStep = 0; // Loop
              await sendLocation(_driverPath[_simulationStep]);
            }
          }
        }
      } else {
        timer.cancel();
      }
    });
  }
}
