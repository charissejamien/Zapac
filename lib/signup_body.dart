import 'package:flutter/material.dart';
import 'auth_screen.dart';
class SignUpBody extends StatefulWidget {
  const SignUpBody({super.key});

  @override
  _SignUpBodyState createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String _generalErrorMessage = '';
  String _emailErrorMessage = '';
  static const double _emailErrorMessageHeight = 20.0;

  String _passwordFieldHintText = "";
  Color _passwordFieldHintColor = Colors.transparent;

  String _confirmPasswordFieldHintText = "";
  Color _confirmPasswordFieldHintColor = Colors.transparent;

  static const double _fieldHintHeight = 18.0;
  static const double _generalErrorMessageHeight = 20.0;


  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmailField);
    passwordController.addListener(_validatePasswordField);
    confirmPasswordController.addListener(_validateConfirmPasswordField);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.removeListener(_validateEmailField);
    emailController.dispose();
    passwordController.removeListener(_validatePasswordField);
    passwordController.dispose();
    confirmPasswordController.removeListener(_validateConfirmPasswordField);
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmailField() {
    final email = emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailErrorMessage = '';
      } else if (!email.contains('@gmail.com')) {
        _emailErrorMessage = "Please enter a valid email address.";
      } else {
        _emailErrorMessage = '';
      }
    });
  }

  void _validatePasswordField() {
    final password = passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordFieldHintText = "Must be at least 8 characters.";
        _passwordFieldHintColor = Colors.transparent;
      } else if (password.length < 8) {
        _passwordFieldHintText = "Password must be at least 8 characters long.";
        _passwordFieldHintColor = Colors.red;
      } else {
        _passwordFieldHintText = "Password looks good!";
        _passwordFieldHintColor = Colors.green;
      }
      _validateConfirmPasswordField();
    });
  }

  void _validateConfirmPasswordField() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    setState(() {
      if (confirmPassword.isEmpty) {
        _confirmPasswordFieldHintText = "Both passwords must match.";
        _confirmPasswordFieldHintColor = Colors.transparent;
      } else if (password == confirmPassword) {
        _confirmPasswordFieldHintText = "Passwords match!";
        _confirmPasswordFieldHintColor = Colors.green;
      } else {
        _confirmPasswordFieldHintText = "Passwords do not match.";
        _confirmPasswordFieldHintColor = Colors.red;
      }
    });
  }

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Center(
          child: Text(
            'This feature is coming soon!',
            textAlign: TextAlign.center,
          ),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 6.0,
      ),
    );
  }

  void _handleSignUp() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      _generalErrorMessage = '';
    });

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _generalErrorMessage = "All fields must be filled.";
      });
      return;
    }
    if (_emailErrorMessage.isNotEmpty) {
      setState(() {
        _generalErrorMessage = _emailErrorMessage;
      });
      return;
    }
    if (password.length < 8) {
      setState(() {
        _generalErrorMessage = "Password must be at least 8 characters long.";
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _generalErrorMessage = "Passwords do not match.";
      });
      return;
    }

    setState(() {
      _generalErrorMessage = '';
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double verticalSpacing = screenHeight * 0.006;
    final double buttonSpacing = screenHeight * 0.01;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: verticalSpacing * 5),
          Center(
            child: Text(
              "Create an Account",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6CA89A),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 3),
          const Text(" Email", style: TextStyle(fontSize: 15)),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3EEE6),
              hintStyle: const TextStyle(fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: emailController.text.isNotEmpty && _emailErrorMessage.isNotEmpty
                      ? Colors.red
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: _emailErrorMessage.isNotEmpty ? Colors.red : Colors.blue,
                  width: 2.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: _emailErrorMessageHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text(
                  _emailErrorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 11.5),
                ),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 1),
          const Text(" Password", style: TextStyle(fontSize: 15)),
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3EEE6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: passwordController.text.isNotEmpty && _passwordFieldHintColor == Colors.red
                      ? Colors.red
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: _passwordFieldHintColor == Colors.green ? Colors.blue : Colors.red,
                  width: 2.0,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: _fieldHintHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text(
                  _passwordFieldHintText,
                  style: TextStyle(fontSize: 11.5, color: passwordController.text.isEmpty ? Colors.transparent : _passwordFieldHintColor),
                ),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 1.5),
          const Text(" Confirm Password", style: TextStyle(fontSize: 15)),
          TextField(
            controller: confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3EEE6),
              hintStyle: const TextStyle(fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: confirmPasswordController.text.isNotEmpty && _confirmPasswordFieldHintColor == Colors.red
                      ? Colors.red
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: _confirmPasswordFieldHintColor == Colors.green ? Colors.blue : Colors.red,
                  width: 2.0,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: _fieldHintHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text(
                  _confirmPasswordFieldHintText,
                  style: TextStyle(fontSize: 11.5, color: confirmPasswordController.text.isEmpty ? Colors.transparent : _confirmPasswordFieldHintColor),
                ),
              ),
            ),
          ),
          SizedBox(
            height: _generalErrorMessageHeight,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                _generalErrorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: buttonSpacing * 0.015),

          ElevatedButton(
            onPressed: _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6CA89A),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, endIndent: 10),
                ),
                Text(
                  "or sign in with",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 13,
                  ),
                ),
                const Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, indent: 10),
                ),
              ],
            ),
          ),
          SizedBox(height: verticalSpacing * 3.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 20),
  label: const Text("Google", style: TextStyle(fontSize: 12, color: Colors.white)),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2E2E2E),
    padding: const EdgeInsets.symmetric(vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  ),
),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.facebook, color: Colors.blue, size: 20),
  label: const Text("Facebook", style: TextStyle(fontSize: 12, color: Colors.black)),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  ),
),
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing),
        ],
      ),
    );
  }
}