import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'profile_page.dart';
import 'commenting_section.dart'; // Make sure this path is correct
import 'bottom_navbar.dart';
import 'AuthManager.dart';
import 'dart:async';
import 'floating_button.dart'; // Your new FloatingButton widget
import 'add_insight_modal.dart'; // Your new Add Insight Modal

// Import ChatMessage if it's moved to a separate file, otherwise it's still in commenting_section.dart
import 'commenting_section.dart' show ChatMessage; // Only import ChatMessage from here

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  final LatLng _initialCameraPosition = const LatLng(
    10.314481680817886,
    123.88813209917954,
  );

  bool _isCommunityInsightExpanded = false;
  int _selectedIndex = 0; // For BottomNavBar

  StreamSubscription? _otherUserLocationSubscription; // For WebSocket updates

  // MODIFIED: Dashboard now owns the chat messages list
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      sender: 'Zole Laverne',
      message:
          '“Ig 6PM juseyo, expect traffic sa Escariomida. Sakay nalang sa other side then walk to Ayala. Arraseo?”',
      route: 'Escario',
      timeAgo: '2 days ago',
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&h=500&fit=crop',
      likes: 15,
      isMostHelpful: true,
    ),
    ChatMessage(
      sender: 'Charisse Pempengco',
      message:
          '“Na agaw mog agi likod sa CDU kai na.... naay d mahimutang. Naa sya ddto mag atang”',
      route: 'Cebu Doc',
      timeAgo: '6 days ago',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&h=500&fit=crop',
      likes: 8,
      dislikes: 1,
    ),
    ChatMessage(
      sender: 'Kyline Alcantara',
      message:
          '“Kuyaw kaaio sa Carbon. Naay nangutana nako ug wat nafen vela? why u crying again? unya nikanta ug thousand years.... kuyawa sa mga adik rn...”',
      route: 'Carbon',
      timeAgo: '9 days ago',
      imageUrl:
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=500&h=500&fit=crop',
      likes: 22,
      dislikes: 2,
    ),
    ChatMessage(
      sender: 'Adopted Brother ni Mikha Lim',
      message:
          '“Ang plete kai tag 12 pesos pero ngano si kuya driver nangayo ug 15 pesos? SMACK THAT.”',
      route: 'Lahug – Carbon',
      timeAgo: 'Just Now',
      imageUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&h=500&fit=crop',
      likes: 5,
    ),
    ChatMessage(
      sender: 'Unknown',
      message:
          '“Shortcut to terminal: cut through Gaisano Mall ground floor!!!!!!”',
      route: 'Puente',
      timeAgo: '1 week ago',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop',
      dislikes: 7,
    ),
  ];


  @override
  void initState() {
    super.initState();
    _addMarker(_initialCameraPosition, 'cebu_city_marker', 'Cebu City');
    _getCurrentLocationAndMarker();

    _otherUserLocationSubscription = AuthManager().otherUserLocationStream
        .listen((location) {
          if (mounted) { // ADDED mounted check
            _updateOtherUserMarker(location);
          }
        });

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
    _otherUserLocationSubscription?.cancel();
    super.dispose();
  }

  void _addMarker(
    LatLng position,
    String markerId,
    String title, {
    BitmapDescriptor? icon,
  }) {
    if (mounted) { // ADDED mounted check
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
  }

  void _updateOtherUserMarker(LatLng newLocation) {
    if (mounted) { // ADDED mounted check
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
    }
  }

  Future<void> _getCurrentLocationAndMarker() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      if (mounted) { // ADDED mounted check
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
      }

      _mapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
      AuthManager().sendLocation(
        currentLatLng,
      );
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
    if (mounted) { // ADDED mounted check
      setState(() {
        _selectedIndex = index;
        print('Selected index: $_selectedIndex');
      });
    }
  }

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
          // Placeholder for what happens when 'add insight' button is pressed.
          // In a real app, you might want to call a method on CommentingSection
          // to show its add insight modal.
          // For now, let's just print a message or show a dummy snackbar.
          print('Add Insight button pressed!');
          // If you want to show the modal from CommentingSection, you'd need
          // a GlobalKey for CommentingSection or a shared state/controller.
          // As _showAddInsightSheet is private in CommentingSection's state,
          // it needs to be made public or exposed via a controller.
          // For demonstration, let's just show a simple dialog here.
          // To properly call CommentingSection's internal _showAddInsightSheet,
          // you would need to refactor CommentingSection to expose it,
          // e.g., via a GlobalKey<CommentingSectionState>()._showAddInsightSheet();
          // Or, CommentingSection itself would be responsible for rendering its FAB
          // and handling the press, in which case Dashboard wouldn't have this FAB.
          // Since the user explicitly asked for a separate floating_button.dart,
          // we are keeping FAB in Dashboard and controlling it via state.

          // Simplified action: Directly show a dummy bottom sheet for adding insight.
          // For actual integration, you'd integrate with CommentingSection's logic.
          showModalBottomSheet(
            context: context,
            onInsightAdded: _addNewInsight, // Pass the callback to add new insight
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

            // Pass the chat messages and the expansion callback to CommentingSection
            CommentingSection(
              onExpansionChanged: _onCommunityInsightExpansionChanged,
              chatMessages: _chatMessages, // Pass the list down
            ),

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
