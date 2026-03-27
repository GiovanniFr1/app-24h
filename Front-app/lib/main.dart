import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const ProviderScope(child: Acre24hApp()));
}

class Acre24hApp extends StatelessWidget {
  const Acre24hApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acre 24h',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Firebase.apps.isNotEmpty &&
              FirebaseAuth.instance.currentUser != null
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
