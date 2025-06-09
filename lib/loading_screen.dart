import 'package:flutter/material.dart';
import 'auth_screen.dart'; // Import your actual AuthScreen here

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _loopCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _loopCount++;
        if (_loopCount < 3) {
          _controller.forward();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthScreen()),
          );
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Bus
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/logo.png',
                width: 150,
              ),
            ),
            SizedBox(height: 250),

            // Gradient Text
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                "ZAPAC",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Important for ShaderMask
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
