import 'package:flutter/material.dart';
import 'dashboard.dart'; // Make sure this import is present for BottomNavBar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // TextEditingController for the full name field
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController; // Controller for displaying email

  // State variables for gender and date of birth
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  // No _isEmailEditing needed here anymore for the header email

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: 'Kerropi P. Kokak');
    _emailController = TextEditingController(text: 'kerropiandcinnamon@gmail.com');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFF4A6FA5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor),
            _buildInfoSection(context),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email address - now only tappable to open the change email dialog
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _showChangeEmailDialog(context); // Call the new dialog method
                },
                child: Text(
                  _emailController.text,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.edit, // Always show edit icon, tapping opens dialog
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Profile picture with a white border
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: const CircleAvatar(
              radius: 52,
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

  Widget _buildInfoSection(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              _EditableInfoRow(
                icon: Icons.person_outline,
                label: 'Full name',
                value: _fullNameController.text,
                controller: _fullNameController,
                onChanged: (newValue) {
                  // Save new name logic
                },
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
              const _InfoRow(
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

  // New method for changing email securely
  void _showChangeEmailDialog(BuildContext context) {
    // Declare controllers as local variables within the method
    final TextEditingController oldEmailInputController = TextEditingController(text: _emailController.text);
    final TextEditingController newEmailInputController = TextEditingController();
    final TextEditingController codeInputController = TextEditingController();
    bool codeSent = false;
    String? errorMessage; // To display error messages in the dialog

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Change Email'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    TextField(
                      controller: oldEmailInputController,
                      decoration: const InputDecoration(
                        labelText: 'Old Email',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: newEmailInputController,
                      decoration: const InputDecoration(
                        labelText: 'New Email',
                        hintText: 'Enter your new email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: codeSent
                          ? null
                          : () {
                              if (newEmailInputController.text.isEmpty ||
                                  !newEmailInputController.text.contains('@')) {
                                setStateInDialog(() {
                                  errorMessage = 'Please enter a valid new email.';
                                });
                                return;
                              }
                              setStateInDialog(() {
                                codeSent = true;
                                errorMessage = null;
                                print('Code sent to ${newEmailInputController.text}');
                              });
                            },
                      child: const Text('Send Code'),
                    ),
                    const SizedBox(height: 15),
                    if (codeSent)
                      TextField(
                        controller: codeInputController,
                        decoration: const InputDecoration(
                          labelText: 'Verification Code',
                          hintText: 'Enter the 6-digit code',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Dispose controllers immediately when closing via Cancel
                    oldEmailInputController.dispose();
                    newEmailInputController.dispose();
                    codeInputController.dispose();
                  },
                ),
                TextButton(
                  child: const Text('Confirm Change'),
                  onPressed: codeSent
                      ? () {
                          if (codeInputController.text.length != 6) {
                            setStateInDialog(() {
                              errorMessage = 'Please enter a 6-digit verification code.';
                            });
                            return;
                          }
                          setState(() {
                            _emailController.text = newEmailInputController.text;
                          });
                          Navigator.of(dialogContext).pop();
                          // Dispose controllers immediately when confirming change
                          oldEmailInputController.dispose();
                          newEmailInputController.dispose();
                          codeInputController.dispose();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email successfully changed!')),
                          );
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    ); // Removed the .then() callback here
  }

  void _showGenderSelectionDialog(BuildContext context) {
    String? tempSelectedGender = _selectedGender;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Select Gender'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: const Text('Male'),
                    value: 'Male',
                    groupValue: tempSelectedGender,
                    onChanged: (String? value) {
                      setStateInDialog(() {
                        tempSelectedGender = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Female'),
                    value: 'Female',
                    groupValue: tempSelectedGender,
                    onChanged: (String? value) {
                      setStateInDialog(() {
                        tempSelectedGender = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Prefer not to say'),
                    value: 'Prefer not to say',
                    groupValue: tempSelectedGender,
                    onChanged: (String? value) {
                      setStateInDialog(() {
                        tempSelectedGender = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      _selectedGender = tempSelectedGender;
                    });
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'Select',
      fieldLabelText: 'Date of Birth',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }
}

/// A reusable widget for displaying a row of information (icon, label, value).
/// This is for static information or delete account.
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

/// A reusable widget for displaying an editable row of information.
class _EditableInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _EditableInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}

/// A reusable widget for displaying a tappable row of information.
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
            padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
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