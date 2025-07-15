// Utility functions for map operations
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
    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng originLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
    markers.add(
      Marker(
        markerId: const MarkerId('destination_marker'),
        position: destinationLatLng,
        infoWindow: InfoWindow(title: destinationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    if (originLatLng.latitude == destinationLatLng.latitude && originLatLng.longitude == destinationLatLng.longitude) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(originLatLng, 15.0));
    } else {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          math.min(originLatLng.latitude, destinationLatLng.latitude),
          math.min(originLatLng.longitude, destinationLatLng.longitude),
        ),
        northeast: LatLng(
          math.max(originLatLng.latitude, destinationLatLng.latitude),
          math.max(originLatLng.longitude, destinationLatLng.longitude),
        ),
      );
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(originLatLng.latitude, originLatLng.longitude),
        destination: PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
        mode: TravelMode.driving,
      ),
      googleApiKey: apiKey,
    );
    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
      return {
        'distance': 'N/A',
        'duration': 'N/A',
      };
    } else {
      print('No polyline points found.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find a route.')),
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
}
