import 'package:flutter/material.dart';
import 'package:zapac/AuthManager.dart';
import 'package:zapac/User.dart';
import 'package:zapac/dashboard.dart';
import 'package:zapac/auth_screen.dart';
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

  static const Color primaryColor   = Color(0xFF4A6FA5);
  static const Color contentBgColor = Colors.white;
  static const Color deleteColor    = Color(0xFFE97C7C);
  static const Color accentColor    = Color(0xFF6CA89A);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {
        _currentUser = AuthManager().currentUser;
        _isLoading   = false;
      });
    });
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
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(child: _buildBody()),
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("User not logged in.", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (r) => false,
            ),
            child: const Text("Go to Login"),
          )
        ]),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildInfoSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _currentUser!.email,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showEditEmailDialog(context),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CircleAvatar(
          radius: 52,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(
            _currentUser!.profileImageUrl ??
            'https://i.pinimg.com/736x/a7/95/9b/a7959b661c47209214716938a11e8eda.jpg',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _currentUser!.fullName,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Daily Commuter',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ]),
    );
  }

  Widget _buildInfoSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: contentBgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Full name',
            value: _currentUser!.fullName,
            onTap: () => _showEditNameSheet(context),
          ),
          const Divider(),
          _buildInfoRow(
            icon: Icons.transgender,
            label: 'Gender',
            value: _currentUser!.gender ?? 'Not provided',
            onTap: () => _showEditGenderSheet(context),
          ),
          const Divider(),
          _buildInfoRow(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: _currentUser!.dateOfBirth ?? 'Not provided',
            onTap: () => _showEditDOBDialog(context),
          ),
          const Divider(),
          InkWell(
            onTap: () => _showDeleteAccountDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Icon(Icons.delete_outline, color: deleteColor),
                const SizedBox(width: 16),
                Text('Delete account', style: TextStyle(color: deleteColor, fontSize: 16)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ]),
      ),
    );
  }

  // ─── Dialog & Sheet Helpers ────────────────────────────────────────────────

 Future<void> _showEditEmailDialog(BuildContext context) async {
  final emailCtrl    = TextEditingController(text: _currentUser!.email);
  final passwordCtrl = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(
        "Change your email",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "You will need to verify your account again after changing your email address. Please make sure it is correct.",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: "New Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,   // your green
            foregroundColor: Colors.white,   // ensures white text
          ),
          onPressed: () {
            // TODO: update email in AuthManager / backend
            Navigator.of(ctx).pop();
          },
          child: const Text("Submit"),
        ),
      ],
    ),
  );
}

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    String? reason;
    final reasons = [
      "I am no longer using my account",
      "I don’t understand how to use it",
      "ZAPAC is not available in my city",
      "Other"
    ];
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSB) => AlertDialog(
          title: const Text("Delete your Account?", style: TextStyle(color: deleteColor, fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              "We’re really sorry to see you go. Are you sure you want to delete your account? Once you confirm, your data will be gone.",
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...reasons.map((r) => RadioListTile<String>(
                  title: Text(r, style: const TextStyle(fontSize: 13)),
                  value: r,
                  groupValue: reason,
                  onChanged: (v) => setSB(() => reason = v),
                )),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: deleteColor),
              onPressed: () {
                AuthManager().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (_) => false,
                );
              },
              child: const Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditNameSheet(BuildContext context) async {
    final firstCtrl  = TextEditingController(text: _currentUser!.firstName);
    final middleCtrl = TextEditingController(text: _currentUser!.middleName ?? '');
    final lastCtrl   = TextEditingController(text: _currentUser!.lastName);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                const Text("Edit your data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: "First name", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: "Last name", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: middleCtrl, decoration: const InputDecoration(labelText: "Middle name", border: OutlineInputBorder())),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor, minimumSize: const Size(double.infinity, 48)),
                  onPressed: () => Navigator.of(sheetCtx).pop({
                    'first': firstCtrl.text.trim(),
                    'middle': middleCtrl.text.trim(),
                    'last': lastCtrl.text.trim(),
                  }),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ]),
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _currentUser!
          ..firstName  = result['first']!
          ..middleName = result['middle']
          ..lastName   = result['last']!;
      });
      await AuthManager().updateUser(_currentUser!);
    }
  }

  Future<void> _showEditGenderSheet(BuildContext context) async {
    String? choice = _currentUser!.gender;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx2, setSB) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              const Text("Please specify your gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: const Text("Male"),
                value: "Male",
                groupValue: choice,
                activeColor: primaryColor,
                onChanged: (v) => setSB(() => choice = v),
              ),
              RadioListTile<String>(
                title: const Text("Female"),
                value: "Female",
                groupValue: choice,
                activeColor: primaryColor,
                onChanged: (v) => setSB(() => choice = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor, minimumSize: const Size(double.infinity, 48)),
                onPressed: () => Navigator.of(sheetCtx).pop(choice),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
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

  Future<void> _showEditDOBDialog(BuildContext context) async {
    DateTime initial = DateTime.tryParse(_currentUser!.dateOfBirth ?? '') ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      final dobStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _currentUser!.dateOfBirth = dobStr;
      });
      await AuthManager().updateUser(_currentUser!);
    }
  }
}