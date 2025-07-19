import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapac/favorite_routes_page.dart';
import 'package:zapac/map_utils.dart';
import 'package:zapac/profile_page.dart';
import 'bottom_navbar.dart';
import 'AuthManager.dart';
import 'dart:async';
import 'package:zapac/search_and_routing_utils.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final TextEditingController _commentController = TextEditingController();
  final LatLng _initialCameraPosition = const LatLng(10.314481680817886, 123.88813209917954);

  bool _isSheetFullyExpanded = false;
  int _selectedIndex = 0; // For BottomNavBar
  StreamSubscription? _otherUserLocationSubscription; // For WebSocket updates

  // --- State for Search and Routing ---
  bool _isSearchActive = false;
  final String apiKey = "AIzaSyAJP6e_5eBGz1j8b6DEKqLT-vest54Atkc";
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isShowingRoute = false;
  Map<String, dynamic> _routeInfo = {};

  final List<Map<String, dynamic>> _recentLocations = [
    {'description': 'House ni Gorgeous', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'House sa Gwapa', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'House ni Pretty', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'SM J Mall', 'place_id': 'ChIJb_MjLwtwqTMReyS2tJz13ic'},
    {'description': 'House ni Lim', 'place_id': 'ChIJ7d3F9kFwqTMRgR2kYh2sF-8'},
    {'description': 'iAcademy Cebu', 'place_id': 'ChIJ155n0wtwqTMRsP82-fG436Y'},
    {'description': 'Ayala Malls Central Bloc', 'place_id': 'ChIJ-c52xgtwqTMR_F098xGvXD4'},
  ];

  @override
  void initState() {
    super.initState();
    addMarker(_markers, _initialCameraPosition, 'cebu_city_marker', 'Cebu City');

    _sheetController.addListener(() {
      if (_sheetController.size >= 0.85 && !_isSheetFullyExpanded) {
        setState(() => _isSheetFullyExpanded = true);
      } else if (_sheetController.size < 0.85 && _isSheetFullyExpanded) {
        setState(() => _isSheetFullyExpanded = false);
      }
    });

    // Listen to other user's location stream from AuthManager
    _otherUserLocationSubscription = AuthManager().otherUserLocationStream.listen((location) {
      if (mounted) {
        updateOtherUserMarker(_markers, location, AuthManager().otherUser?.fullName);
      }
    });

    // Initialize other user's marker if they exist on start
    if (AuthManager().otherUser != null && AuthManager().otherUser!.currentLocation != null) {
      addMarker(
        _markers,
        AuthManager().otherUser!.currentLocation!,
        'other_user_location',
        AuthManager().otherUser!.fullName,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _sheetController.dispose();
    _commentController.dispose();
    _searchController.dispose();
    _otherUserLocationSubscription?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocationAndMarker(_markers, _mapController, context);
    });
  }

  Future<void> _getCurrentLocationAndMarker() async {
    try {
      await getCurrentLocationAndMarker(_markers, _mapController, context).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location fetch timed out.')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  // --- Placeholder for missing methods referenced in the code ---
  void _showAddInsightSheet() {
    // Implement logic to show the add insight sheet
    print('Show add insight sheet');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation based on index if needed
      if (index == 1) { // Assuming index 1 is for Favorite Routes
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoriteRoutesPage()),
        );
      } else if (index == 0) {
        // Already on home, do nothing or animate map
      } else if (index == 2) {
        // Handle menu item tap, perhaps show a dialog or another page
      }
    });
  }

  void _showRoute(Map<String, dynamic> item) async {
    setState(() {
      _isSearchActive = false;
      _isShowingRoute = true;
      _predictions = [];
      _searchController.clear();
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value == 'destination_marker');
    });
    final routeInfo = await showRoute(
      item: item,
      apiKey: apiKey,
      markers: _markers,
      polylines: _polylines,
      mapController: _mapController,
      context: context,
    );
    setState(() {
      _routeInfo = routeInfo;
      if (routeInfo.isEmpty) _isShowingRoute = false;
    });
  }
  void _clearRoute() {
    setState(() {
      _isShowingRoute = false;
      clearRoute(_polylines, _markers);
      _routeInfo = {};
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isSheetFullyExpanded && !_isSearchActive
          ? FloatingActionButton(
              onPressed: _showAddInsightSheet,
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
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialCameraPosition,
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onTap: (_) {
                if (_isSearchActive) {
                  setState(() {
                    _isSearchActive = false;
                    _searchController.clear();
                    _predictions = [];
                  });
                }
              },
            ),
            if (_isSearchActive)
              _buildSearchView()
            else
              _buildDefaultView(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultView() {
    return Stack(
      children: [
        if (_isShowingRoute) _buildRouteDetailsSheet(),
        Positioned(
          top: 12,
          left: 19,
          right: 19,
          child: SearchBar(
            onTap: () => setState(() => _isSearchActive = true),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchView() {
    return buildSearchViewUtil(
      searchController: _searchController,
      predictions: _predictions,
      recentLocations: _recentLocations,
      onRoute: _showRoute,
      onClose: () => setState(() {
        _isSearchActive = false;
        _searchController.clear();
        _predictions = [];
      }),
    );
  }

  Widget _buildRouteDetailsSheet() {
    return buildRouteDetailsSheetUtil(_routeInfo, _clearRoute);
  }
}

class SearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  const SearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: Container(
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
              const Icon(Icons.search, color: Color(0xFF6CA89A)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Where to?',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ),
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
        ),
      ),
    );
  }
}
