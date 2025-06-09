import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'loading_screen.dart'; // Import your new loading screen

void main() {
  runApp(MaterialApp(
    home: LoadingScreen(), // Start with LoadingScreen
    debugShowCheckedModeBanner: false,
  ));
}
