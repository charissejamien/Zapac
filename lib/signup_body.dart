import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'auth_screen.dart';

class SignUpBody extends StatefulWidget {
  const SignUpBody({super.key});

  @override
  _SignUpBodyState createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true; // Added for independent confirm password visibility
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen height for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjusted: Even further reduced spacing factors
    final double verticalSpacing = screenHeight * 0.008; // Significantly reduced vertical spacing
    final double buttonSpacing = screenHeight * 0.015;    // Significantly reduced spacing before buttons

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: ListView(
        // Ensure ListView is always scrollable for keyboard handling
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: verticalSpacing * 1.5), // Space at the top
          Center(
            child: Text(
              "Create an Account",
              style: TextStyle(
                fontSize: 26, // Adjusted: Further reduced font size from 24 to 22
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6CA89A),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing * 2), // Spacing after title
          const Text("   Email", style: TextStyle(fontSize: 16)),
          TextField(
            controller: emailController,
            decoration: _inputDecoration(),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: verticalSpacing), // Reduced spacing
          const Text("   Password", style: TextStyle(fontSize: 16)),
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration(
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
          SizedBox(height: verticalSpacing), // Reduced spacing
          const Text("   Confirm Password", style: TextStyle(fontSize: 16)),
          TextField(
            controller: confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: _inputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: buttonSpacing), // Spacing before Sign Up button

          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6CA89A),
              padding: const EdgeInsets.symmetric(vertical: 14), // Slightly reduced button vertical padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.black,
                fontSize: 17, // Slightly reduced button font size
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: verticalSpacing),
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
          SizedBox(height: verticalSpacing * 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    label: const Text("Google", style: TextStyle(fontSize: 13, color: Colors.white)), // Reduced font size
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E2E2E),
                      padding: const EdgeInsets.symmetric(vertical: 11), // Adjusted vertical padding
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
                    icon: const Icon(Icons.facebook, color: Colors.blue),
                    label: const Text("Facebook", style: TextStyle(fontSize: 13, color: Colors.black)), // Reduced font size
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11), // Adjusted vertical padding
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
          SizedBox(height: verticalSpacing), // Spacing at the bottom
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
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
      suffixIcon: suffixIcon,
    );
  }
}