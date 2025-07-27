import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapac/models/favorite_route.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:zapac/favorite_routes_page.dart';

class RouteDetailPage extends StatefulWidget {
  final FavoriteRoute route;

  const RouteDetailPage({super.key, required this.route});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

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

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: Theme.of(context).colorScheme.primary,
        points: widget.route.polylinePoints,
        width: 5,
      )
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    Future.delayed(const Duration(milliseconds: 150), () {
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(widget.route.bounds, 60));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final Color sheetBackgroundColor = theme.cardColor;
    final Color textColor = cs.onSurface;
    final Color handleColor = cs.onSurface.withOpacity(0.4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 0,
        leading: BackButton(
          color: cs.onPrimary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.route.routeName,
          style: TextStyle(
            color: cs.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _getCenter(widget.route.bounds),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.15,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: sheetBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: handleColor,
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
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 10),
                            Divider(color: cs.onSurface.withOpacity(0.12)),
                            const SizedBox(height: 10),
                            _buildRouteInfoRow(
                              icon: Icons.trip_origin,
                              title: "From",
                              content: widget.route.startAddress,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 15),
                            _buildRouteInfoRow(
                              icon: Icons.location_on,
                              title: "To",
                              content: widget.route.endAddress,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 15),
                            Divider(color: cs.onSurface.withOpacity(0.12)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn("Distance", widget.route.distance, textColor),
                                _buildStatColumn("Duration", widget.route.duration, textColor),
                                _buildStatColumn("Estimated Fare", widget.route.estimatedFare, textColor),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildRouteInfoRow({required IconData icon, required String title, required String content, required Color textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
              Text(content, style: TextStyle(fontSize: 16, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }
}