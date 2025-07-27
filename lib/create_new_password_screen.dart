import 'package:flutter/material.dart';
import 'auth_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  _CreateNewPasswordScreenState createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _errorMessage = ''; // State variable for general error message (from button press)
  static const double _errorMessageHeight = 30.0; // Fixed height for error message

  // NEW: State variables for real-time password validation feedback
  bool _isPasswordLengthValid = false;
  bool _doPasswordsMatch = false; // For real-time feedback on confirm password
  String? _passwordFieldHintText; // For real-time password length hint/error

  @override
  void initState() {
    super.initState();
    // Add listener to password field for real-time validation
    passwordController.addListener(_validatePasswordField);
    confirmPasswordController.addListener(_validateConfirmPasswordField);
  }

  @override
  void dispose() {
    passwordController.removeListener(_validatePasswordField); // Remove listener
    confirmPasswordController.removeListener(_validateConfirmPasswordField); // Remove listener
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // NEW: Real-time password validation logic
  void _validatePasswordField() {
    final password = passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _isPasswordLengthValid = false;
        _passwordFieldHintText = null; // No hint if empty
      } else if (password.length < 8) {
        _isPasswordLengthValid = false;
        _passwordFieldHintText = "Must be at least 8 characters.";
      } else {
        _isPasswordLengthValid = true;
        _passwordFieldHintText = null; // Clear hint if valid
      }
      // Also re-check confirm password if password changes
      _validateConfirmPasswordField();
    });
  }

  // NEW: Real-time confirm password validation logic
  void _validateConfirmPasswordField() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    setState(() {
      if (confirmPassword.isEmpty) {
        _doPasswordsMatch = false; // Cannot match if empty
      } else if (password == confirmPassword) {
        _doPasswordsMatch = true;
      } else {
        _doPasswordsMatch = false;
      }
    });
  }

  void _resetPassword() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      _errorMessage = ''; // Clear previous general error messages
    });

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Password fields cannot be empty.";
      });
      return;
    }

    // If all validations pass, clear general error and proceed
    setState(() {
      _errorMessage = ''; // Clear general error on success
    });

    // Proceed with password reset logic (e.g., call an AuthManager method)
    // For now, it navigates back to AuthScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF4A6FA5),
            toolbarHeight: 100,
            automaticallyImplyLeading: false,
            leadingWidth: 500,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 40),
                  Icon(Icons.arrow_back, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Create New",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6CA89A),
              ),
            ),
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6CA89A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your new password must be different from previous used passwords.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text("  Password", style: TextStyle(fontSize: 16)),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              // NEW: onChanged listener for real-time validation feedback
              // onChanged: (value) => _validatePasswordField(), // Listener already added in initState
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF3EEE6),
                hintText: 'Enter Password',
                // NEW: Dynamic border color
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: passwordController.text.isNotEmpty && !_isPasswordLengthValid
                        ? Colors.red // Red if invalid and not empty
                        : Colors.transparent, // Transparent for default state (or a subtle grey)
                    width: 1.5, // Make border slightly visible
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: _isPasswordLengthValid ? Colors.blue : Colors.red, // Blue if valid, Red if invalid
                    width: 2.0, // Thicker border when focused
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            // NEW: Real-time password length hint/error
            SizedBox(
              height: _passwordFieldHintText != null ? 20.0 : 0, // Reserve height if hint exists
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0), // Adjust padding
                  child: Text(
                    _passwordFieldHintText ?? '',
                    style: const TextStyle(fontSize: 12.5, color: Colors.red), // Red for error hint
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("  Confirm Password", style: TextStyle(fontSize: 16)),
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              // NEW: onChanged listener for real-time validation feedback
              // onChanged: (value) => _validateConfirmPasswordField(), // Listener already added in initState
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF3EEE6),
                hintText: 'Enter New Password',
                // NEW: Dynamic border color based on match
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch
                        ? Colors.red // Red if not matching and not empty
                        : Colors.transparent, // Transparent for default state
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: _doPasswordsMatch ? Colors.blue : Colors.red, // Blue if match, Red if not
                    width: 2.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            // NEW: Real-time confirm password hint/error
            SizedBox(
              height: confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch ? 20.0 : 0, // Reserve height if hint exists
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0), // Adjust padding
                  child: Text(
                    confirmPasswordController.text.isNotEmpty && !_doPasswordsMatch ? "Passwords do not match." : "",
                    style: const TextStyle(fontSize: 12.5, color: Colors.red), // Red for error hint
                  ),
                ),
              ),
            ),
            // General error message (from button press, fixed height)
            SizedBox(
              height: _errorMessageHeight + 20,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 15 - _errorMessageHeight < 0 ? 0 : 15 - _errorMessageHeight),
            Center(
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CA89A),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Reset Password",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF4A6FA5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
        ),
      ),
    );
  }
}