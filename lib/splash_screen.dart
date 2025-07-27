import 'package:flutter/material.dart';
import 'package:zapac/dashboard.dart';
import 'package:zapac/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Simulate some loading/initialization time
    await Future.delayed(const Duration(seconds: 3)); // Adjust duration as needed

    // TODO: Replace with your actual authentication/initialization logic
    // For example, checking AuthManager().isSignedInStream
    bool isSignedIn = false; // Replace with actual check

    if (!mounted) return; // Ensure widget is still in tree

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // This is where you decide where to go after loading
        // Example:
        builder: (context) => isSignedIn ? const Dashboard() : const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your app's primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your App Logo or Splash Image
            Image.asset(
              'assets/logo.png', // Make sure you have a logo.png in your assets folder
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            // A loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Your accent color
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}