import 'package:firebase_auth/firebase_auth.dart';
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

  void _navegarPorRole(Map<String, dynamic>? profile) {
    if (!mounted) return;
    if (profile == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );
      return;
    }
    final role = (profile['role'] as String?)?.toLowerCase();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            role == 'driver' ? const DriverHomeScreen() : const HomeScreen(),
      ),
    );
  }

  void _showEmailSheet() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool showPassword = false;
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> onContinuar() async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              if (!showPassword) {
                setSheetState(() => showPassword = true);
                return;
              }

              final password = passwordController.text;
              if (password.isEmpty) return;

              setSheetState(() {
                isLoading = true;
                errorMessage = null;
              });

              try {
                final service = ref.read(firebaseAuthServiceProvider);

                // Tenta login; se o usuário não existir, cria a conta.
                try {
                  await service.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found' ||
                      e.code == 'invalid-credential') {
                    await service.registerWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                  } else {
                    rethrow;
                  }
                }

                Map<String, dynamic>? profile;
                try {
                  profile = await ref
                      .read(firestoreUserRepositoryProvider)
                      .getUserProfile();
                } catch (_) {
                  profile = null;
                }

                if (!context.mounted) return;
                Navigator.pop(context);
                _navegarPorRole(profile);
              } on FirebaseAuthException catch (e) {
                setSheetState(() {
                  isLoading = false;
                  errorMessage = _traduzirErroAuth(e.code);
                });
              } catch (e) {
                setSheetState(() {
                  isLoading = false;
                  errorMessage = 'Erro inesperado. Tente novamente.';
                });
              }
            }

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
                      showPassword ? 'Sua Senha' : 'Seu E-mail',
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
                      enabled: !showPassword,
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
                      autofocus: !showPassword,
                    ),
                    if (showPassword) ...[
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
                        autofocus: true,
                      ),
                    ],
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: GoogleFonts.inter(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      text: isLoading
                          ? 'AGUARDE...'
                          : showPassword
                          ? 'ENTRAR'
                          : 'CONTINUAR',
                      onPressed: isLoading ? () {} : onContinuar,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _traduzirErroAuth(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde.';
      case 'email-already-in-use':
        return 'E-mail já cadastrado. Tente fazer login.';
      default:
        return 'Falha na autenticação. Verifique seus dados.';
    }
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
        profile = await ref
            .read(firestoreUserRepositoryProvider)
            .getUserProfile();
      } catch (_) {
        profile = null;
      }
      if (!mounted) return;
      _navegarPorRole(profile);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in falhou: $e')),
      );
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

                  // Logo
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

                  // Botões de autenticação
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
                    onPressed: _showEmailSheet,
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
    return Container(
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
    );
  }
}
