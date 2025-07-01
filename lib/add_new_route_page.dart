import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:zapac/location_search_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zapac/models/favorite_route.dart'; // Import the new model

class AddNewRoutePage extends StatefulWidget {
  const AddNewRoutePage({super.key});

  @override
  _AddNewRoutePageState createState() => _AddNewRoutePageState();
}

class _AddNewRoutePageState extends State<AddNewRoutePage> {
  final String apiKey = "YOUR_API_KEY"; // IMPORTANT: Replace with your API key

  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  Map<String, dynamic>? _startLocation;
  Map<String, dynamic>? _destinationLocation;
  Map<String, dynamic>? _directionsResponse;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _getRoute() async {
    if (_startLocation == null || _destinationLocation == null) {
      return;
    }

    final startPlaceId = _startLocation!['place_id'];
    final destinationPlaceId = _destinationLocation!['place_id'];

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=place_id:$startPlaceId&destination=place_id:$destinationPlaceId&key=$apiKey';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      List<PointLatLng> polylineCoordinates = PolylinePoints()
          .decodePolyline(decoded['routes'][0]['overview_polyline']['points']);

      List<LatLng> latLngList = polylineCoordinates
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _directionsResponse = decoded;
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          points: latLngList,
          width: 5,
        ));
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _createBounds(latLngList),
          100.0,
        ),
      );
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void _saveRoute() {
    if (_routeNameController.text.isEmpty || _directionsResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a route name and get directions.')),
      );
      return;
    }

    final routeData = _directionsResponse!['routes'][0];
    final leg = routeData['legs'][0];

    final newRoute = FavoriteRoute(
      routeName: _routeNameController.text,
      startAddress: leg['start_address'],
      endAddress: leg['end_address'],
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      polylinePoints: _polylines.first.points,
      bounds: _createBounds(_polylines.first.points),
    );

    Navigator.pop(context, newRoute);
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat =
        positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final southwestLon =
        positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final northeastLat =
        positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final northeastLon =
        positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLon),
      northeast: LatLng(northeastLat, northeastLon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Route'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoute,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _routeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Route Name',
                  ),
                ),
                TextField(
                  controller: _startLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Starting Location',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationSearchPage(apiKey: apiKey),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _startLocation = result;
                        _startLocationController.text = result['description'];
                      });
                    }
                  },
                ),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationSearchPage(apiKey: apiKey),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _destinationLocation = result;
                        _destinationController.text = result['description'];
                      });
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: _getRoute,
                  child: const Text('Show Route'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.3157, 123.8854), // Cebu City
                zoom: 12,
              ),
              polylines: _polylines,
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}