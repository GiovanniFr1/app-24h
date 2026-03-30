import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/providers/ride_request_provider.dart';

class SearchingDriverScreen extends ConsumerStatefulWidget {
  const SearchingDriverScreen({super.key});

  @override
  ConsumerState<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends ConsumerState<SearchingDriverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. Map Background (Simulated with Gradient & Noise placeholder)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppTheme.background,
                    AppTheme.surfaceContainerLowest,
                  ],
                ),
              ),
              child: Opacity(
                opacity: 0.2,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAlTbaUKJpKi_gMlEQQKC_xLd5TSlzF_7t51sYntkoRs4KAsnNJwSPyVsJBqNgNPstRyTYW3zmR8XcvGxFnXiB8L177tFq-5ILfA_uiaLGLapmpU_TlXhmCjtgl9yGJHqiITG24pucQEvgd4TI45R6Ml_fpYmJqYHaTVpdPAGHW2ENgJ-yAaM_hZa9zsIiA_NjOlroEgx5RIN--zwr8vT6IcKKRH9uUQNoCOy_a8RKtFJkvwfmroL6T8BDZ9iYBczMXvxuByWUzYrE',
                  fit: BoxFit.cover,
                  color: Colors.black,
                  colorBlendMode: BlendMode.color,
                ),
              ),
            ),
          ),
          
          // 2. Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100, // accommodate safe area
              padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu, color: AppTheme.primary),
                  ),
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDqOmWW7u8cFN-1VVqOcRrhQwFYcW3N01JerSpxUaFskFHbvdpn_s53QtQLojiTc8I76cGBYgeiy6J-kcBe3Y29hIMVTobjTC4VINo00Vzeco0KlizTg7vYm4jj28oHf-lC89m9XDU-kjBh5dfRDU4HfcGKEhcVyhw_9N_c_Kf8U7KZuGv_H4nBXPRhTv_nN1yxQeVkveKsIVn-zxUVwVaW37WcRp9voKcuGByMUi0aB74mEOiSIkjnlrTwOzssE13RCAMMQ4MeCWI'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Radar Animation
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing Rings
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildPulseRing(_animationController.value, AppTheme.primary),
                                  _buildPulseRing((_animationController.value + 0.5) % 1.0, AppTheme.secondary),
                                ],
                              );
                            },
                          ),
                          
                          // Scanning Line
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _animationController.value * 2 * math.pi,
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border(
                                      top: BorderSide(
                                        color: AppTheme.primary.withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Central Visual
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryContainer, AppTheme.primary],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.moped,
                              color: AppTheme.onPrimaryContainer,
                              size: 56,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),

                    // Status Information
                    Text(
                      'Procurando pilotos\nMoto Acre próximos...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conectando você à rota mais rápida',
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bento Status Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ESPERA EST.',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF5e4100),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '2-4',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppTheme.secondary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'MIN',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGlassPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRÂNSITO',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.tertiary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Leve',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.tertiary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Active Scanning Points
                    _buildGlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.tertiary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '3 Pilotos próximos',
                                style: GoogleFonts.inter(
                                  color: AppTheme.onSurface.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'RASTREANDO SETOR 7G',
                            style: GoogleFonts.inter(
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
          
          // Action Area
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    onPressed: () {
                      ref.read(rideRequestProvider.notifier).cancelRide();
                      Navigator.pop(context);
                    }, // Cancel action
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'CANCELAR PEDIDO',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SEM TAXA DE CANCELAMENTO NOS PRÓXIMOS 2 MINUTOS',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double progress, Color color) {
    // scale from 1.0 to 2.5
    final scale = 1.0 + (1.5 * progress);
    // opacity from 0.6 to 0.0
    final opacity = 0.6 * (1.0 - progress);
    
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 120, // base size matches central visual
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPanel({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(20)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F29).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: child,
    );
  }
}
