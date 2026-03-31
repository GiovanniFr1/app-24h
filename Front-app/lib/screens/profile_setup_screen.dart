import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/providers/service_providers.dart';
import 'driver_home_screen.dart';
import 'home_screen.dart';
import '../models/kyc_models.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _carYearController = TextEditingController();
  final TextEditingController _carDoorsController = TextEditingController();
  
  String _selectedRole = 'passenger';
  String _selectedPayment = 'pix';
  bool _isLoading = false;
  String? _errorMessage;

  bool _hasEar = false;
  bool _isDefinitiveCnh = false;
  bool _hasAc = false;
  bool _backgroundCheckConsent = false;

  Future<void> _onSaveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(firebaseAuthServiceProvider);
      final user = service.currentUser;

      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      if (_selectedRole == 'passenger') {
        final payload = PassengerRegistrationPayload(
          cpf: _cpfController.text.trim(),
          fullName: name,
          email: user.email ?? '',
          phoneVerified: user.phoneNumber ?? '',
          isOver18: true, // Automático por ora até ter tela de birthdate
          defaultPaymentMethod: _selectedPayment,
        );
        final err = payload.validateClientSide();
        if (err != null) throw Exception(err);

        await ref.read(apiAuthRepositoryProvider).registerPassenger(payload);
      } else {
        final payload = DriverKycPayload(
          cpf: _cpfController.text.trim(),
          fullyName: name,
          phoneVerified: user.phoneNumber ?? '',
          cnhFilePath: 'mock_cnh.jpg', 
          selfieFilePath: 'mock_selfie.jpg', 
          hasEar: _hasEar,
          isDefinitiveCnh: _isDefinitiveCnh,
          backgroundCheckConsent: _backgroundCheckConsent,
          crlvFilePath: 'mock_crlv.pdf', 
          carYear: int.tryParse(_carYearController.text.trim()) ?? 0,
          carDoors: int.tryParse(_carDoorsController.text.trim()) ?? 0,
          hasAc: _hasAc,
          seatCapacity: 5,
          isNotPickupOrVan: true,
        );
        final err = payload.validateClientSide();
        if (err != null) throw Exception(err);

        await ref.read(apiAuthRepositoryProvider).registerDriverKyc(payload);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => _selectedRole == 'driver'
              ? const DriverHomeScreen()
              : const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _carYearController.dispose();
    _carDoorsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/logo.jpeg',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Editorial Header
                    Text(
                      'IDENTITY SETUP',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          height: 1.1,
                        ),
                        children: [
                          const TextSpan(text: 'Create your '),
                          TextSpan(
                            text: 'Rider Profile',
                            style: TextStyle(
                              color: AppTheme.primaryContainer,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Selecione seu perfil',
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleOption(
                            id: 'passenger',
                            title: 'Passageiro',
                            icon: Icons.person_outline,
                            selected: _selectedRole == 'passenger',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleOption(
                            id: 'driver',
                            title: 'Motorista',
                            icon: Icons.drive_eta,
                            selected: _selectedRole == 'driver',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Avatar Uploader
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                color: AppTheme.onSurfaceVariant,
                                size: 64,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primary,
                                    AppTheme.primaryContainer,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: AppTheme.background,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: AppTheme.onPrimaryContainer,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Input Fields
                    _buildInputLabel('FULL NAME'),
                    _buildTextField(
                      _nameController,
                      'Enter your name',
                      TextInputType.name,
                    ),
                    const SizedBox(height: 24),

                    _buildInputLabel('EMAIL ADDRESS'),
                    _buildTextField(
                      _emailController,
                      'name@example.com',
                      TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    _buildInputLabel('CPF'),
                    _buildTextField(
                      _cpfController,
                      '000.000.000-00',
                      TextInputType.number,
                    ),
                    const SizedBox(height: 32),

                    if (_selectedRole == 'driver') ...[
                      const Divider(height: 48),
                      Text(
                        'DADOS DO VEÍCULO E CNH',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInputLabel('ANO DE FABRICAÇÃO'),
                      _buildTextField(_carYearController, 'Ex: 2016', TextInputType.number),
                      const SizedBox(height: 24),
                      _buildInputLabel('QUANTIDADE DE PORTAS'),
                      _buildTextField(_carDoorsController, 'Ex: 4', TextInputType.number),
                      const SizedBox(height: 24),

                      _buildSwitch('Veículo possui Ar-Condicionado?', _hasAc, (v) => setState(() => _hasAc = v)),
                      _buildSwitch('CNH é Definitiva (Não PPD)?', _isDefinitiveCnh, (v) => setState(() => _isDefinitiveCnh = v)),
                      _buildSwitch('CNH possui EAR (Atividade Remun.)?', _hasEar, (v) => setState(() => _hasEar = v)),
                      _buildSwitch('Autorizo a checagem de antecedentes', _backgroundCheckConsent, (v) => setState(() => _backgroundCheckConsent = v)),
                      const SizedBox(height: 32),
                    ],

                    // Payment Methods Bento
                    _buildInputLabel('PREFERRED PAYMENT'),
                    const SizedBox(height: 12),

                    _buildPaymentOption(
                      id: 'pix',
                      title: 'Pix',
                      subtitle: 'Instant confirmation',
                      icon: Icons.qr_code_2,
                      color: AppTheme.tertiary,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      id: 'credit',
                      title: 'Credit Card',
                      subtitle: 'Ending in •••• 4242',
                      icon: Icons.credit_card,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      id: 'cash',
                      title: 'Cash',
                      subtitle: 'Pay after the ride',
                      icon: Icons.payments,
                      color: AppTheme.secondary,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 100), // Padding for fixed bottom CTA
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Area
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer.withValues(alpha: 0.9),
              ),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onSaveAndContinue,
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.onPrimaryContainer,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Text(
                          'SAVE AND CONTINUE',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String id,
    required String title,
    required IconData icon,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.surfaceContainerHigh
              : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: selected
                    ? AppTheme.onSurface
                    : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: AppTheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    TextInputType type,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.inter(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPayment == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.surfaceContainerHigh
              : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? color
                      : AppTheme.outlineVariant.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      activeColor: AppTheme.primary,
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
    );
  }
}
