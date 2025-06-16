import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:zapac/dashboard.dart';
import 'reset_password_screen.dart';


class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  bool _obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          //SizedBox(height: 20),
          Center(
            child: Text(
              "Welcome Back!",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6CA89A)),
            ),
          ),
          SizedBox(height: 30),
          Text("   Email", style: TextStyle(fontSize: 16)),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
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
            ),
          ),
          SizedBox(height: 30),
          Text("   Password", style: TextStyle(fontSize: 16)),
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
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
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard()),
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
              "Login",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: RichText(
              text: TextSpan(
                text: "Forgotten your password? ",
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: " Reset password",
                    style: TextStyle(color: Color(0xFFEA4335)),
                    recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                      );
                    },
                  ),
                ],
              ),
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
}
