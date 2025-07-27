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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 2;

  File? _profileImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  // Remove these hardcoded color constants:
  // static const Color primaryColor = Color(0xFF4A6FA5);
  // static const Color contentBgColor = Colors.white;
  // static const Color deleteColor = Color(0xFFE97C7C);
  // static const Color accentColor = Color(0xFF6CA89A);

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
    // …other tabs…
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Get the current ColorScheme

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme background color
      body: SafeArea(child: _buildBody(colorScheme)), // Pass colorScheme to _buildBody
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) { // Accept colorScheme as parameter
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: colorScheme.onBackground)); // Use theme color for indicator
    }
    if (_currentUser == null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("User not logged in.",
              style: TextStyle(color: colorScheme.onBackground)), // Use theme color for text
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
        _buildHeader(colorScheme), // Pass colorScheme
        _buildInfoSection(colorScheme), // Pass colorScheme
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) { // Accept colorScheme as parameter
    ImageProvider<Object> avatar = _profileImageFile != null
        ? FileImage(_profileImageFile!)
        : (_currentUser!.profileImageUrl?.isNotEmpty == true
            ? NetworkImage(_currentUser!.profileImageUrl!)
            : const AssetImage('assets/logo.png')); // use your existing placeholder
    return Container(
      width: double.infinity,
      color: colorScheme.primary, // Use theme primary color for header background
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _currentUser!.email,
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 14), // Use onPrimary for text on primary background
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showEditEmailDialog(context, colorScheme), // Pass colorScheme
              child: Icon(Icons.edit,
                  color: colorScheme.onPrimary, size: 18), // Use onPrimary for icon on primary background
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _onProfilePicTap,
          child: CircleAvatar(
            radius: 52,
            backgroundColor: colorScheme.surface, // Use theme surface for avatar background
            backgroundImage: avatar,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _currentUser!.fullName,
          style: TextStyle(
              color: colorScheme.onPrimary, // Use onPrimary for text on primary background
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Daily Commuter',
          style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 14), // Use onPrimary for text
        ),
      ]),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme) { // Accept colorScheme as parameter
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface, // Use theme surface color for content background
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(
          children: [
            _infoRow(
              icon: Icons.person_outline,
              label: 'Full name',
              value: _currentUser!.fullName,
              valueColor: colorScheme.onSurface, // Text color on surface
              onTap: () => _showEditFullNameSheet(context, colorScheme), // Pass colorScheme
            ),
            Divider(color: colorScheme.outlineVariant), // Use theme divider color
            _infoRow(
              icon: Icons.transgender,
              label: 'Gender',
              value: _currentUser!.gender ?? 'Not provided',
              valueColor: colorScheme.onSurface, // Text color on surface
              onTap: () => _showEditGenderSheet(context, colorScheme), // Pass colorScheme
            ),
            Divider(color: colorScheme.outlineVariant), // Use theme divider color
            _infoRow(
              icon: Icons.cake_outlined,
              label: 'Date of Birth',
              value: _currentUser!.dateOfBirth ?? 'Not provided',
              valueColor: colorScheme.onSurface, // Text color on surface
              onTap: () => _showEditDOBDialog(context, colorScheme), // Pass colorScheme
            ),
            Divider(color: colorScheme.outlineVariant), // Use theme divider color
            _infoRow(
              icon: Icons.delete_outline,
              label: 'Delete account',
              value:
                  'All your data will be permanently removed',
              valueColor: colorScheme.error, // Use theme error color
              onTap: () => _confirmDeleteAccount(colorScheme), // Pass colorScheme
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor, // Make valueColor nullable if it might not be provided
    required VoidCallback onTap,
  }) {
    // Default valueColor if not provided
    valueColor = valueColor ?? Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24), // Use theme color for icons
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)), // Use theme color for label
                    const SizedBox(height: 4),
                    Text(value,
                        style: TextStyle(
                            fontSize: 14, color: valueColor)),
                  ]),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16), // Use theme color for arrow icon
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
          backgroundColor: Theme.of(ctx).colorScheme.surface, // Use theme surface color
          content: Text("Do you want to change your profile pic?", style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)), // Use onSurface for text
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


  Future<void> _showEditEmailDialog(BuildContext context, ColorScheme colorScheme) async { // Accept colorScheme
    final emailCtrl =
        TextEditingController(text: _currentUser!.email);
    final passwordCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: colorScheme.surface, // Use theme surface color
          title: Text("Change your email",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)), // Use onSurface for title
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "You will need to verify your account again after changing your email address. Please make sure it is correct.",
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)), // Use onSurfaceVariant for text
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                    labelText: "New Email",
                    labelStyle: TextStyle(color: colorScheme.onSurface), // Use onSurface for label
                    border: const OutlineInputBorder(),
                    fillColor: colorScheme.surfaceContainerHighest, // Use a container color for fill
                    filled: true,
                ),
                style: TextStyle(color: colorScheme.onSurface), // Text color in TextField
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: colorScheme.onSurface), // Use onSurface for label
                    border: const OutlineInputBorder(),
                    fillColor: colorScheme.surfaceContainerHighest, // Use a container color for fill
                    filled: true,
                ),
                style: TextStyle(color: colorScheme.onSurface), // Text color in TextField
              ),
              const SizedBox(height: 24),
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
                        backgroundColor: colorScheme.primary, // Use theme primary color
                        foregroundColor: colorScheme.onPrimary), // Use onPrimary for text color
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
          BuildContext context, ColorScheme colorScheme) async { // Accept colorScheme
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
            color: colorScheme.surface, // Use theme surface color
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
                      color: colorScheme.secondary, // Use theme secondary color
                      borderRadius:
                          BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text("Edit your data",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface)), // Use onSurface for text
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
                    backgroundColor: colorScheme.primary, // Use theme primary color
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
                        TextStyle(color: colorScheme.onPrimary)), // Use onPrimary for text
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

  Future<void> _showEditGenderSheet(BuildContext context, ColorScheme colorScheme) async { // Accept colorScheme
    String? choice = _currentUser!.gender;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx2, setSB) => Container(
            decoration: BoxDecoration(
              color: colorScheme.surface, // Use theme surface color
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(10))), // Use theme secondary
              const SizedBox(height: 16),
              Text("Please specify your gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)), // Use onSurface
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: Text("Male", style: TextStyle(color: colorScheme.onSurface)), // Use onSurface
                value: "Male",
                groupValue: choice,
                activeColor: colorScheme.primary, // Use theme primary
                onChanged: (v) => setSB(() => choice = v),
              ),
              RadioListTile<String>(
                title: Text("Female", style: TextStyle(color: colorScheme.onSurface)), // Use onSurface
                value: "Female",
                groupValue: choice,
                activeColor: colorScheme.primary, // Use theme primary
                onChanged: (v) => setSB(() => choice = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, minimumSize: const Size(double.infinity, 48)), // Use theme primary
                onPressed: () => Navigator.of(sheetCtx).pop(choice),
                child: Text("OK", style: TextStyle(color: colorScheme.onPrimary)), // Use onPrimary
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

  Future<void> _showEditDOBDialog(BuildContext context, ColorScheme colorScheme) async { // Accept colorScheme
    DateTime initial = DateTime.tryParse(_currentUser!.dateOfBirth ?? '') ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: colorScheme, // Pass the current colorScheme to DatePicker
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

  Future<void> _confirmDeleteAccount(ColorScheme colorScheme) async { // Accept colorScheme
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
            backgroundColor: colorScheme.surface, // Use theme surface color
            title: Text("Delete your Account?", style: TextStyle(color: colorScheme.error, fontSize: 18, fontWeight: FontWeight.bold)), // Use theme error color
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                "We’re really sorry to see you go. Are you sure you want to delete your account? Once you confirm, your data will be gone.",
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
              ),
              const SizedBox(height: 12),
              ...reasons.map((r) => RadioListTile<String>(
                    title: Text(r, style: TextStyle(fontSize: 13, color: colorScheme.onSurface)), // Use onSurface
                    value: r,
                    groupValue: reason,
                    onChanged: (v) => setSB(() => reason = v),
                    activeColor: colorScheme.primary, // Use theme primary
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