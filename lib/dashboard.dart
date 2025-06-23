import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  // Default camera position (Cebu City)
  LatLng _initialCameraPosition =
      const LatLng(10.314481680817886, 123.88813209917954);

  @override
  void initState() {
    super.initState();
    _addMarker(_initialCameraPosition, 'cebu_city_marker', 'Cebu City');
    _getCurrentLocationAndMarker();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _addMarker(LatLng position, String markerId, String title) {
    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: title, snippet: 'A great place!'),
      ),
    );
    setState(() {});
  }

  Future<void> _getCurrentLocationAndMarker() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied. We cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    // Move camera and add a marker
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation, 14.0),
    );
    _addMarker(currentLocation, 'current_location_marker', 'Your Location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating button to recenter on current location
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocationAndMarker,
        child: const Icon(Icons.my_location),
      ),

      // Bottom navigation bar
      bottomNavigationBar: const _BottomNavBar(),

      // Main body: full-screen map, floating overlays
      body: SafeArea(
        child: Stack(
          children: [
            // 1) Full-screen Google Map
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialCameraPosition,
                  zoom: 14.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // we use our FAB instead
              ),
            ),

            // 2) Draggable chat sheet on top of the map
            DraggableScrollableSheet(
              initialChildSize: 0.30,
              minChildSize: 0.10,
              maxChildSize: 0.80,
              builder: (context, scrollController) {
                return Container(
                  color: const Color(0xFFF9F9F9),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 1 + 10,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Yellow handle at top of sheet
                        return Container(
                          height: 31,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4BE6C),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                        );
                      }
                      final i = index - 1;
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage:
                              NetworkImage('https://placehold.co/66x72'),
                        ),
                        title: const Text('“Example message…”'),
                        subtitle:
                            Text('Route : Escario • ${i + 1} days ago'),
                      );
                    },
                  ),
                );
              },
            ),

            // 3) Search bar always on top
            const Positioned(
              top: 12,
              left: 19,
              right: 19,
              child: _SearchBar(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Search Bar Widget ---
class _SearchBar extends StatelessWidget {
  const _SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ShapeDecoration(
        color: const Color(0xFFD9E0EA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
        shadows: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.4),
            blurRadius: 6.8,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Where to?',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF6CA89A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// --- Bottom Navigation Bar Widget ---
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF4A6FA5),
        boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.bookmark, size: 30, color: Colors.white),
          Icon(Icons.menu, size: 30, color: Colors.white),
        ],
      ),
    );
  }
}