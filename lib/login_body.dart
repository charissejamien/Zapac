import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:zapac/dashboard.dart';
import 'reset_password_screen.dart';
import 'package:zapac/AuthManager.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  bool _obscurePassword = true;
  String _errorMessage = '';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      _errorMessage = '';
    });

    if (email.isEmpty && password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your credentials.";
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email address.";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your password.";
      });
      return;
    }

    bool success = await AuthManager().login(email, password);

    if (!mounted) return;
    if (success) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
            child: Text(
              'Login successful!',
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 700),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 6.0, // Add elevation
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
      });
    } else {
      setState(() => _errorMessage = "Invalid email or password.");
    }
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
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 6.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final double verticalSpacing = screenHeight * 0.012;
    final double buttonSpacing = screenHeight * 0.018;
    final double errorHeight = screenHeight * 0.05;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: verticalSpacing * 1.5),
          const Center(
            child: Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6CA89A),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 2),
          const Text("   Email", style: TextStyle(fontSize: 16)),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3EEE6),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: verticalSpacing * 2),
          const Text("   Password", style: TextStyle(fontSize: 16)),
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3EEE6),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          Container(
            height: errorHeight,
            alignment: Alignment.center,
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
          SizedBox(height: buttonSpacing * 0.015),

          ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6CA89A),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          SizedBox(height: verticalSpacing * 1.5),
          Center(
            child: RichText(
              text: TextSpan(
                text: "Forgotten your password? ",
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                children: [
                  TextSpan(
                    text: " Reset password",
                    style: const TextStyle(color: Color(0xFFEA4335)),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResetPasswordScreen(),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 1.5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, endIndent: 10),
                ),
                Text(
                  "or sign in with",
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, indent: 10),
                ),
              ],
            ),
          ),
          SizedBox(height: verticalSpacing * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton.icon(
                    onPressed: _showComingSoonSnackBar,
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    label: const Text(
                      "Google",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E2E2E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    onPressed: _showComingSoonSnackBar,
                    icon: const Icon(Icons.facebook, color: Colors.blue),
                    label: const Text(
                      "Facebook",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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