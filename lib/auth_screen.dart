import 'package:flutter/material.dart';
import 'login_body.dart'; // New login widget
import 'signup_body.dart'; // You'll create this later

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignUpSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(220),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
          child: AppBar(
            backgroundColor: Color(0xFF4A6FA5),
            toolbarHeight: 320,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Image.asset('assets/logo.png', height: 100,),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => isSignUpSelected = true),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: isSignUpSelected
                              ? Border(bottom: BorderSide(color: Colors.white))
                              : null,
                        ),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: isSignUpSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    GestureDetector(
                      onTap: () => setState(() => isSignUpSelected = false),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: !isSignUpSelected
                              ? Border(bottom: BorderSide(color: Colors.white))
                              : null,
                        ),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: !isSignUpSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFF4A6FA5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
        ),
      ),
      body: isSignUpSelected ? SignUpBody() : LoginBody(),
    );
  }
}
