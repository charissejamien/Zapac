import 'package:flutter/material.dart';
import 'package:zapac/add_new_route_page.dart';
import 'package:zapac/models/favorite_route.dart';
import 'package:zapac/route_detail_page.dart';
import 'package:zapac/data/favorite_routes_data.dart';
import 'bottom_navbar.dart'; // Import the BottomNavBar
import 'dashboard.dart';    // Import Dashboard
import 'settings_page.dart'; // Import SettingsPage

class FavoriteRoutesPage extends StatefulWidget {
  const FavoriteRoutesPage({super.key});

  @override
  State<FavoriteRoutesPage> createState() => _FavoriteRoutesPageState();
}

class _FavoriteRoutesPageState extends State<FavoriteRoutesPage> {
  final List<FavoriteRoute> _favoriteRoutes = favoriteRoutes;

  @override
  Widget build(BuildContext context) {
    // Determine colors based on the current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color appBarColor = isDarkMode ? Colors.grey[850]! : const Color(0xFF4A6FA5);
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color iconColor = isDarkMode ? Colors.white : Colors.black; // Ensure icon color is visible

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor, // Use theme-dependent color
        elevation: 0,
        title: Text(
          'Favorite Routes',
          style: TextStyle(color: Colors.white), // AppBar title always white for contrast
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Make back button white
        actions: [
          IconButton(
            icon: Icon(Icons.add_location_alt_outlined, color: iconColor, size: 28), // Use theme-dependent icon color
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddNewRoutePage()),
              );
              setState(() {
                // This will rebuild the list with any new routes.
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor, // Use theme background color
        child: _favoriteRoutes.isEmpty
            ? Center(
                child: Text(
                  'You have no favorite routes yet.\nClick the + icon to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: textColor), // Use theme text color
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
                    color: Theme.of(context).cardColor, // Use theme card color
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        route.routeName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme text color
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'From: ${route.startAddress}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // Use theme text color
                          ),
                          Text(
                            'To: ${route.endAddress}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // Use theme text color
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${route.distance} (${route.duration})',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      onTap: () {
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1, // Set selectedIndex to 1 for Favorite Routes
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }
          // No need to navigate if index is 1 (current page)
        },
      ),
    );
  }
}