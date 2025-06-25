import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';

void main() {
  runApp(MaterialApp(
    home: AuthScreen(),
    debugShowCheckedModeBanner: false,
  ));
}


