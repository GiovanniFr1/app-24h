import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

enum RideRequestStatus {
  initial,
  searching,
  accepted,
  driverArrived,
  inTransit,
  completed,
  error,
}

class RideRequestState {
  final RideRequestStatus status;
  final Map<String, dynamic>? driverInfo;
  final int? tripId;
  final String? errorMessage;

  const RideRequestState({
    required this.status,
    this.driverInfo,
    this.tripId,
    this.errorMessage,
  });

  RideRequestState copyWith({
    RideRequestStatus? status,
    Map<String, dynamic>? driverInfo,
    int? tripId,
    String? errorMessage,
  }) {
    return RideRequestState(
      status: status ?? this.status,
      driverInfo: driverInfo ?? this.driverInfo,
      tripId: tripId ?? this.tripId,
      errorMessage: errorMessage,
    );
  }
}

class RideRequestNotifier extends Notifier<RideRequestState> {
  Timer? _pollingTimer;

  @override
  RideRequestState build() {
    ref.onDispose(() => _pollingTimer?.cancel());
    return const RideRequestState(status: RideRequestStatus.initial);
  }

  Future<void> requestRide({
    required String origin,
    required String destination,
    required double price,
  }) async {
    state = state.copyWith(status: RideRequestStatus.searching);

    // MOCK: Simular requisição aceita no frontend sem o backend.
    Future.delayed(const Duration(seconds: 3), () {
      if (state.status != RideRequestStatus.searching) return;
      state = state.copyWith(tripId: 999);
      _startMockedStatePolling();
    });
  }

  void _startMockedStatePolling() {
    _pollingTimer?.cancel();
    int cycle = 0;
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final current = state.status;
      if (current == RideRequestStatus.initial ||
          current == RideRequestStatus.completed ||
          current == RideRequestStatus.error) {
        _pollingTimer?.cancel();
        return;
      }

      cycle++;
      
      if (cycle == 1) {
        state = state.copyWith(
          status: RideRequestStatus.accepted,
          driverInfo: {
            'name': 'Carlos Silva',
            'vehicle': 'Honda NXR 160 Bros • QXY-7788',
            'photoUrl': 'https://i.pravatar.cc/150?img=11',
            'etaMins': 3,
            'rating': 4.98,
          },
        );
      } else if (cycle == 2) {
        state = state.copyWith(status: RideRequestStatus.driverArrived);
      } else if (cycle == 3) {
        state = state.copyWith(status: RideRequestStatus.inTransit);
      } else if (cycle == 6) {
        // Demora simulada da corrida
        state = state.copyWith(status: RideRequestStatus.completed);
        _pollingTimer?.cancel();
      }
    });
  }

  Future<void> cancelRide() async {
    _pollingTimer?.cancel();
    final tripId = state.tripId;
    state = const RideRequestState(status: RideRequestStatus.initial);
    if (tripId != null) {
      try {
        await ref.read(tripServiceProvider).cancelTrip(tripId);
      } catch (_) {}
    }
  }
}

final rideRequestProvider =
    NotifierProvider<RideRequestNotifier, RideRequestState>(() {
  return RideRequestNotifier();
});
