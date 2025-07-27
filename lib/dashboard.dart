import 'package:flutter/material.dart' hide SearchBar;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'profile_page.dart';
import 'commenting_section.dart'; // Make sure this path is correct
import 'bottom_navbar.dart';
import 'AuthManager.dart';
import 'dart:async';
import 'floating_button.dart'; // Your new FloatingButton widget
import 'add_insight_modal.dart'; // Your new Add Insight Modal
import 'search_bar_widget.dart';
import 'map_utils.dart';

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
  final Set<Polyline> _polylines = {}; // <-- Add this line

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
          '"Ig 6PM juseyo, expect traffic sa Escariomida. Sakay nalang sa other side then walk to Ayala. Arraseo?"',
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
          '"Na agaw mog agi likod sa CDU kai na.... naay d mahimutang. Naa sya ddto mag atang"',
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
          '"Kuyaw kaaio sa Carbon. Naay nangutana nako ug wat nafen vela? why u crying again? unya nikanta ug thousand years.... kuyawa sa mga adik rn..."',
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
          '"Ang plete kai tag 12 pesos pero ngano si kuya driver nangayo ug 15 pesos? SMACK THAT."',
      route: 'Lahug – Carbon',
      timeAgo: 'Just Now',
      imageUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&h=500&fit=crop',
      likes: 5,
    ),
    ChatMessage(
      sender: 'Unknown',
      message:
          '"Shortcut to terminal: cut through Gaisano Mall ground floor!!!!!!"',
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
    addMarker(_markers, _initialCameraPosition, 'cebu_city_marker', 'Cebu City');

    _otherUserLocationSubscription = AuthManager().otherUserLocationStream
        .listen((location) {
          if (mounted) { // ADDED mounted check
            updateOtherUserMarker(
              _markers,
              location,
              AuthManager().otherUser?.fullName,
            );
            setState(() {});
          }
        });

    if (AuthManager().otherUser != null &&
        AuthManager().otherUser!.currentLocation != null) {
      addMarker(
        _markers,
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Use a safer approach for async operations after widget creation
    getCurrentLocationAndMarker(
      _markers,
      _mapController,
      context,
      isMounted: () => mounted,
    ).then((_) {
      if (mounted) { // Check if widget is still mounted before calling setState
        setState(() {});
      }
    }).catchError((error) {
      // Handle any errors gracefully
      print('Error in getCurrentLocationAndMarker: $error');
    });
  }

  void _onItemTapped(int index) {
    if (!mounted) return; // Early return if not mounted
    setState(() {
      _selectedIndex = index;
      print('Selected index: $_selectedIndex');
    });
  }

  void _onCommunityInsightExpansionChanged(bool isExpanded) {
    if (!mounted) return; // Early return if not mounted
    setState(() {
      _isCommunityInsightExpanded = isExpanded;
    });
  }

  // Callback for when a new insight is added from the modal
  void _addNewInsight(ChatMessage newInsight) {
    if (!mounted) return; // Early return if not mounted
    setState(() {
      _chatMessages.insert(0, newInsight);
    });
  }

  // Safe method to handle async location updates
  Future<void> _handleMyLocationPressed() async {
    if (!mounted) return; // Check before starting async operation
    
    try {
      await getCurrentLocationAndMarker(
        _markers,
        _mapController,
        context,
        isMounted: () => mounted,
      );
      if (mounted) { // Check again after async operation
        setState(() {});
      }
    } catch (error) {
      print('Error getting current location: $error');
      // Optionally show a snackbar or handle the error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location')),
        );
      }
    }
  }

  // Safe method to handle search place selection
  Future<void> _handlePlaceSelected(dynamic item) async {
    if (!mounted) return; // Check before starting async operation
    
    print('Calling showRoute with: $item');
    try {
      await showRoute(
        item: item,
        apiKey: "AIzaSyAJP6e_5eBGz1j8b6DEKqLT-vest54Atkc",
        markers: _markers,
        polylines: _polylines,
        mapController: _mapController,
        context: context,
      );
      if (mounted) { // Check again after async operation
        setState(() {});
      }
    } catch (error) {
      print('Error in showRoute: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to show route')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingButton(
        isCommunityInsightExpanded: _isCommunityInsightExpanded,
        onAddInsightPressed: () {
          if (!mounted) return; // Safety check
          // Call your new showAddInsightModal function
          showAddInsightModal(
            context: context,
            onInsightAdded: _addNewInsight, // Pass the callback to add new insight
          );
        },
        onMyLocationPressed: _handleMyLocationPressed, // Use the safe method
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
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),

            // Pass the chat messages to CommentingSection
            CommentingSection(
              chatMessages: _chatMessages,
              onExpansionChanged: _onCommunityInsightExpansionChanged,  // Pass the list down
            ),

            SearchBar(
              onPlaceSelected: _handlePlaceSelected, // Use the safe method
            ),
          ],
        ),
      ),
    );
  }
}