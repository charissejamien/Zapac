import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  LatLng _initialCameraPosition = LatLng(10.314481680817886, 123.88813209917954);

  @override
  void initState(){
    super.initState();
    _addMarker(_initialCameraPosition, 'cebu_city_marker', 'Cebu City');
    _getCurrentLocationAndMarker();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addMarker(LatLng position, String markerId, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(
            title: title,
            snippet: 'A great place!',
          ),
          icon: BitmapDescriptor.defaultMarker, // Default red pin
          // You can customize the icon:
          // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          // icon: BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/custom_pin.png'),
        ),
      );
    });
  }

  Future<void> _getCurrentLocationAndMarker() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      // accessing the position and request users to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // comes into play).
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentLocation = LatLng(position.latitude, position.longitude);
    setState(() {
      _initialCameraPosition = currentLocation; // Update initial position
    });
    _addMarker(currentLocation, 'current_location_marker', 'Your Location');
    mapController.animateCamera(CameraUpdate.newLatLngZoom(currentLocation, 14.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps with Pin'),
        backgroundColor: Colors.blue,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialCameraPosition,
          zoom: 12.0,
        ),
        markers: _markers, // Pass the set of markers here
        myLocationEnabled: true, // Shows the blue dot for current location
        myLocationButtonEnabled: true, // Shows the button to center on current location
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocationAndMarker,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}