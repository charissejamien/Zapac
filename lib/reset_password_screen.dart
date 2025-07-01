import 'package:flutter/material.dart';
import 'enter_code_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
          child: AppBar(
            backgroundColor: Color(0xFF4A6FA5),
            toolbarHeight: 100,
            automaticallyImplyLeading: false,
            leadingWidth: 500,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
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
            SizedBox(height: 50),
            Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6CA89A)
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10),
            Text(
              "Enter the email associated with your account and we'll send a code to your email to reset your password.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 80),
            Text("  Email", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFF3EEE6),
                hintText: 'Enter Email',
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
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnterCodeScreen()),
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
                "Send",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
              ),
            ),
          ],
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
    );
  }
}
