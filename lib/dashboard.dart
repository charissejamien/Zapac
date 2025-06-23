import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// --- Dummy Data for Chat Messages ---
class ChatMessage {
  final String sender;
  final String message;
  final String route;
  final String timeAgo;
  final String imageUrl;
  int likes; // Added likes count
  int dislikes; // Added dislikes count
  bool isLiked; // To track if the current user liked it
  bool isDisliked; // To track if the current user disliked it


  ChatMessage({
    required this.sender,
    required this.message,
    required this.route,
    required this.timeAgo,
    required this.imageUrl,
    this.likes = 0, // Default likes to 0
    this.dislikes = 0, // Default dislikes to 0
    this.isLiked = false,
    this.isDisliked = false,
  });
}

// Example dummy chat messages
List<ChatMessage> _chatMessages = [
  ChatMessage(
    sender: 'Alice',
    message: 'Looking for a ride near Ayala Mall!',
    route: 'Ayala',
    timeAgo: '2 hours ago',
    imageUrl: 'https://placehold.co/66x72/FF5733/FFFFFF?text=A',
    likes: 15,
  ),
  ChatMessage(
    sender: 'Bob',
    message: 'Anyone heading to IT Park from Lahug?',
    route: 'IT Park',
    timeAgo: '4 hours ago',
    imageUrl: 'https://placehold.co/66x72/33FF57/FFFFFF?text=B',
    likes: 8,
    dislikes: 1,
  ),
  ChatMessage(
    sender: 'Charlie',
    message: 'Shared a jeepney from Carbon to Colon.',
    route: 'Carbon-Colon',
    timeAgo: '1 day ago',
    imageUrl: 'https://placehold.co/66x72/3357FF/FFFFFF?text=C',
    likes: 22,
    dislikes: 2,
  ),
  ChatMessage(
    sender: 'Diana',
    message: 'Found a good spot for coffee near Fuente Osmeña.',
    route: 'Fuente',
    timeAgo: '2 days ago',
    imageUrl: 'https://placehold.co/66x72/FF33DA/FFFFFF?text=D',
    likes: 5,
  ),
  ChatMessage(
    sender: 'Eve',
    message: 'Traffic is heavy on Guadalupe today.',
    route: 'Guadalupe',
    timeAgo: '3 days ago',
    imageUrl: 'https://placehold.co/66x72/DAFF33/FFFFFF?text=E',
    dislikes: 7,
  ),
  ChatMessage(
    sender: 'Frank',
    message: 'Looking for directions to Taoist Temple.',
    route: 'Taoist Temple',
    timeAgo: '4 days ago',
    imageUrl: 'https://placehold.co/66x72/33DAFF/FFFFFF?text=F',
    likes: 10,
  ),
  ChatMessage(
    sender: 'Grace',
    message: 'Is there a bus from SM Seaside to Mactan Airport?',
    route: 'Airport',
    timeAgo: '5 days ago',
    imageUrl: 'https://placehold.co/66x72/8A33FF/FFFFFF?text=G',
    likes: 3,
    dislikes: 1,
  ),
  ChatMessage(
    sender: 'Heidi',
    message: 'Exploring the historical sites in downtown Cebu.',
    route: 'Downtown',
    timeAgo: '6 days ago',
    imageUrl: 'https://placehold.co/66x72/FF8A33/FFFFFF?text=H',
    likes: 18,
  ),
  ChatMessage(
    sender: 'Ivan',
    message: 'Any recommendations for local food?',
    route: 'Food Trip',
    timeAgo: '1 week ago',
    imageUrl: 'https://placehold.co/66x72/33FF8A/FFFFFF?text=I',
    likes: 25,
    dislikes: 3,
  ),
  ChatMessage(
    sender: 'Judy',
    message: 'Heading to Tops Lookout for sunset views.',
    route: 'Tops',
    timeAgo: '1 week ago',
    imageUrl: 'https://placehold.co/66x72/8A7933/FFFFFF?text=J',
    likes: 12,
  ),
];


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  LatLng _initialCameraPosition =
      const LatLng(10.314481680817886, 123.88813209917954);

  @override
  void initState() {
    super.initState();
    _addMarker(_initialCameraPosition, 'cebu_city_marker', 'Cebu City');
    _getCurrentLocationAndMarker();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
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
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied. Cannot request.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 14.0),
      );
      _markers.removeWhere((marker) => marker.markerId.value == 'current_location_marker');
      _addMarker(currentLocation, 'current_location_marker', 'Your Location');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _collapseSheet() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.30,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Function to handle like button press
  void _toggleLike(int index) {
    setState(() {
      ChatMessage message = _chatMessages[index];
      if (message.isLiked) {
        message.likes--;
        message.isLiked = false;
      } else {
        message.likes++;
        message.isLiked = true;
        if (message.isDisliked) {
          message.dislikes--;
          message.isDisliked = false;
        }
      }
    });
  }

  // Function to handle dislike button press
  void _toggleDislike(int index) {
    setState(() {
      ChatMessage message = _chatMessages[index];
      if (message.isDisliked) {
        message.dislikes--;
        message.isDisliked = false;
      } else {
        message.dislikes++;
        message.isDisliked = true;
        if (message.isLiked) {
          message.likes--;
          message.isLiked = false;
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _collapseSheet,
            backgroundColor: const Color(0xFFF4BE6C),
            heroTag: 'collapseBtn',
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getCurrentLocationAndMarker,
            backgroundColor: const Color(0xFF6CA89A),
            heroTag: 'myLocationBtn',
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: const BottomNavBar(),

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

            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.30,
              minChildSize: 0.15,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Community Insights',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = _chatMessages[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(message.imageUrl),
                              ),
                              title: Text(
                                message.sender,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              // Subtitle now contains message, route/time, and like/dislike buttons
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(message.message),
                                  Text(
                                    'Route: ${message.route} • ${message.timeAgo}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  const SizedBox(height: 8), // Spacing between text and buttons
                                  Row(
                                    children: [
                                      // Like Button and Count
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.thumb_up,
                                              color: message.isLiked ? Colors.blue : Colors.blueGrey,
                                            ),
                                            onPressed: () => _toggleLike(index),
                                            visualDensity: VisualDensity.compact, // Make icon button smaller
                                            padding: EdgeInsets.zero, // Remove default padding
                                            constraints: const BoxConstraints(), // Remove default min size
                                          ),
                                          Text('${message.likes}'),
                                        ],
                                      ),
                                      const SizedBox(width: 16), // Spacing between like/dislike
                                      // Dislike Button and Count
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.thumb_down,
                                              color: message.isDisliked ? Colors.red : Colors.blueGrey,
                                            ),
                                            onPressed: () => _toggleDislike(index),
                                            visualDensity: VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          Text('${message.dislikes}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Trailing now only contains the Reply button
                              trailing: IconButton(
                                icon: const Icon(Icons.reply, color: Colors.blueGrey),
                                onPressed: () {
                                  print('Reply to ${message.sender}');
                                },
                              ),
                              isThreeLine: true, // Set to true to ensure enough space for the subtitle
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Positioned(
              top: 12,
              left: 19,
              right: 19,
              child: SearchBar(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Search Bar Widget ---
class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose(){
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
                    onSubmitted: (value) {
                      print('Search query submitted: $value');
                    }
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF6CA89A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_circle, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// --- Bottom Navigation Bar Widget ---
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('Selected index: $_selectedIndex');
    });
  }

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
        children: [
          GestureDetector(
            onTap: () => _onItemTapped(0),
            child: Icon(
              Icons.home,
              size: 30,
              color: _selectedIndex == 0 ? Colors.tealAccent[100] : Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => _onItemTapped(1),
            child: Icon(
              Icons.bookmark,
              size: 30,
              color: _selectedIndex == 1 ? Colors.tealAccent[100] : Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => _onItemTapped(2),
            child: Icon(
              Icons.menu,
              size: 30,
              color: _selectedIndex == 2 ? Colors.tealAccent[100] : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
