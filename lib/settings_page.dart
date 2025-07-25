import 'package:flutter/material.dart';
import 'package:zapac/bottom_navbar.dart';
import 'package:zapac/dashboard.dart';
import 'package:zapac/favorite_routes_page.dart';
import 'package:zapac/profile_page.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State for Dark Mode toggle
  bool _isDarkMode = false; // You would link this to actual theme management

  // User details (replace with actual user data from your AuthManager or a user model)
  final String _userEmail = 'kerropiandcinnamon@gmail.com';
  final String _userName = 'Kerropi';
  final String _userStatus = 'Daily Commuter';
  final String _userProfileImageUrl = 'https://i.pinimg.com/736x/a7/95/9b/a7959b661c47209214716938a11e8eda.jpg'; // Placeholder image

  // Define your colors based on existing themes in your project
  static const Color primaryColor = Color(0xFF4A6FA5); // Found in other files
  static const Color greenButtonColor = Color(0xFF6CA89A); // Found in other files

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background for the settings page
      appBar: AppBar(
        backgroundColor: primaryColor, // Consistent with your app bar color
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header section (user profile)
          Container(
            width: double.infinity,
            color: primaryColor,
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
                    // Navigate to profile editing page or show a dialog
                    // For now, let's navigate to the existing ProfilePage
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
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                        // Implement your theme switching logic here
                      });
                    },
                    activeColor: greenButtonColor,
                  ),
                ),
                _buildSettingsTile(
                  title: 'Share our app',
                  onTap: () {
                    // Implement share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share app functionality coming soon!')),
                    );
                  },
                ),
                // Add more settings options as needed
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2, // Highlight the menu icon
        onItemTapped: (index) {
          // Handle navigation from bottom bar if needed, or keep it simple.
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
          }
          // No action needed if index is 2 (SettingsPage) as we are already here.
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
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }
}