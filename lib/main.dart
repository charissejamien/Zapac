import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'dashboard.dart';
import 'AuthManager.dart'; // Import AuthManager

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The AuthWrapper will handle showing the correct screen
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// THIS IS THE NEW WIDGET THAT SOLVES THE PROBLEM
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    // We get the currentUser from the single, persistent instance of AuthManager
    final currentUser = AuthManager().currentUser;

    print('[AuthWrapper] Building... Current user is: ${currentUser?.email}');

    if (currentUser != null) {
      // If the user is logged in, show the Dashboard
      return const Dashboard();
    } else {
      // If the user is not logged in, show the AuthScreen
      return const AuthScreen();
    }
  }
}
