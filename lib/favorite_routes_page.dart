import 'package:flutter/material.dart';
import 'package:zapac/add_new_route_page.dart';
import 'package:zapac/models/favorite_route.dart'; // Import the new model
import 'package:zapac/route_detail_page.dart'; // Import the detail page

class FavoriteRoutesPage extends StatefulWidget {
  const FavoriteRoutesPage({super.key});

  @override
  State<FavoriteRoutesPage> createState() => _FavoriteRoutesPageState();
}

class _FavoriteRoutesPageState extends State<FavoriteRoutesPage> {
  // Use the new FavoriteRoute model
  final List<FavoriteRoute> _favoriteRoutes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4BE6C),
        elevation: 0,
        title: const Text('Favorite Routes',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined,
                color: Colors.black, size: 28),
            onPressed: () async {
              // Navigate and wait for a result
              final newRoute = await Navigator.push<FavoriteRoute>(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddNewRoutePage()),
              );

              // If a new route was returned, add it to the list
              if (newRoute != null && mounted) {
                setState(() {
                  _favoriteRoutes.add(newRoute);
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF4BE6C), // Background color from image
        child: _favoriteRoutes.isEmpty
            ? const Center(
                child: Text(
                  'You have no favorite routes yet.\nClick the + icon to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _favoriteRoutes.length,
                itemBuilder: (context, index) {
                  final route = _favoriteRoutes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(route.routeName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text('From: ${route.startAddress}',
                              overflow: TextOverflow.ellipsis),
                          Text('To: ${route.endAddress}',
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 5),
                          Text('${route.distance} (${route.duration})',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      onTap: () {
                        // Navigate to the detail page on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RouteDetailPage(route: route),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}