import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'profile_page.dart';
import 'commenting_section.dart';
import 'bottom_navbar.dart';
import 'AuthManager.dart';
import 'dart:async';
// Import the new floating_button.dart file
import 'floating_button.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  // No longer need _sheetController here if only CommentingSection uses it.
  // final DraggableScrollableController _sheetController = DraggableScrollableController();

  final LatLng _initialCameraPosition = const LatLng(
    10.314481680817886,
    123.88813209917954,
  );

  // New state variable to track community insight sheet expansion
  bool _isCommunityInsightExpanded = false;
  // bool _isSheetFullyExpanded = false; // This can now be removed or repurposed if it controlled other sheets

  int _selectedIndex = 0; // For BottomNavBar

  StreamSubscription? _otherUserLocationSubscription; // For WebSocket updates

  @override
  void initState() {
    super.initState();
    _addMarker(_initialCameraPosition, 'cebu_city_marker', 'Cebu City');
    _getCurrentLocationAndMarker();

    // The listener for _sheetController (if it controlled _buildRouteDetailsSheet)
    // would stay here. If CommentingSection is the only sheet changing the FAB,
    // then the logic for _isSheetFullyExpanded based on _sheetController
    // is no longer directly needed in Dashboard.
    // However, if _isSheetFullyExpanded refers to *other* draggable sheets on Dashboard,
    // you might keep it and combine conditions, or rename for clarity.
    // For this solution, we focus on the _isCommunityInsightExpanded state.
    // If your original _isSheetFullyExpanded also handled something relevant to the FAB,
    // you'll need to decide how to combine these states.

    // _sheetController.addListener(() {
    //   if (_sheetController.size >= 0.85 && !_isSheetFullyExpanded) {
    //     setState(() => _isSheetFullyExpanded = true);
    //   } else if (_sheetController.size < 0.85 && _isSheetFullyExpanded) {
    //     setState(() => _isSheetFullyExpanded = false);
    //   }
    // });


    // Listen to other user's location stream from AuthManager
    _otherUserLocationSubscription = AuthManager().otherUserLocationStream
        .listen((location) {
          if (mounted) {
            // Ensure widget is still mounted before setState
            _updateOtherUserMarker(location);
          }
        });

    // Initialize other user's marker if they exist on start
    if (AuthManager().otherUser != null &&
        AuthManager().otherUser!.currentLocation != null) {
      _addMarker(
        AuthManager().otherUser!.currentLocation!,
        'other_user_location',
        AuthManager().otherUser!.fullName,
      );
    }
  }

  @override
  void dispose() {
    // _sheetController.dispose(); // Dispose if still used for other sheets
    _otherUserLocationSubscription?.cancel(); // Cancel subscription
    super.dispose();
  }

  void _addMarker(
    LatLng position,
    String markerId,
    String title, {
    BitmapDescriptor? icon,
  }) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: icon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  void _updateOtherUserMarker(LatLng newLocation) {
    setState(() {
      _markers.removeWhere(
        (marker) => marker.markerId.value == 'other_user_location',
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('other_user_location'),
          position: newLocation,
          infoWindow: InfoWindow(
            title: AuthManager().otherUser?.fullName ?? 'Other User',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange, // Different color for other user
          ),
        ),
      );
    });
    // Optionally move camera to track the other user
    // _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
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
      AuthManager().sendLocation(
        currentLatLng,
      ); // Send current user's location via WebSocket
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

  // Define the callback function to be passed to CommentingSection
  void _onCommunityInsightExpansionChanged(bool isExpanded) {
    setState(() {
      _isCommunityInsightExpanded = isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingButton(
        isCommunityInsightExpanded: _isCommunityInsightExpanded,
        onAddInsightPressed: () {
          print('Add Insight button pressed!');
          showModalBottomSheet(
            context: context,
            builder: (context) => const SizedBox(
              height: 200,
              child: Center(
                child: Text('Add New Insight Modal (from Dashboard FAB)'),
              ),
            ),
          );
        },
        onMyLocationPressed: _getCurrentLocationAndMarker,
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

            // Pass the callback to CommentingSection
            CommentingSection(onExpansionChanged: _onCommunityInsightExpansionChanged),

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
