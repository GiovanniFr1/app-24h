import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/providers/service_providers.dart';
import '../core/models/trip_model.dart';
import '../shared/widgets/nova_corrida_alert.dart';
import 'driver_earnings_screen.dart';
import 'login_screen.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

enum DriverStatus { offline, online, aCaminho, embarque, emViagem }

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  DriverStatus _driverStatus = DriverStatus.offline;
  GoogleMapController? _mapController;
  double _mapBottomPadding = 0;

  double _ganhosHoje = 0.0;
  final List<String> _historicoModalidades = [];

  int? _currentTripId;
  Trip? _currentTripData;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const String _grayMapStyle = '''[
    {
      "stylers": [
        {"saturation": -100},
        {"lightness": 20}
      ]
    }
  ]''';

  static const LatLng _origem = LatLng(-9.97499, -67.8243);
  static const LatLng _destino = LatLng(-9.9488, -67.7915);

  static const CameraPosition _initialPosition = CameraPosition(
    target: _origem,
    zoom: 13.5,
  );

  Future<void> _buscarEMostrarCorrida() async {
    Trip? trip;

    try {
      final tripService = ref.read(tripServiceProvider);
      final trips = await tripService.getTrips();
      trip = trips.firstWhere(
        (t) => t.isPending,
        orElse: () => throw Exception('Nenhuma viagem pendente'),
      );
    } catch (_) {
      // Sem trips pendentes no backend – usa dados de exemplo
    }

    _mostrarNovaCorrida(trip);
  }

  Set<Circle> get _activeHeatmapCircles {
    if (_driverStatus != DriverStatus.online || _currentTripId != null) {
      return {};
    }

    return {
      Circle(
        circleId: const CircleId('zonaQuente1'),
        center: LatLng(-9.9695, -67.8220),
        radius: 450,
        fillColor: const Color(0x44FFD54F),
        strokeColor: const Color(0x88FFC107),
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('zonaQuente2'),
        center: LatLng(-9.9810, -67.8320),
        radius: 520,
        fillColor: const Color(0x44FF8F00),
        strokeColor: const Color(0x88FFB300),
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('zonaQuente3'),
        center: LatLng(-9.9660, -67.8380),
        radius: 380,
        fillColor: const Color(0x4491D500),
        strokeColor: const Color(0x8894D500),
        strokeWidth: 2,
      ),
    };
  }

  Widget _buildDriverActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primary,
          foregroundColor: foregroundColor ?? AppTheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
        ),
        icon: Icon(icon, size: 24),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onPressed,
      ),
    );
  }

  void _mostrarNovaCorrida(Trip? trip) {
    setState(() {
      _mapBottomPadding = 380.0;
      _markers.clear();
      _polylines.clear();

      _markers.add(
        Marker(
          markerId: const MarkerId('origem'),
          position: _origem,
          infoWindow: const InfoWindow(title: 'Passageiro'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
      _markers.add(
        const Marker(
          markerId: MarkerId('destino'),
          position: _destino,
          infoWindow: InfoWindow(title: 'Destino: Taquari'),
        ),
      );
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('rota'),
          points: const [_origem, _destino],
          color: AppTheme.primary,
          width: 4,
          geodesic: true,
        ),
      );
    });

    if (_mapController != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _origem.latitude < _destino.latitude
              ? _origem.latitude
              : _destino.latitude,
          _origem.longitude < _destino.longitude
              ? _origem.longitude
              : _destino.longitude,
        ),
        northeast: LatLng(
          _origem.latitude > _destino.latitude
              ? _origem.latitude
              : _destino.latitude,
          _origem.longitude > _destino.longitude
              ? _origem.longitude
              : _destino.longitude,
        ),
      );
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: NovaCorridaAlert(
          distancia: trip != null
              ? '${trip.price.toStringAsFixed(1)} km'
              : '4.2 km',
          tempo: '12 min',
          valor: trip != null
              ? 'R\$ ${trip.price.toStringAsFixed(2).replaceAll('.', ',')}'
              : 'R\$ 18,50',
          origem: 'Embarque: ${trip?.origin ?? 'Centro'} (a 800m)',
          destino: 'Destino: ${trip?.destination ?? 'Taquari'}',
          onAccept: () async {
            Navigator.pop(context);
            final messenger = ScaffoldMessenger.of(context);

            if (trip != null) {
              try {
                await ref.read(tripServiceProvider).acceptTrip(trip.id);
                _currentTripId = trip.id;
                _currentTripData = trip;
              } catch (_) {
                _currentTripId = null;
              }
            }

            setState(() {
              _driverStatus = DriverStatus.aCaminho;
              _mapBottomPadding = 260.0;
            });
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Corrida Aceita! Siga até o passageiro.'),
              ),
            );
          },
          onDecline: () {
            Navigator.pop(context);
            setState(() {
              _markers.clear();
              _polylines.clear();
              _mapBottomPadding = 0;
            });
            if (_mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(_initialPosition),
              );
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viagem recusada. Procurando outra...'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _iniciarCorrida() async {
    if (_currentTripId != null) {
      try {
        await ref.read(tripServiceProvider).startTrip(_currentTripId!);
      } catch (_) {}
    }
    setState(() => _driverStatus = DriverStatus.emViagem);
  }

  Future<void> _finalizarCorrida() async {
    double valorGanho = 18.50;

    if (_currentTripId != null) {
      try {
        final completed = await ref
            .read(tripServiceProvider)
            .completeTrip(_currentTripId!);
        valorGanho = completed.price > 0 ? completed.price : 18.50;
      } catch (_) {}
    }

    setState(() {
      _driverStatus = DriverStatus.online;
      _mapBottomPadding = 0;
      _ganhosHoje += valorGanho;
      _historicoModalidades.insert(
        0,
        valorGanho > 20 ? 'Moto Comfort' : 'Moto Standard',
      );
      _markers.clear();
      _polylines.clear();
      _currentTripId = null;
      _currentTripData = null;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceContainerLow,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.attach_money, color: AppTheme.tertiary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Corrida Finalizada',
                    style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                  ),
                  Text(
                    '+ R\$ ${valorGanho.toStringAsFixed(2).replaceAll('.', ',')} adicionados!',
                    style: GoogleFonts.inter(
                      color: AppTheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await ref.read(authServiceProvider).logout();
    } catch (_) {}
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              colors: [AppTheme.background, Colors.transparent],
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              backgroundColor: AppTheme.surfaceContainerHigh.withValues(
                alpha: 0.8,
              ),
              child: const Icon(Icons.menu, color: AppTheme.primaryContainer),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Moto Acre',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: AppTheme.primaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: _mapBottomPadding),
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            style: _driverStatus == DriverStatus.offline ? _grayMapStyle : null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polylines,
            circles: _activeHeatmapCircles,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverEarningsScreen(
                            ganhosTotais: _ganhosHoje,
                            historicoModalidades: _historicoModalidades,
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerHigh.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppTheme.primaryContainer.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'R\$ ${_ganhosHoje.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _driverStatus != DriverStatus.offline
                                    ? 'Você está Online'
                                    : 'Você está Offline',
                                style: GoogleFonts.inter(
                                  color: _driverStatus != DriverStatus.offline
                                      ? AppTheme.tertiary
                                      : AppTheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Switch(
                                value: _driverStatus != DriverStatus.offline,
                                activeThumbColor: AppTheme.tertiary,
                                activeTrackColor: AppTheme.tertiary.withValues(
                                  alpha: 0.3,
                                ),
                                inactiveThumbColor: AppTheme.onSurfaceVariant,
                                inactiveTrackColor:
                                    AppTheme.surfaceContainerHighest,
                                onChanged: (value) {
                                  if (_driverStatus == DriverStatus.aCaminho ||
                                      _driverStatus == DriverStatus.embarque ||
                                      _driverStatus == DriverStatus.emViagem) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Finalize a viagem antes de ficar offline.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _driverStatus = value
                                        ? DriverStatus.online
                                        : DriverStatus.offline;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Align(alignment: Alignment.bottomCenter, child: _buildBottomCard()),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border(
              top: BorderSide(
                color: AppTheme.outlineVariant.withValues(alpha: 0.1),
              ),
            ),
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
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 32,
                left: 24,
                right: 24,
              ),
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
                  if (_driverStatus == DriverStatus.offline ||
                      _driverStatus == DriverStatus.online)
                    ..._buildAguardandoState()
                  else if (_driverStatus == DriverStatus.aCaminho)
                    ..._buildACaminhoState()
                  else if (_driverStatus == DriverStatus.embarque)
                    ..._buildEmbarqueState()
                  else if (_driverStatus == DriverStatus.emViagem)
                    ..._buildEmViagemState(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAguardandoState() {
    return [
      Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: _driverStatus == DriverStatus.online
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.radar,
          color: _driverStatus == DriverStatus.online
              ? AppTheme.primary
              : AppTheme.onSurfaceVariant,
          size: 40,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        _driverStatus == DriverStatus.online
            ? 'Aguardando solicitações...'
            : 'Fique online para receber viagens',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        _driverStatus == DriverStatus.online
            ? 'Seu carro está visível para passageiros em Rio Branco.'
            : 'Você não receberá chamados no momento.',
        style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
      if (_driverStatus == DriverStatus.offline) ...[
        const SizedBox(height: 24),
        _buildDriverActionButton(
          text: 'GO',
          icon: Icons.power_settings_new,
          onPressed: () {
            setState(() => _driverStatus = DriverStatus.online);
          },
        ),
      ] else ...[
        const SizedBox(height: 24),
        Text(
          'Zonas quentes são destacadas no mapa enquanto você estiver online.',
          style: GoogleFonts.inter(
            color: AppTheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildDriverActionButton(
          text: 'Simular Chamado',
          icon: Icons.notifications_active,
          onPressed: _buscarEMostrarCorrida,
        ),
      ],
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildACaminhoState() {
    final passengerName = _currentTripData?.origin ?? 'Beto Barros';
    final pickupLocation =
        'Embarque: ${_currentTripData?.origin ?? 'Centro'} (a 800m)';

    return [
      Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buscando $passengerName',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  pickupLocation,
                  style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      _buildDriverActionButton(
        text: 'CHEGUEI NO LOCAL',
        icon: Icons.location_pin,
        onPressed: () => setState(() => _driverStatus = DriverStatus.embarque),
      ),
    ];
  }

  List<Widget> _buildEmbarqueState() {
    return [
      Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: AppTheme.secondaryContainer.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.hail,
          color: AppTheme.secondaryContainer,
          size: 40,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Aguardando embarque...',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        'Tempo de espera do passageiro: 01:20',
        style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      _buildDriverActionButton(
        text: 'INICIAR CORRIDA',
        icon: Icons.play_arrow,
        onPressed: _iniciarCorrida,
      ),
    ];
  }

  List<Widget> _buildEmViagemState() {
    final dest = _currentTripData?.destination ?? 'Taquari';

    return [
      Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.flag, color: AppTheme.tertiary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Faltam 4.2 km (aprox. 12 min)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  'Destino: $dest',
                  style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      _buildDriverActionButton(
        text: 'FINALIZAR CORRIDA',
        icon: Icons.check_circle,
        onPressed: _finalizarCorrida,
      ),
    ];
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surfaceContainerLow,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.background),
            accountName: Text(
              'João (Motorista)',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'Honda CG 160 • ABC-1234',
              style: GoogleFonts.inter(),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryContainer, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: AppTheme.surfaceContainerHigh,
                child: Icon(
                  Icons.person,
                  color: AppTheme.onSurfaceVariant,
                  size: 40,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppTheme.error),
            title: Text(
              'Sair',
              style: GoogleFonts.inter(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
