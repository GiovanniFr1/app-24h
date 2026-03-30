import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/providers/ride_request_provider.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/buscador_bairro_sheet.dart';
import '../shared/widgets/trip_status_card.dart';
import '../shared/widgets/trip_completed_sheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'searching_driver_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _bairros = [
    {'nome': 'Centro', 'distanciaKm': 1.5, 'multiplicador': 1.0, 'periculosidade': 'Baixa'},
    {'nome': 'Bosque', 'distanciaKm': 3.2, 'multiplicador': 1.2, 'periculosidade': 'Baixa'},
    {'nome': 'Placas', 'distanciaKm': 5.8, 'multiplicador': 1.5, 'periculosidade': 'Média'},
    {'nome': 'Cidade Nova', 'distanciaKm': 8.5, 'multiplicador': 2.0, 'periculosidade': 'Alta'},
    {'nome': 'Taquari', 'distanciaKm': 12.4, 'multiplicador': 2.5, 'periculosidade': 'Crítica'},
  ];

  Map<String, dynamic>? _bairroSelecionado;
  String _selectedRideType = 'standard';

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-9.97499, -67.8243),
    zoom: 13.5,
  );

  final double _tarifaBase = 5.0; // Valor de partida
  final double _valorPorKm = 1.50; // Valor por kilômetro rodado

  double get _valorFinal {
    if (_bairroSelecionado == null) return _tarifaBase;
    double distancia = _bairroSelecionado!['distanciaKm'];
    double multiplicador = _bairroSelecionado!['multiplicador'];
    return (_tarifaBase + (distancia * _valorPorKm)) * multiplicador;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RideRequestState>(rideRequestProvider, (previous, next) {
      if (previous?.status != RideRequestStatus.searching && next.status == RideRequestStatus.searching) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchingDriverScreen()),
        );
      }
      if (previous?.status == RideRequestStatus.searching && (next.status == RideRequestStatus.accepted || next.status == RideRequestStatus.error)) {
        // Pop the search screen when search finishes (accept or error)
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });

    final rideState = ref.watch(rideRequestProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.background,
                Colors.transparent,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primaryContainer),
          onPressed: () {},
        ),
        title: Image.asset(
          'assets/images/logo.jpeg',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceContainerHigh,
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(Icons.person, color: AppTheme.onSurface, size: 20),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {},
          ),

          if (rideState.status == RideRequestStatus.accepted ||
              rideState.status == RideRequestStatus.driverArrived ||
              rideState.status == RideRequestStatus.inTransit)
             Positioned(
               top: 100,
               right: 24,
               child: GestureDetector(
                 onTap: () => _showSafetyCenterSheet(context),
                 child: ClipOval(
                   child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                     child: Container(
                       width: 56,
                       height: 56,
                       decoration: BoxDecoration(
                         color: AppTheme.primary.withValues(alpha: 0.1),
                         border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
                         shape: BoxShape.circle,
                         boxShadow: [
                           BoxShadow(
                             color: AppTheme.primary.withValues(alpha: 0.2),
                             blurRadius: 16,
                           ),
                         ],
                       ),
                       child: const Center(
                         child: Icon(Icons.shield, color: AppTheme.primary, size: 28),
                       ),
                     ),
                   ),
                 ),
               ),
             ),

          if (_bairroSelecionado != null && rideState.status == RideRequestStatus.initial)
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 24,
                              color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                            const Icon(Icons.location_on, color: AppTheme.tertiary, size: 16),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT ROUTE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary.withValues(alpha: 0.7),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                _bairroSelecionado!['nome'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
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

          Positioned(
            right: 24,
            bottom: _bairroSelecionado == null ? 300 : 450,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.my_location, color: AppTheme.onSurface),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildStateContent(rideState),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: rideState.status == RideRequestStatus.initial
            ? Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer.withValues(alpha: 0.9),
                  border: Border(top: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.2))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 32,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: BottomNavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      currentIndex: _selectedIndex,
                      onTap: (index) => setState(() => _selectedIndex = index),
                      selectedItemColor: AppTheme.primary,
                      unselectedItemColor: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                      selectedLabelStyle: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.moped),
                          label: 'CORRIDA',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.history),
                          label: 'ATIVIDADE',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.account_balance_wallet),
                          label: 'CARTEIRA',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: 'PERFIL',
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildStateContent(RideRequestState state) {
    if (state.status == RideRequestStatus.searching) {
      // Searching state is handled via Navigation push listener above
      // But we show an empty container or minimal loading here just in case
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    } else if (state.status == RideRequestStatus.accepted ||
        state.status == RideRequestStatus.driverArrived ||
        state.status == RideRequestStatus.inTransit) {
      return TripStatusCard(
        state: state,
        onCancel: () {
          ref.read(rideRequestProvider.notifier).cancelRide();
          setState(() => _bairroSelecionado = null);
        },
        onSafetyTap: () => _showSafetyCenterSheet(context),
      );
    } else if (state.status == RideRequestStatus.completed) {
      return TripCompletedSheet(
        driverInfo: state.driverInfo ?? {},
        onFinish: () {
          ref.read(rideRequestProvider.notifier).cancelRide();
          setState(() => _bairroSelecionado = null);
        },
      );
    } else if (state.status == RideRequestStatus.error) {
      return _buildErrorState(state.errorMessage ?? 'Erro.');
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        key: const ValueKey('error'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppTheme.onSurface)),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Tentar novamente',
            onPressed: () {
              ref.read(rideRequestProvider.notifier).cancelRide();
              setState(() => _bairroSelecionado = null);
            },
          ),
        ],
      ),
    );
  }



  Widget _buildInitialState() {
    if (_bairroSelecionado != null) {
      return _buildRideSelection();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        key: const ValueKey('initial'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para onde?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildBairroSelector(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBentoShortcut(
                  icon: Icons.home,
                  title: 'Casa',
                  subtitle: '15 min',
                  color: AppTheme.secondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBentoShortcut(
                  icon: Icons.work,
                  title: 'Trabalho',
                  subtitle: '28 min',
                  color: AppTheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATIVIDADE RECENTE',
                style: GoogleFonts.inter(
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'LIMPAR',
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentItem('Ace Coffee Roasters', '4th Street, Rio Branco'),
        ],
      ),
    );
  }

  Widget _buildBentoShortcut({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
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
                subtitle.toUpperCase(),
                style: GoogleFonts.inter(
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppTheme.onSurfaceVariant, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(color: AppTheme.onSurface, fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildBairroSelector() {
    return GestureDetector(
      onTap: _abrirBuscaBairro,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Insira o destino',
                style: GoogleFonts.inter(
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideSelection() {
    return Column(
      key: const ValueKey('ride_selection'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecione sua moto',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Viagens mais rápidas, frota premium.',
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildRideOption(
                id: 'standard',
                title: 'Moto Standard',
                subtitle: 'A 3 min',
                price: _valorFinal,
                tag: 'ECONOMIA',
                icon: Icons.motorcycle,
                color: AppTheme.tertiary,
                isHighDemand: _bairroSelecionado?['periculosidade'] == 'Alta' || _bairroSelecionado?['periculosidade'] == 'Crítica',
              ),
              const SizedBox(height: 16),
              _buildRideOption(
                id: 'comfort',
                title: 'Moto Comfort',
                subtitle: 'A 5 min',
                price: _valorFinal * 1.4,
                tag: 'PREMIUM',
                icon: Icons.sports_motorsports,
                color: AppTheme.secondaryContainer,
                isHighDemand: _bairroSelecionado?['periculosidade'] == 'Alta' || _bairroSelecionado?['periculosidade'] == 'Crítica',
              ),
              const SizedBox(height: 16),
              _buildRideOption(
                id: 'express',
                title: 'Moto Express',
                subtitle: 'A 1 min',
                price: _valorFinal * 1.9,
                tag: 'MAIS RÁPIDA',
                icon: Icons.speed,
                color: AppTheme.primary,
                isHighDemand: _bairroSelecionado?['periculosidade'] == 'Alta' || _bairroSelecionado?['periculosidade'] == 'Crítica',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.1))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Text('•••• 4242', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                ],
              ),
              Text(
                'ALTERAR',
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: CustomButton(
            text: 'Solicitar Moto Acre',
            icon: Icons.arrow_forward,
            onPressed: () {
              ref.read(rideRequestProvider.notifier).requestRide(
                origin: 'Centro',
                destination: _bairroSelecionado!['nome'] as String,
                price: _selectedRideType == 'standard'
                    ? _valorFinal
                    : _selectedRideType == 'comfort'
                        ? _valorFinal * 1.4
                        : _valorFinal * 1.9,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRideOption({
    required String id,
    required String title,
    required String subtitle,
    required double price,
    required String tag,
    required IconData icon,
    required Color color,
    bool isHighDemand = false,
  }) {
    final bool isSelected = _selectedRideType == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRideType = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceContainerHighest : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 20,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      if (isHighDemand) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, color: AppTheme.error, size: 10),
                              const SizedBox(width: 2),
                              Text(
                                'ALTA',
                                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: color, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        subtitle.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : AppTheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSafetyCenterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Central de Segurança',
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estamos monitorando sua viagem em tempo real.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildSafetyOption(
                    icon: Icons.share_location,
                    title: 'Compartilhar Rota',
                    subtitle: 'Envie sua localização em tempo real para contatos de confiança',
                    color: AppTheme.primary,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rota compartilhada!')));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSafetyOption(
                    icon: Icons.mic,
                    title: 'Gravar Áudio',
                    subtitle: 'Grave o áudio da viagem de forma segura',
                    color: AppTheme.tertiary,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iniciando gravação de áudio...')));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSafetyOption(
                    icon: Icons.local_police,
                    title: 'Ligar para Polícia (190)',
                    subtitle: 'Compartilhe sua localização diretamente com as autoridades',
                    color: AppTheme.error,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ligando para a Polícia...')));
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSafetyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _abrirBuscaBairro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuscadorBairroSheet(bairros: _bairros),
    ).then((bairroSelecionado) {
      if (bairroSelecionado != null && bairroSelecionado is Map<String, dynamic>) {
        setState(() {
          _bairroSelecionado = bairroSelecionado;
          _selectedRideType = 'standard';
        });
      }
    });
  }
}
