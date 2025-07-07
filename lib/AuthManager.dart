// lib/auth_manager.dart
import 'user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async'; // For Timer

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  User? _currentUser;
  User? _otherUser; // To hold the other hardcoded user for tracking
  Timer? _locationSimulationTimer;
  int _simulationStep = 0;

  // Hardcoded users
  final List<User> _hardcodedUsers = [
    User(
      email: 'princess@gmail.com',
      password: 'superman',
      firstName: 'Princess Mikaela',
      lastName: 'Borbajo',
      type: UserType.commuter,
      currentLocation: const LatLng(
        10.314481680817886,
        123.88813209917954,
      ), // Initial location
    ),
    User(
      email: 'zoie@gmail.com',
      password: 'ironman',
      firstName: 'Zoie Christle',
      lastName: 'Estorba',
      type: UserType.driver,
      currentLocation: const LatLng(
        10.314481680817886,
        123.88813209917954,
      ), // Initial location
    ),
  ];

  User? get currentUser => _currentUser;
  User? get otherUser => _otherUser;

  Future<bool> login(String email, String password) async {
    for (User user in _hardcodedUsers) {
      if (user.email == email && user.password == password) {
        _currentUser = user;
        // Determine the other user for location tracking
        _otherUser = _hardcodedUsers.firstWhere((u) => u.email != email);
        startOtherUserLocationSimulation(); // Start simulating movement for the other user
        return true;
      }
    }
    _currentUser = null;
    _otherUser = null;
    return false;
  }

  void logout() {
    _currentUser = null;
    _otherUser = null;
    _locationSimulationTimer?.cancel(); // Stop simulation on logout
    _simulationStep = 0; // Reset simulation
  }

  // Define a simple path for the driver to follow
  final List<LatLng> _driverPath = [
    const LatLng(
      10.314481680817886,
      123.88813209917954,
    ), // Start (same as initial)
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

  // Callback to notify listeners (e.g., Dashboard) about location changes
  final List<Function()> _locationChangeListeners = [];

  void addLocationChangeListener(Function() listener) {
    _locationChangeListeners.add(listener);
  }

  void removeLocationChangeListener(Function() listener) {
    _locationChangeListeners.remove(listener);
  }

  void _notifyLocationListeners() {
    for (var listener in _locationChangeListeners) {
      listener();
    }
  }

  // Simulates the other user's location changing
  void startOtherUserLocationSimulation() {
    _locationSimulationTimer?.cancel(); // Cancel any existing timer
    _simulationStep = 0; // Reset the step for a new simulation

    _locationSimulationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      if (_otherUser != null && _otherUser!.type == UserType.driver) {
        if (_simulationStep < _driverPath.length) {
          _otherUser!.currentLocation = _driverPath[_simulationStep];
          _simulationStep++;
          _notifyLocationListeners(); // Notify listeners
        } else {
          // Reset simulation or stop if path is finished
          _simulationStep = 0; // Loop the path
          _otherUser!.currentLocation =
              _driverPath[_simulationStep]; // Reset to start of path
          _notifyLocationListeners();
          // timer.cancel(); // Uncomment to stop after one loop
        }
      } else {
        timer.cancel(); // Stop if other user is not a driver or not set
      }
    });
  }
}
