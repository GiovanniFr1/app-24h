import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import 'custom_button.dart';

class DriverInfoCard extends StatelessWidget {
  final Map<String, dynamic> driverInfo;
  final VoidCallback onCancel;

  const DriverInfoCard({
    super.key,
    required this.driverInfo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho - Motorista a caminho
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motorista a caminho',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chega em ${driverInfo['etaMins']} min',
                  style: GoogleFonts.inter(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${driverInfo['rating']}',
                    style: GoogleFonts.inter(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Info do Motorista
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(driverInfo['photoUrl']),
              backgroundColor: AppTheme.surfaceContainerLowest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverInfo['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${driverInfo['trips']} corridas',
                    style: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.messageCircle, color: AppTheme.onSurface),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.phone, color: AppTheme.primary),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Info do Carro
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverInfo['carModel'],
                        style: GoogleFonts.inter(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driverInfo['plate'],
                        style: GoogleFonts.inter(
                          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Image.asset(
                'assets/carro_placeholder.png', // Fallback, não importa tanto agora se a img existir
                height: 40,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(LucideIcons.car, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8), size: 40),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Ações
        CustomButton(
          text: 'Cancelar Corrida',
          icon: LucideIcons.x,
          isOutlined: true,
          onPressed: onCancel,
        ),
      ],
    );
  }
}
