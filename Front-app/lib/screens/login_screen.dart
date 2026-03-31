import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/providers/service_providers.dart';
import '../shared/widgets/custom_button.dart';
import 'home_screen.dart';
import 'driver_home_screen.dart';
import 'phone_verification_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleLoading = false;

  void _loginAsGuest() {
    _navegar(false);
  }

  void _navegar(bool isDriver) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isDriver ? const DriverHomeScreen() : const HomeScreen(),
      ),
    );
  }

  Future<void> _loginWithEmail(String email, String password) async {
    try {
      final service = ref.read(firebaseAuthServiceProvider);
      await service.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic>? profile;
      try {
        profile = await ref.read(apiAuthRepositoryProvider).fetchDashboard();
      } catch (_) {
        profile = null;
      }
      if (!mounted) return;

      Navigator.pop(context);
      if (profile == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
        return;
      }

      final isDriver =
          (profile['is_driver'] as bool?) ??
          (profile['role'] as String?)?.toLowerCase() == 'driver';
      _navegar(isDriver);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no login: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _registerWithEmail(String email, String password) async {
    try {
      final service = ref.read(firebaseAuthServiceProvider);
      await service.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no cadastro: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showEmailLoginSheet() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Login com E-mail',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.inter(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  style: GoogleFonts.inter(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'ENTRAR',
                  onPressed: () {
                    _loginWithEmail(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'CADASTRAR',
                  onPressed: () {
                    Navigator.pop(context);
                    _showEmailRegisterSheet();
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmailRegisterSheet() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cadastrar com E-mail',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.inter(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  style: GoogleFonts.inter(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'CADASTRAR',
                  onPressed: () {
                    _registerWithEmail(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final service = ref.read(firebaseAuthServiceProvider);
      final credential = await service.signInWithGoogle();
      if (credential == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }

      Map<String, dynamic>? profile;
      try {
        profile = await ref.read(apiAuthRepositoryProvider).fetchDashboard();
      } catch (_) {
        profile = null;
      }
      if (!mounted) return;

      if (profile == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
        return;
      }

      final isDriver =
          (profile['is_driver'] as bool?) ??
          (profile['role'] as String?)?.toLowerCase() == 'driver';
      _navegar(isDriver);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1558981403-90f13a27289d?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppTheme.background),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background.withValues(alpha: 0.4),
                    AppTheme.background.withValues(alpha: 0.8),
                    AppTheme.background,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // App Logo - Premium Layout
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 40,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/logo.jpeg',
                        width: 260,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Social Login Actions
                  CustomButton(
                    text: 'CONTINUAR COM TELEFONE',
                    icon: Icons.phone_android,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhoneVerificationScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'CONTINUAR COM EMAIL',
                    icon: Icons.email_outlined,
                    onPressed: _showEmailLoginSheet,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'CRIAR CONTA COM EMAIL',
                    icon: Icons.person_add_outlined,
                    onPressed: _showEmailRegisterSheet,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          iconPath: 'google',
                          isLoading: _isGoogleLoading,
                          onPressed: _signInWithGoogle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          iconPath: 'apple',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU EXPLORE O APP',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _loginAsGuest,
                    child: Text(
                      'CONTINUAR COMO CONVIDADO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.secondaryContainer,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  Text(
                    'AO SE CADASTRAR, VOCÊ CONCORDA COM NOSSOS TERMOS DE SERVIÇO E POLÍTICAS DE PRIVACIDADE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String iconPath,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : iconPath == 'google'
              ? _buildGoogleIcon()
              : const Icon(Icons.apple, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              'G',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
