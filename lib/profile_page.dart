import 'package:flutter/material.dart';
import 'dashboard.dart'; // Make sure this import is present for BottomNavBar

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary color from your design for easy reuse.
    const Color primaryColor = Color(0xFF4A6FA5);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          _buildHeader(primaryColor),
          _buildInfoSection(),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(), // <-- Added here
    );
  }

  /// Builds the top blue header section of the profile.
  Widget _buildHeader(Color primaryColor) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email address with an edit icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'kerropiandcinnamon@gmail.com',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 20),

          // Profile picture with a white border
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white, // This creates the white border
            child: const CircleAvatar(
              radius: 52,
              // Replace with your actual image asset or network image
              backgroundImage: NetworkImage('https://i.pinimg.com/736x/a7/95/9b/a7959b661c47209214716938a11e8eda.jpg'),
            ),
          ),
          const SizedBox(height: 15),

          // User name
          const Text(
            'Kerropi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 5),

          // User subtitle
          const Text(
            'Daily Commuter',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom white section with user information.
  Widget _buildInfoSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          // If you want rounded corners at the top:
          // borderRadius: BorderRadius.only(
          //   topLeft: Radius.circular(30),
          //   topRight: Radius.circular(30),
          // ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Full name',
                value: 'Kerropi P. Kokak',
              ),
              SizedBox(height: 15),
              _InfoRow(
                icon: Icons.transgender, // Using a representative icon for gender
                label: 'Gender',
                value: 'Not provided',
              ),
              SizedBox(height: 15),
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'Date of Birth',
                value: 'Not provided',
              ),
              SizedBox(height: 15),
              // Special row for the delete account action
              _InfoRow(
                icon: Icons.delete_outline,
                value: 'Delete account',
                valueColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable widget for displaying a row of information (icon, label, value).
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String? label; // Label is optional for the "Delete account" case
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    this.label,
    required this.value,
    this.valueColor = Colors.black, // Default color is black
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only show the label if it's not null
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                // Add a little space if there is a label
                if (label != null) const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 16,
                    fontWeight: label != null ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}