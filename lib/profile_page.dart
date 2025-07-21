import 'package:flutter/material.dart';
import 'dashboard.dart'; // Remove this line
import 'bottom_navbar.dart'; // Add this line to directly import BottomNavBar
import 'auth_screen.dart'; // Import your login screen file

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- your profile state
  String _firstName = 'Kerropi';
  String _middleName = 'P.';
  String _lastName = 'Kokak';
  String _email = 'kerropiandcinnamon@gmail.com';

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  // --- your brand colors
  static const Color primaryColor = Color(0xFF4A6FA5);
  static const Color accentYellow = Color(0xFFFFD700);
  static const Color orangeLineColor = Color(0xFFF4BE6C);
  static const Color greenButtonColor = Color(0xFF6CA89A);
  static const Color coralRed = Color(0xFFE97C7C);

  // Add a state variable for the selected index of the BottomNavBar
  int _selectedIndex = 0; // Default to the first tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here based on the index
    if (index == 0) {
      // Assuming index 0 is the Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
    // You can add more navigation logic for other indices as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(children: [_buildHeader(), _buildInfoSection(context)]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildHeader() {
    final fullName =
        '$_firstName ${_middleName.isNotEmpty ? '$_middleName ' : ''}$_lastName';
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () => _showChangeEmailDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit, color: Colors.white, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage(
                'https://i.pinimg.com/736x/a7/95/9b/a7959b661c47209214716938a11e8eda.jpg',
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Daily Commuter',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            _TappableInfoRow(
              icon: Icons.person_outline,
              label: 'Full name',
              value: '$_firstName $_middleName $_lastName',
              onTap: () => _showEditFullNameSheet(context),
            ),
            const SizedBox(height: 15),
            _TappableInfoRow(
              icon: Icons.transgender,
              label: 'Gender',
              value: _selectedGender ?? 'Not provided',
              onTap: () => _showGenderSelectionDialog(context),
            ),
            const SizedBox(height: 15),
            _TappableInfoRow(
              icon: Icons.cake_outlined,
              label: 'Date of Birth',
              value: _selectedDateOfBirth == null
                  ? 'Not provided'
                  : '${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.year}',
              onTap: () => _selectDateOfBirth(context),
            ),
            const SizedBox(height: 15),
            // wrap your existing red row in an InkWell
            InkWell(
              onTap: () => _showDeleteAccountDialog(context),
              child: const _InfoRow(
                icon: Icons.delete_outline,
                value: 'Delete account',
                valueColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ——————— Change Email dialog (as before) ———————
  void _showChangeEmailDialog(BuildContext context) {
    final newEmailController = TextEditingController(text: _email);
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change your email',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You will need to verify account again after changing your email address. Please make sure it is correct.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: newEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: coralRed,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() => _email = newEmailController.text.trim());
                        Navigator.of(ctx).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: greenButtonColor,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ——————— Delete Account dialog ———————
  void _showDeleteAccountDialog(BuildContext context) {
    String? reason;
    final options = [
      'I am no longer using my account',
      'I don’t understand how to use',
      'ZAPAC is not available in my city',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (ctx2, setState2) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete your Account?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: coralRed,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We’re really sorry to see you go. Are you sure you want to delete your account? Once you confirm, your data will be gone.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),

                  // radio options
                  ...options.map((opt) {
                    return RadioListTile<String>(
                      title: Text(
                        opt,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      value: opt,
                      groupValue: reason,
                      activeColor: coralRed,
                      onChanged: (val) => setState2(() => reason = val),
                      contentPadding: EdgeInsets.zero,
                    );
                  }),

                  const SizedBox(height: 24),
                  // delete button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // TODO: call your delete-account API, then:
                        // Navigator.of(ctx).pop(); // Remove this line
                        Navigator.pushAndRemoveUntil(
                          // Add this line
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthScreen(),
                          ), // Replace LoginScreen() with your actual login page widget
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: coralRed,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ——————— Full name bottom sheet (unchanged) ———————
  void _showEditFullNameSheet(BuildContext context) async {
    final firstCtrl = TextEditingController(text: _firstName);
    final middleCtrl = TextEditingController(text: _middleName);
    final lastCtrl = TextEditingController(text: _lastName);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: orangeLineColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Text(
                'Edit your data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildNameTextField(
                controller: firstCtrl,
                labelText: 'First name',
              ),
              const SizedBox(height: 15),
              _buildNameTextField(
                controller: middleCtrl,
                labelText: 'Middle name',
              ),
              const SizedBox(height: 15),
              _buildNameTextField(controller: lastCtrl, labelText: 'Last name'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetCtx).pop({
                    'first': firstCtrl.text.trim(),
                    'middle': middleCtrl.text.trim(),
                    'last': lastCtrl.text.trim(),
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _firstName = result['first']!;
        _middleName = result['middle']!;
        _lastName = result['last']!;
      });
    }
    // controllers get GC’d automatically
  }

  Widget _buildNameTextField({
    required TextEditingController controller,
    required String labelText,
  }) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );

  // ——————— Gender sheet & Date picker (unchanged) ———————
  void _showGenderSelectionDialog(BuildContext context) {
    String? temp = _selectedGender;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx2, setState2) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: orangeLineColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const Text(
                  'Please specify your gender',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                RadioListTile<String>(
                  title: const Text('Male'),
                  value: 'Male',
                  groupValue: temp,
                  activeColor: accentYellow,
                  onChanged: (v) => setState2(() => temp = v),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  title: const Text('Female'),
                  value: 'Female',
                  groupValue: temp,
                  activeColor: accentYellow,
                  onChanged: (v) => setState2(() => temp = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (temp != null) {
                          setState(() => _selectedGender = temp);
                          Navigator.of(sheetCtx).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          primaryColor: primaryColor,
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }
}

/// Static info row (used for Delete account)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    this.label,
    required this.value,
    this.valueColor = Colors.black,
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
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                if (label != null) const SizedBox(height: 2),
                Text(value, style: TextStyle(color: valueColor, fontSize: 16)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}

/// Tappable info row (Full name, Gender, DOB)
class _TappableInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TappableInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600]),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
