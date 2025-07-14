import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zapac/data/favorite_routes_data.dart';
import 'package:zapac/favorite_routes_page.dart';
import 'package:zapac/models/favorite_route.dart';
import 'package:zapac/profile_page.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'commenting_section.dart';
import 'bottom_navbar.dart';
import 'AuthManager.dart';
import 'dart:async';

// --- Dummy Data for Chat Messages ---
class ChatMessage {
  final String sender;
  final String message;
  final String route;
  final String timeAgo;
  final String imageUrl;
  int likes;
  int dislikes;
  bool isLiked;
  bool isDisliked;
  bool isMostHelpful; // NEW: To show the 'Most Helpful' tag

  ChatMessage({
    required this.sender,
    required this.message,
    required this.route,
    required this.timeAgo,
    required this.imageUrl,
    this.likes = 0,
    this.dislikes = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isMostHelpful = false, // NEW: Default to false
  });
}

// MODIFIED: Updated dummy data to match the UI and include 'isMostHelpful'
List<ChatMessage> _chatMessages = [
  ChatMessage(
    sender: 'Zole Laverne',
    message: '“Ig 6PM juseyo, expect traffic sa Escariomida. Sakay nalang sa other side then walk to Ayala. Arraseo?”',
    route: 'Escario',
    timeAgo: '2 days ago',
    imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&h=500&fit=crop',
    likes: 15,
    isMostHelpful: true,
  ),
  ChatMessage(
    sender: 'Charisse Pempengco',
    message: '“Na agaw mog agi likod sa CDU kai na.... naay d mahimutang. Naa sya ddto mag atang”',
    route: 'Cebu Doc',
    timeAgo: '6 days ago',
    imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&h=500&fit=crop',
    likes: 8,
    dislikes: 1,
  ),
  ChatMessage(
    sender: 'Kyline Alcantara',
    message: '“Kuyaw kaaio sa Carbon. Naay nangutana nako ug wat nafen vela? why u crying again? unya nikanta ug thousand years.... kuyawa sa mga adik rn...”',
    route: 'Carbon',
    timeAgo: '9 days ago',
    imageUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=500&h=500&fit=crop',
    likes: 22,
    dislikes: 2,
  ),
  ChatMessage(
    sender: 'Adopted Brother ni Mikha Lim',
    message: '“Ang plete kai tag 12 pesos pero ngano si kuya driver nangayo ug 15 pesos? SMACK THAT.”',
    route: 'Lahug – Carbon',
    timeAgo: 'Just Now',
    imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&h=500&fit=crop',
    likes: 5,
  ),
  ChatMessage(
    sender: 'Unknown',
    message: '“Shortcut to terminal: cut through Gaisano Mall ground floor!!!!!!”',
    route: 'Puente',
    timeAgo: '1 week ago',
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop',
    dislikes: 7,
  ),
];

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
}


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
      if (!_isShowingRoute)
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.35,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          builder: (context, scrollController) =>
              _buildInsightsSheet(scrollController),
        ),
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

Widget _buildInsightsSheet(ScrollController scrollController) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF4BE6C),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Taga ZAPAC says...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) =>
                _buildInsightCard(_chatMessages[index]),
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInsightCard(ChatMessage message) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(message.imageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    message.sender,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (message.isMostHelpful)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CA89A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '💡 Most Helpful',
                        style: TextStyle(
                          color: Color(0xFF6CA89A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  const Icon(Icons.more_horiz, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${message.route}  |  ${message.timeAgo}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF4A6FA5),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.home, size: 30, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteRoutesPage()),
              );
            },
            icon: const Icon(Icons.bookmark, size: 30, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
