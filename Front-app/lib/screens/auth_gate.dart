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
    final service = ref.read(firebaseAuthServiceProvider);
    final user = service.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: service.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
                    const SizedBox(height: 24),
                    const Text('Não foi possível carregar o perfil do usuário.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final profile = snapshot.data;
        if (profile == null) {
          return const ProfileSetupScreen();
        }

        final isDriver = (profile['is_driver'] as bool?) ??
            (profile['role'] as String?)?.toLowerCase() == 'driver';

        return isDriver ? const DriverHomeScreen() : const HomeScreen();
      },
    );
  }
}
