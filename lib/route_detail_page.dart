import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapac/models/favorite_route.dart';

class RouteDetailPage extends StatefulWidget {
  final FavoriteRoute route;

  const RouteDetailPage({super.key, required this.route});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  LatLng _getCenter(LatLngBounds bounds) {
    return LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );
  }

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: const MarkerId('start'),
      position: widget.route.polylinePoints.first,
      infoWindow: InfoWindow(title: 'Start', snippet: widget.route.startAddress),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('end'),
      position: widget.route.polylinePoints.last,
      infoWindow: InfoWindow(title: 'End', snippet: widget.route.endAddress),
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    Future.delayed(const Duration(milliseconds: 150), () {
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(widget.route.bounds, 60));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _getCenter(widget.route.bounds),
              zoom: 12,
            ),
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                color: const Color(0xFF4A6FA5),
                points: widget.route.polylinePoints,
                width: 5,
              )
            },
            myLocationButtonEnabled: false,
          ),

          // DraggableScrollableSheet with Route Details
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
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
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Handle for dragging the sheet
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.route.routeName,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),
                          _buildRouteInfoRow(
                            icon: Icons.trip_origin,
                            title: "From",
                            content: widget.route.startAddress,
                          ),
                          const SizedBox(height: 15),
                          _buildRouteInfoRow(
                            icon: Icons.location_on,
                            title: "To",
                            content: widget.route.endAddress,
                          ),
                          const SizedBox(height: 15),
                          const Divider(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn("Distance", widget.route.distance),
                              _buildStatColumn("Duration", widget.route.duration),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildRouteInfoRow({required IconData icon, required String title, required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6CA89A), size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(content, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}