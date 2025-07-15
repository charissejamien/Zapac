import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zapac/data/favorite_routes_data.dart';
import 'package:zapac/favorite_routes_page.dart';
import 'package:zapac/models/favorite_route.dart';
import 'package:zapac/route_detail_page.dart';
import 'package:zapac/profile_page.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'commenting_section.dart';
import 'bottom_navbar.dart';
import 'AuthManager.dart';
import 'dart:async';

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
  String _selectedFilter = 'All';
  int _selectedIndex = 0; // For BottomNavBar
  StreamSubscription? _otherUserLocationSubscription; // For WebSocket updates

  // --- State for Search and Routing ---
  bool _isSearchActive = false;
  final String apiKey = "AIzaSyAJP6e_5eBGz1j8b6DEKqLT-vest54Atkc"; // Replace with your key
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isShowingRoute = false;
  Map<String, String> _routeInfo = {};

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
    _addMarker(_initialCameraPosition, 'cebu_city_marker', 'Cebu City');
    _getCurrentLocationAndMarker();

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
        _updateOtherUserMarker(location);
      }
    });

    // Initialize other user's marker if they exist on start
    if (AuthManager().otherUser != null && AuthManager().otherUser!.currentLocation != null) {
      _addMarker(
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
  }

  void _addMarker(LatLng position, String markerId, String title, {BitmapDescriptor? icon}) {
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

  Future<void> _getCurrentLocationAndMarker() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: currentLatLng,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });

      if (mounted) {
        _mapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location.')),
        );
      }
    }
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
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    });

    // Optional: Move camera to follow other user
    // _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
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

  Future<void> _getPredictions(String input) async {
    // Implement Google Places Autocomplete API call
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:ph';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _predictions = data['predictions'];
      });
    } else {
      print('Failed to load predictions: ${response.statusCode}');
    }
  }

   void _showRoute(Map<String, dynamic> item) async {
    setState(() {
      _isSearchActive = false;
      _isShowingRoute = true;
      _predictions = [];
      _searchController.clear();
      _polylines.clear(); // Clear existing polylines
      _markers.removeWhere((marker) => marker.markerId.value == 'destination_marker'); // Ensure old destination marker is removed
    });

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
        // Optionally show a snackbar or error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get destination details.')),
          );
        }
        setState(() { _isShowingRoute = false; }); // Revert if failed
        return;
      }
    } else if (item.containsKey('route')) {
      FavoriteRoute route = item['route'];
      destinationLatLng = LatLng(route.latitude, route.longitude); // Access latitude and longitude directly
      destinationName = route.routeName;
    }

    if (destinationLatLng != null) {
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng originLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      _addMarker(destinationLatLng, 'destination_marker', destinationName, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

      // Calculate bounds for camera animation
      LatLngBounds bounds;
      if (originLatLng.latitude == destinationLatLng.latitude && originLatLng.longitude == destinationLatLng.longitude) {
        // If origin and destination are the same, just center on it with a reasonable zoom
        _mapController.animateCamera(CameraUpdate.newLatLngZoom(originLatLng, 15.0));
      } else {
        bounds = LatLngBounds(
          southwest: LatLng(
            math.min(originLatLng.latitude, destinationLatLng.latitude),
            math.min(originLatLng.longitude, destinationLatLng.longitude),
          ),
          northeast: LatLng(
            math.max(originLatLng.latitude, destinationLatLng.latitude),
            math.max(originLatLng.longitude, destinationLatLng.longitude),
          ),
        );
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100)); // 100 is padding
      }


     
      // Get directions
      // PolylinePoints polylinePoints = PolylinePoints();
      // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      //   origin: PointLatLng(originLatLng.latitude, originLatLng.longitude),
      //   destination: PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
      //   travelMode: TravelMode.driving,
      //   apiKey: apiKey,
      // );
      
    //   if (result.points.isNotEmpty) {
    //     List<LatLng> polylineCoordinates = result.points
    //         .map((point) => LatLng(point.latitude, point.longitude))
    //         .toList();

    //     setState(() {
    //       _polylines.add(
    //         Polyline(
    //           polylineId: const PolylineId('route'),
    //           points: polylineCoordinates,
    //           color: Colors.blue,
    //           width: 5,
    //         ),
    //       );
          
    //       _routeInfo = {
    //         'distance': 'N/A',
    //         'duration': 'N/A',
    //       };
    //     });
    //   } else {
    //     print('No polyline points found.');
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Could not find a route.')),
    //       );
    //     }
    //     setState(() { _isShowingRoute = false; }); // Revert if no route found
    //   }
    // } else {
    //   print('Destination LatLng is null. Cannot show route.');
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Could not determine destination location.')),
    //     );
    //   }
    //   setState(() { _isShowingRoute = false; });
    }
  }
  void _clearRoute() {
    setState(() {
      _isShowingRoute = false;
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value == 'destination_marker');
      _routeInfo = {};
    });
  }

  // --- Build methods are already correctly placed inside _DashboardState ---
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
        // Removed DraggableScrollableSheet for insights/comments
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
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _isSearchActive = false;
                      _searchController.clear();
                      _predictions = [];
                    }),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _getPredictions,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Where to?",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (favoriteRoutes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  children: favoriteRoutes
                      .map(
                        (route) => ElevatedButton(
                          onPressed: () => _showRoute({'route': route}),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6CA89A),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(route.routeName),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (favoriteRoutes.isNotEmpty) const Divider(height: 1),
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildList(_recentLocations, Icons.history)
                  : _buildList(_predictions, Icons.location_on_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> items, IconData icon) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(icon, color: Colors.grey),
          title: Text(items[index]['description']),
          onTap: () => _showRoute({'place': items[index]}),
        );
      },
    );
  }

  Widget _buildRouteDetailsSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Route to Destination",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("Distance", style: TextStyle(color: Colors.grey)),
                      Text(
                        _routeInfo['distance'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Duration", style: TextStyle(color: Colors.grey)),
                      Text(
                        _routeInfo['duration'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _clearRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE97C7C),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Clear Route"),
              ),
            ],
          ),
        ),
      ),
    );
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
