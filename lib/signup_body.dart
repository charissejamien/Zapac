import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          //SizedBox(height: 20),
          Center(
            child: Text(
              "Create an Account",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6CA89A)),
            ),
          ),
          SizedBox(height: 20),
          Text("   Email", style: TextStyle(fontSize: 16)),
          TextField(
            controller: emailController,
            decoration: _inputDecoration(),
          ),
          SizedBox(height: 20),
          Text("   Password", style: TextStyle(fontSize: 16)),
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Text("   Confirm Password", style: TextStyle(fontSize: 16)),
          TextField(
            controller: confirmPasswordController,
            obscureText: _obscureConfirmPassword, // Use the new state variable
            decoration: _inputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword // Use the new state variable
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword; // Toggle the new state variable
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 35),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6CA89A),
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Sign Up",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, endIndent: 10),
                ),
                Text("or sign in with", style: TextStyle(color: Color(0xFF2F2D2A))),
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1, indent: 10),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.g_mobiledata, color: Colors.white),
                label: Text("Google", style: TextStyle(fontSize: 14, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E2E2E),
                  padding: EdgeInsets.symmetric(horizontal: 40),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.facebook, color: Colors.blue),
                label: Text("Facebook", style: TextStyle(fontSize: 14, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Color(0xFFF3EEE6),
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