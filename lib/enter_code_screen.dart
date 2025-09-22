import 'package:flutter/material.dart';
import 'create_new_password_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  String _errorMessage = '';
  String _resendMessage = '';

  // Hardcoded valid code
  static const String _validCode = "00000";

  static const double _errorMessageHeight = 24.0;
  static const double _resendMessageHeight = 20.0;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 4) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_errorMessage.isNotEmpty && mounted) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  // Handle Verify button press
  void _verifyCode() {
    String enteredCode = _controllers.map((c) => c.text).join();

    if (enteredCode.isEmpty) {
      setState(() {
        _errorMessage = "Please enter the code.";
      });
    } else if (enteredCode.length < 5) {
      setState(() {
        _errorMessage = "Please enter the full 5-digit code.";
      });
    }
    else if (enteredCode != _validCode) {
      setState(() {
        _errorMessage = "Invalid code. Please try again.";
      });
    } else {
      setState(() {
        _errorMessage = '';
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateNewPasswordScreen()),
      );
    }
  }

  // Handle Resend now button press
  void _resendCode() {
    setState(() {
      _resendMessage = "Code resent! Check your email.";
      _errorMessage = '';
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _resendMessage = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF4A6FA5),
            toolbarHeight: 100,
            automaticallyImplyLeading: false,
            leadingWidth: 500,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(
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
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ListView(
          children: [
            const SizedBox(height: 80),
              const Text(
                "Enter Code",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6CA89A),
                ),
                textAlign: TextAlign.left,
              ),
            const SizedBox(height: 5),
            const Text(
              "Enter the code we sent you as verification to reset your password.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 60),
            const Text("    Code", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: const Color(0xFFF3EEE6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                );
              }),
            ),

            SizedBox(
              height: _errorMessageHeight + 25,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Didn't receive code?",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _resendCode, // Call resend method
                    child: const Text(
                      "Resend now",
                      style: TextStyle(
                        color: Color(0xFFFF7979),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _resendMessageHeight, // Fixed height
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        _resendMessage,
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _verifyCode, // Call verify method
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CA89A),
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Verify",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
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