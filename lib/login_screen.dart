// login_screen.dart
import 'package:flutter/material.dart';
import 'login_body.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Color(0xFF4A6FA5),
      ),
      body: LoginBody(),
    );
  }
}
