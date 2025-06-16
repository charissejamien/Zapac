import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late GoogleMapController _mapController;

  // Default center: Cebu City
  static const LatLng _initialPosition = LatLng(10.3157, 123.8854);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bottom nav stays pinned above everything
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
        child: Stack(
          children: [
            // 1) Full‐screen map
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _initialPosition,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                zoomControlsEnabled: false,
              ),
            ),

            // 2) Search bar overlay on top
            const Positioned(
              top: 12,
              left: 19,
              right: 19,
              child: _SearchBar(),
            ),

            // 3) Slide‐up chat panel
            DraggableScrollableSheet(
              initialChildSize: 0.30,
              minChildSize: 0.10,
              maxChildSize: 0.80,
              builder: (context, scrollController) {
                return Container(
                  // the white background for the sheet
                  color: const Color(0xFFF9F9F9),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 1 + 10, // 1 for yellow handle, then messages
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Yellow curved handle
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
          ],
        ),
      ),
    );
  }
}

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