import 'package:flutter/material.dart';
import 'package:zapac/AuthManager.dart';
import 'package:zapac/User.dart';
import 'dashboard.dart';
import 'bottom_navbar.dart';
import 'auth_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // This will hold the logged-in user's data.
  User? _currentUser;
  bool _isLoading = true; // To handle loading state

  // --- Brand Colors ---
  static const Color primaryColor = Color(0xFF4A6FA5);
  static const Color greenButtonColor = Color(0xFF6CA89A);
  static const Color coralRed = Color(0xFFE97C7C);

  // Default to the profile tab index (e.g., 2)
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Safely load user data from AuthManager
  void _loadUserData() {
  Future.microtask(() {
    if (mounted) {
      print('[ProfilePage] Loading user. AuthManager says current user is: ${AuthManager().currentUser?.email}');
      
      setState(() {
        _currentUser = AuthManager().currentUser;
        _isLoading = false;
      });
    }
  });
}

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
    // Add other cases for your nav bar items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("User not logged in.", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("Go to Login"),
            )
          ],
        ),
      );
    }

    return Column(children: [_buildHeader(), _buildInfoSection(context)]);
  }

  // --- Header Section ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage(
                _currentUser!.profileImageUrl ?? 'https://i.pinimg.com/736x/a7/95/9b/a7959b661c47209214716938a11e8eda.jpg',
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _currentUser!.fullName,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Daily Commuter',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- Editable Info Section ---
  Widget _buildInfoSection(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _currentUser!.email,
                onTap: () { /* Implement email change dialog */ },
              ),
              const SizedBox(height: 15),
              _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Full name',
                value: _currentUser!.fullName,
                onTap: () => _showEditFullNameSheet(context),
              ),
              const SizedBox(height: 15),
              _buildInfoRow(
                icon: Icons.delete_outline,
                label: 'Delete Account',
                value: 'All your data will be permanently removed',
                onTap: () => _showDeleteAccountDialog(context),
                valueColor: coralRed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dialogs and Bottom Sheets ---

  void _showEditFullNameSheet(BuildContext context) async {
    // Pre-fill text fields with current user data
    final firstCtrl = TextEditingController(text: _currentUser!.firstName);
    final middleCtrl = TextEditingController(text: _currentUser!.middleName ?? '');
    final lastCtrl = TextEditingController(text: _currentUser!.lastName);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Full Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: firstCtrl, decoration: InputDecoration(labelText: 'First Name')),
              const SizedBox(height: 15),
              TextField(controller: middleCtrl, decoration: InputDecoration(labelText: 'Middle Name (Optional)')),
              const SizedBox(height: 15),
              TextField(controller: lastCtrl, decoration: InputDecoration(labelText: 'Last Name')),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.of(sheetCtx).pop({
                      'first': firstCtrl.text.trim(),
                      'middle': middleCtrl.text.trim(),
                      'last': lastCtrl.text.trim(),
                    });
                  },
                   style: ElevatedButton.styleFrom(
                    backgroundColor: greenButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );

    // *** THIS IS THE KEY FIX ***
    if (result != null && mounted) {
      setState(() {
        // Instead of creating a new User, we MODIFY the existing one.
        _currentUser!.firstName = result['first']!;
        _currentUser!.middleName = result['middle']; // Can be null
        _currentUser!.lastName = result['last']!;
      });
      // In a real app, you would now save the updated _currentUser object to your database
      // await AuthManager().updateUser(_currentUser!);
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action is irreversible. All your data will be permanently lost.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: coralRed),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Dismiss the dialog first
              AuthManager().logout();
              if (mounted) {
                 Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (Route<dynamic> route) => false,
                 );
              }
            },
          ),
        ],
      ),
    );
  }
}

// --- Reusable Info Row Widget ---
Widget _buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
  required VoidCallback onTap,
  Color valueColor = Colors.black,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(fontSize: 16, color: valueColor, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
           const SizedBox(height: 15),
           const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        ],
      ),
    ),
  );
}