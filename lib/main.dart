import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';
import 'loading_screen.dart'; // Import your new loading screen

void main() {
  runApp(MaterialApp(
    home: LoadingScreen(), // Start with LoadingScreen
    debugShowCheckedModeBanner: false,
  ));
}


