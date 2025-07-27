// lib/profile_page.dart

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zapac/AuthManager.dart';
import 'package:zapac/User.dart';
import 'package:zapac/auth_screen.dart';
import 'package:zapac/dashboard.dart';
import 'bottom_navbar.dart';
import 'main.dart'; // Import main.dart to access themeNotifier if still used there

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 2; // Assuming Profile is index 2 in your BottomNavBar

  File? _profileImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  Future<void> _initProfile() async {
    _currentUser = AuthManager().currentUser;
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_pic_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      _profileImageFile = File(savedPath);
    } else {
      _profileImageFile = null; // fallback to NetworkImage or AssetImage
    }
    setState(() => _isLoading = false);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    }
    // Handle other tabs as per your BottomNavBar setup
    // Example:
    // else if (index == 1) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const FavoriteRoutesPage()),
    //   );
    // } else if (index == 3) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const SettingsPage()),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea( // SafeArea handles system intrusions
        child: _buildBody(colorScheme)
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: colorScheme.onBackground));
    }
    if (_currentUser == null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("User not logged in.",
              style: TextStyle(color: colorScheme.onBackground)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context)
                .pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const AuthScreen()),
                    (r) => false),
            child: const Text("Go to Login"),
          )
        ]),
      );
    }

    return Column(
      children: [
        _buildHeader(colorScheme), // This takes fixed vertical space
        // Expanded ensures the remaining space is given to the ListView for scrolling
        Expanded(
          child: _buildInfoSection(colorScheme),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    ImageProvider<Object> avatar = _profileImageFile != null
        ? FileImage(_profileImageFile!)
        : (_currentUser!.profileImageUrl?.isNotEmpty == true
            ? NetworkImage(_currentUser!.profileImageUrl!)
            : const AssetImage('assets/logo.png'));

    return Container(
      width: double.infinity,
      color: colorScheme.primary,
      // MODIFIED: Reduced vertical padding for the header
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Reduced from 20
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible( // Use Flexible to prevent overflow of email
                child: Text(
                  _currentUser!.email,
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 13), // Reduced font size
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // Reduced spacing
              GestureDetector(
                onTap: () => _showEditEmailDialog(context, colorScheme),
                child: Icon(Icons.edit, color: colorScheme.onPrimary, size: 16), // Reduced icon size
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced spacing
          GestureDetector(
            onTap: _onProfilePicTap,
            child: CircleAvatar(
              radius: 40, // Reduced avatar radius from 52
              backgroundColor: colorScheme.surface,
              backgroundImage: avatar,
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing
          Text(
            _currentUser!.fullName,
            style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 20, // Reduced font size from 22
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2), // Reduced spacing
          Text(
            'Daily Commuter',
            style: TextStyle(
                color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 13), // Reduced font size
          ),
          const SizedBox(height: 10), // Reduced spacing
          // Edit Profile Button
          ElevatedButton(
            onPressed: () {
              // This button already exists and navigates to ProfilePage itself, which is redundant.
              // It should probably just close this settings view or handle an actual edit flow.
              // For now, removing redundant navigation. The overall ProfilePage is what they're editing.
              // If you want a *separate* edit profile screen, you would navigate there.
              // Assuming this button is for editing the current profile data displayed.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6CA89A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Reduced padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Slightly reduced border radius
              ),
              textStyle: const TextStyle(fontSize: 13), // Reduced button text font size
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // MODIFIED: Reduced vertical padding for the info section content
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced from 24/16
      child: ListView(
        // The ListView inside Expanded should handle its own scrolling.
        // It should not contribute to the parent Column's overflow.
        // The problem is likely the space taken by its parent's siblings.
        children: [
          _infoRow(
            icon: Icons.person_outline,
            label: 'Full name',
            value: _currentUser!.fullName,
            valueColor: colorScheme.onSurface,
            onTap: () => _showEditFullNameSheet(context, colorScheme),
          ),
          Divider(color: colorScheme.outlineVariant),
          _infoRow(
            icon: Icons.transgender,
            label: 'Gender',
            value: _currentUser!.gender ?? 'Not provided',
            valueColor: colorScheme.onSurface,
            onTap: () => _showEditGenderSheet(context, colorScheme),
          ),
          Divider(color: colorScheme.outlineVariant),
          _infoRow(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: _currentUser!.dateOfBirth ?? 'Not provided',
            valueColor: colorScheme.onSurface,
            onTap: () => _showEditDOBDialog(context, colorScheme),
          ),
          Divider(color: colorScheme.outlineVariant),
          _infoRow(
            icon: Icons.delete_outline,
            label: 'Delete account',
            value: 'All your data will be permanently removed',
            valueColor: colorScheme.error,
            onTap: () => _confirmDeleteAccount(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required VoidCallback onTap,
  }) {
    valueColor = valueColor ?? Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        // MODIFIED: Reduced vertical padding for each info row
        padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 12
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22), // Slightly smaller icon
            const SizedBox(width: 12), // Reduced spacing
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)), // Reduced font size
                    const SizedBox(height: 2), // Reduced spacing
                    Text(value,
                        style: TextStyle(
                            fontSize: 13, color: valueColor)), // Reduced font size
                  ]),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant, size: 14), // Slightly smaller icon
          ],
        ),
      ),
    );
  }


  Future<void> _onProfilePicTap() async {
    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          content: Text("Do you want to change your profile pic?", style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Yes"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        );
      },
    );
    if (should == true) {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() => _profileImageFile = file);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_pic_path', file.path);
        // TODO: Upload logic here once backend is ready
      }
    }
  }


  Future<void> _showEditEmailDialog(BuildContext context, ColorScheme colorScheme) async {
    final emailCtrl =
        TextEditingController(text: _currentUser!.email);
    final passwordCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text("Change your email",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "You will need to verify your account again after changing your email address. Please make sure it is correct.",
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                    labelText: "New Email",
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    border: const OutlineInputBorder(),
                    fillColor: colorScheme.surfaceContainerHighest,
                    filled: true,
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    border: const OutlineInputBorder(),
                    fillColor: colorScheme.surfaceContainerHighest,
                    filled: true,
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Cancel"),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(ctx).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary),
                    onPressed: () async {
                      final newEmail = emailCtrl.text.trim();
                      final newPassword = passwordCtrl.text;
                      final updatedUser = User(
                        email: newEmail,
                        password: newPassword,
                        firstName: _currentUser!.firstName,
                        lastName: _currentUser!.lastName,
                        middleName: _currentUser!.middleName,
                        profileImageUrl: _currentUser!.profileImageUrl,
                        type: _currentUser!.type,
                        currentLocation: _currentUser!.currentLocation,
                        gender: _currentUser!.gender,
                        dateOfBirth: _currentUser!.dateOfBirth,
                      );
                      await AuthManager().updateUser(updatedUser);
                      setState(() { _currentUser = updatedUser; });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ],
          ),
          actions: [],
        );
      },
    );
  }

  Future<void> _showEditFullNameSheet(
          BuildContext context, ColorScheme colorScheme) async {
    final firstCtrl =
        TextEditingController(text: _currentUser!.firstName);
    final middleCtrl =
        TextEditingController(text: _currentUser!.middleName ?? '');
    final lastCtrl =
        TextEditingController(text: _currentUser!.lastName);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20)),
          ),
          padding:
              const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius:
                          BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text("Edit your data",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface)),
              const SizedBox(height: 16),
              TextField(
                  controller: firstCtrl,
                  decoration: InputDecoration(
                      labelText: "First name",
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      border: const OutlineInputBorder(),
                      fillColor: colorScheme.surfaceContainerHighest,
                      filled: true,
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: lastCtrl,
                  decoration: InputDecoration(
                      labelText: "Last name",
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      border: const OutlineInputBorder(),
                      fillColor: colorScheme.surfaceContainerHighest,
                      filled: true,
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: middleCtrl,
                  decoration: InputDecoration(
                      labelText: "Middle name",
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      border: const OutlineInputBorder(),
                      fillColor: colorScheme.surfaceContainerHighest,
                      filled: true,
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    minimumSize:
                        const Size(double.infinity, 48)),
                onPressed: () =>
                    Navigator.of(sheetCtx).pop({
                  'first': firstCtrl.text.trim(),
                  'middle': middleCtrl.text.trim(),
                  'last': lastCtrl.text.trim(),
                }),
                child: Text("OK",
                    style:
                        TextStyle(color: colorScheme.onPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _currentUser!
          ..firstName = result['first']!
          ..middleName = result['middle']
          ..lastName = result['last']!;
      });
      await AuthManager().updateUser(_currentUser!);
    }
  }

  Future<void> _showEditGenderSheet(BuildContext context, ColorScheme colorScheme) async {
    String? choice = _currentUser!.gender;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx2, setSB) => Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text("Please specify your gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: Text("Male", style: TextStyle(color: colorScheme.onSurface)),
                value: "Male",
                groupValue: choice,
                activeColor: colorScheme.primary,
                onChanged: (v) => setSB(() => choice = v),
              ),
              RadioListTile<String>(
                title: Text("Female", style: TextStyle(color: colorScheme.onSurface)),
                value: "Female",
                groupValue: choice,
                activeColor: colorScheme.primary,
                onChanged: (v) => setSB(() => choice = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, minimumSize: const Size(double.infinity, 48)),
                onPressed: () => Navigator.of(sheetCtx).pop(choice),
                child: Text("OK", style: TextStyle(color: colorScheme.onPrimary)),
              ),
            ]),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _currentUser!.gender = result;
      });
      await AuthManager().updateUser(_currentUser!);
    }
  }

  Future<void> _showEditDOBDialog(BuildContext context, ColorScheme colorScheme) async {
    DateTime initial = DateTime.tryParse(_currentUser!.dateOfBirth ?? '') ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: colorScheme,
            // You might need to adjust other date picker specific colors here if necessary
            // e.g., textTheme for header, etc.
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final dobStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _currentUser!.dateOfBirth = dobStr;
      });
      await AuthManager().updateUser(_currentUser!);
    }
  }

  Future<void> _confirmDeleteAccount(ColorScheme colorScheme) async {
    String? reason;
    final reasons = [
      "I am no longer using my account",
      "I don’t understand how to use it",
      "ZAPAC is not available in my city",
      "Other"
    ];
    await showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx2, setSB) => AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text("Delete your Account?", style: TextStyle(color: colorScheme.error, fontSize: 18, fontWeight: FontWeight.bold)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                "We’re really sorry to see you go. Are you sure you want to delete your account? Once you confirm, your data will be gone.",
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              ...reasons.map((r) => RadioListTile<String>(
                    title: Text(r, style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
                    value: r,
                    groupValue: reason,
                    onChanged: (v) => setSB(() => reason = v),
                    activeColor: colorScheme.primary,
                  )),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(),
                onPressed: () {
                  AuthManager().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (_) => false,
                  );
                },
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Theme.of(ctx).brightness == Brightness.dark
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
