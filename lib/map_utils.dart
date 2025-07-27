// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:zapac/models/favorite_route.dart';

// Add a marker to the map
void addMarker(Set<Marker> markers, LatLng position, String markerId, String title, {BitmapDescriptor? icon}) {
  markers.add(
    Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: icon ?? BitmapDescriptor.defaultMarker,
    ),
  );
}

// Get current location and add marker
Future<void> getCurrentLocationAndMarker(Set<Marker> markers, GoogleMapController mapController, BuildContext context) async {
  // First, check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, don't continue
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location services are disabled. Please enable them.'),
        action: SnackBarAction(
          label: 'Open Settings',
          onPressed: () async {
            await Geolocator.openLocationSettings();
          },
        ),
      ),
    );
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied. Please enable location permissions in settings.')),
      );
      return;
    }
  }
  try {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    markers.removeWhere((marker) => marker.markerId.value == 'current_location');
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: currentLatLng,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    mapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
  } catch (e) {
    print('Error getting location: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not get current location.')),
    );
  }
}

// Update other user's marker
void updateOtherUserMarker(Set<Marker> markers, LatLng newLocation, String? fullName) {
  markers.removeWhere((marker) => marker.markerId.value == 'other_user_location');
  markers.add(
    Marker(
      markerId: const MarkerId('other_user_location'),
      position: newLocation,
      infoWindow: InfoWindow(title: fullName ?? 'Other User'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
  );
}

// Get predictions from Google Places Autocomplete
Future<List<dynamic>> getPredictions(String input, String apiKey) async {
  if (input.isEmpty) return [];
  final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:ph';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['predictions'];
  } else {
    print('Failed to load predictions: ${response.statusCode}');
    return [];
  }
}

// Show route on the map
Future<Map<String, dynamic>> showRoute({
  required dynamic item,
  required String apiKey,
  required Set<Marker> markers,
  required Set<Polyline> polylines,
  required GoogleMapController mapController,
  required BuildContext context,
}) async {
  print('showRoute called with item: $item');
  LatLng? destinationLatLng;
  String destinationName = '';
  if (item.containsKey('place')) {
    final placeId = item['place']['place_id'];
    destinationName = item['place']['description'];
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      destinationLatLng = LatLng(location['lat'], location['lng']);
    } else {
      print('Failed to get place details: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get destination details.')),
      );
      return {};
    }
  } else if (item.containsKey('route')) {
    FavoriteRoute route = item['route'];
    destinationLatLng = LatLng(route.latitude, route.longitude);
    destinationName = route.routeName;
  }
  if (destinationLatLng != null) {
    // Check if location services are enabled before proceeding with routing
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location services are disabled. Please enable them to show a route.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
          ),
        ),
      );
      return {};
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied. Please enable location permissions in settings.')),
        );
        return {};
      }
    }


    LatLng? originLatLng;
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      originLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      print('Error getting current location for routing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your current location for routing. Please ensure GPS is on.')),
      );
      return {}; // Return empty if current location cannot be obtained
    }

    if (originLatLng == null) {
      return {};
    }

    // --- NEW: Use Directions API HTTP request, just like getRoute ---
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${originLatLng.latitude},${originLatLng.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&key=$apiKey';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      if (decoded['routes'].isEmpty) {
        print('No routes found in Directions API response.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No route found.')),
        );
        return {};
      }
      final routeData = decoded['routes'][0];
      final leg = routeData['legs'][0];
      final startLatLng = leg['start_location'];
      final endLatLng = leg['end_location'];

      markers.clear();
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: LatLng(startLatLng['lat'], startLatLng['lng']),
        infoWindow: const InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
      markers.add(Marker(
        markerId: const MarkerId('end'),
        position: LatLng(endLatLng['lat'], endLatLng['lng']),
        infoWindow: InfoWindow(title: destinationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      List<PointLatLng> polylineCoordinates = PolylinePoints().decodePolyline(routeData['overview_polyline']['points']);
      List<LatLng> latLngList = polylineCoordinates.map((point) => LatLng(point.latitude, point.longitude)).toList();

      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          points: latLngList,
          width: 5,
        ),
      );

      mapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            latLngList.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
            latLngList.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            latLngList.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
            latLngList.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
          ),
        ),
        100.0,
      ));

      print('Added polyline with ${latLngList.length} points');
      print('Polylines count: ${polylines.length}');
      return {
        'distance': leg['distance']['text'],
        'duration': leg['duration']['text'],
      };
    } else {
      print('Failed to get directions: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get directions.')),
      );
      return {};
    }
  } else {
    print('Destination LatLng is null. Cannot show route.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not determine destination location.')),
    );
    return {};
  }
}

// Clear route from the map
void clearRoute(Set<Polyline> polylines, Set<Marker> markers) {
  polylines.clear();
  markers.removeWhere((marker) => marker.markerId.value == 'destination_marker');
  markers.removeWhere((marker) => marker.markerId.value == 'current_location_marker'); // Clear current location marker too
}

Future<LatLng> getLatLngFromPlaceId(String placeId) async {
  // Use Google Places Details API to get lat/lng from place_id
  final apiKey = 'AIzaSyAJP6e_5eBGz1j8b6DEKqLT-vest54Atkc';
  final url =
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
  final response = await http.get(Uri.parse(url));
  final data = json.decode(response.body);
  final location = data['result']['geometry']['location'];
  return LatLng(location['lat'], location['lng']);
}