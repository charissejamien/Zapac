import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'profile_page.dart'; // Assuming profile_page.dart exists
import 'commenting_section.dart'; // Import the new commenting section
import 'bottom_navbar.dart'; // Import the new bottom nav bar

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final LatLng _initialCameraPosition = const LatLng(
    10.314481680817886,
    123.88813209917954,
  );

  bool _isSheetFullyExpanded = false;
  int _selectedIndex = 0; // For BottomNavBar

  @override
  void initState() {
    super.initState();
    _addMarker(_initialCameraPosition, 'cebu_city_marker', 'Cebu City');
    _getCurrentLocationAndMarker();

    _sheetController.addListener(() {
      if (_sheetController.size >= 0.85 && !_isSheetFullyExpanded) {
        setState(() => _isSheetFullyExpanded = true);
      } else if (_sheetController.size < 0.85 && _isSheetFullyExpanded) {
        setState(() => _isSheetFullyExpanded = false);
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _addMarker(LatLng position, String markerId, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: title),
        ),
      );
    });
  }

  Future<void> _getCurrentLocationAndMarker() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.removeWhere(
          (marker) => marker.markerId.value == 'current_location',
        );
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: currentLatLng,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
      });

      _mapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location.')),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation for other tabs if needed
      print('Selected index: $_selectedIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isSheetFullyExpanded
          ? FloatingActionButton(
              onPressed: () {
                // Accessing the method from CommentingSectionState
                // This requires a GlobalKey or passing a callback
                // For simplicity, we'll assume CommentingSection will manage its own FAB if expanded.
                // Or you can pass a callback to CommentingSection.
              },
              backgroundColor: const Color(0xFF6CA89A),
              heroTag: 'addInsightBtn',
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : FloatingActionButton(
              onPressed: _getCurrentLocationAndMarker,
              backgroundColor: const Color(0xFF6CA89A),
              heroTag: 'myLocationBtn',
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialCameraPosition,
                  zoom: 14.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),

            CommentingSection(), // Calling the new CommentingSection widget

            const Positioned(top: 12, left: 19, right: 19, child: SearchBar()),
          ],
        ),
      ),
    );
  }
}

// --- Search Bar Widget (Unchanged) ---
class SearchBar extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const SearchBar({super.key, this.onProfileTap});
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6CA89A)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Where to?',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    onSubmitted: (value) =>
                        print('Search query submitted: $value'),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.onProfileTap?.call();
              print('Profile icon tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: Container(
              width: 34,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF6CA89A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_circle, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
