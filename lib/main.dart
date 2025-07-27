// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'dashboard.dart';
import 'AuthManager.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

// Create a ThemeNotifier to manage theme state
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) async {
    if (mode != _themeMode) {
      _themeMode = mode;
      notifyListeners();
      // Save theme preference to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    }
  }

  void setInitialTheme(ThemeMode mode) {
    _themeMode = mode;
  }
}

// Global instance of ThemeNotifier (for simplicity, consider Provider for larger apps)
final ThemeNotifier themeNotifier = ThemeNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.setInitialTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder( // Use ListenableBuilder to react to themeNotifier changes
      listenable: themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Zapac',
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF4A6FA5),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A6FA5),
              onPrimary: Colors.white,
              background: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              secondary: Color(0xFF6CA89A),
              error: Color(0xFFE97C7C),
              outlineVariant: Color(0xFFDDDDDD),
            ),
            // Define other light mode colors
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF273238),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF273238),
              onPrimary: Colors.white,
              background: Color(0xFF121212),
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
              secondary: Color(0xFF9DBEBB),
              error: Color(0xFFCF6679),
              outlineVariant: Color(0xFF444444),
            ),
            appBarTheme: AppBarTheme(color: Colors.grey),
            scaffoldBackgroundColor: Colors.grey[850],
            cardColor: Colors.grey[800],
            // Add more dark theme specific colors and styles as needed
          ),
          themeMode: themeNotifier.themeMode, // Use the theme mode from the notifier
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
// AuthWrapper remains as is from your file
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final currentUser = AuthManager().currentUser;
    print('[AuthWrapper] Building... Current user is: ${currentUser?.email}');
    if (currentUser != null) {
      return const Dashboard();
    } else {
      return const AuthScreen();
    }
  }
}