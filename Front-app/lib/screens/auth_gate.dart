import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/service_providers.dart';
import 'driver_home_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: ref.read(firestoreUserRepositoryProvider).getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              // Documento ainda não existe no Firestore (Cloud Function pode estar em delay)
              // ou é um novo usuário que ainda não configurou o perfil.
              return const ProfileSetupScreen();
            }

            final role = (profile['role'] as String?)?.toLowerCase();
            return role == 'driver'
                ? const DriverHomeScreen()
                : const HomeScreen();
          },
        );
      },
    );
  }
}
