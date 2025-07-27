import 'package:flutter/material.dart';
import 'package:zapac/bottom_navbar.dart';
import 'package:zapac/dashboard.dart';
import 'package:zapac/favorite_routes_page.dart';
import 'package:zapac/profile_page.dart';
import 'main.dart'; // Import main.dart to access themeNotifier
import 'package:zapac/AuthManager.dart'; // Import AuthManager
import 'package:zapac/auth_screen.dart'; // Import AuthScreen for navigation

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // User details (replace with actual user data from your AuthManager or a user model)
  final String _userEmail = 'charisjmn@gmail.com';
  final String _userName = 'Charisse Jamien T';
  final String _userStatus = 'Daily Commuter';
  final String _userProfileImageUrl = 'https://plus.unsplash.com/premium_vector-1744196876628-cdd656d88ed3?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=500&h=500&fit=crop';

  static const Color primaryColor = Color(0xFF4A6FA5);
  static const Color greenButtonColor = Color(0xFF6CA89A);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Read the current theme mode from the notifier
    final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme colors
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor, // Use theme colors
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header section (user profile)
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor, // Use theme colors
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  _userEmail,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                const SizedBox(height: 15),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundImage: NetworkImage(_userProfileImageUrl),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _userStatus,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 15),
                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          // Settings options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSettingsTile(
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: isDarkMode, // Use the actual theme mode
                    onChanged: (value) {
                      themeNotifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      // No need for setState here if themeNotifier rebuilds the MaterialApp
                    },
                    activeColor: greenButtonColor,
                  ),
                ),
                _buildSettingsTile(
                  title: 'Share our app',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share app functionality coming soon!')),
                    );
                  },
                ),
                // NEW: Logout ListTile
                _buildSettingsTile(
                  title: 'Logout',
                  onTap: () {
                    AuthManager().logout(); // Call the logout method from AuthManager
                    // Navigate back to the authentication screen and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (Route<dynamic> route) => false, // This condition removes all routes from the stack
                    );
                  },
                  trailing: Icon(Icons.logout, color: Theme.of(context).iconTheme.color), // Optional: Add a logout icon
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2, // Assuming settings is the third item (index 2)
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoriteRoutesPage()),
            );
          } else if (index == 3) { // Profile Page index, if your nav bar has 4 items
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
          // The settings page itself is already active at index 2, so no navigation needed for index 2
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color), // Use theme text color
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }
}