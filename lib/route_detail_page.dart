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

  // This helper function calculates the center of the route's bounds.
  LatLng _getCenter(LatLngBounds bounds) {
    return LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );
  }

  @override
  void initState() {
    super.initState();
    // Add markers for the start and end points of the route
    _markers.add(Marker(
      markerId: const MarkerId('start'),
      position: widget.route.polylinePoints.first,
      infoWindow:
          InfoWindow(title: 'Start', snippet: widget.route.startAddress),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('end'),
      position: widget.route.polylinePoints.last,
      infoWindow: InfoWindow(title: 'End', snippet: widget.route.endAddress),
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Animate the camera to fit the entire route on the screen
    Future.delayed(const Duration(milliseconds: 200), () {
      _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(widget.route.bounds, 60));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.routeName),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          // Here we use the helper function to fix the error
          target: _getCenter(widget.route.bounds),
          zoom: 12,
        ),
        markers: _markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            points: widget.route.polylinePoints,
            width: 5,
          )
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.route.routeName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Distance: ${widget.route.distance}'),
            Text('Duration: ${widget.route.duration}'),
          ],
        ),
      ),
    );
  }
}