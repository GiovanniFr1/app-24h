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

    try {
      final tripService = ref.read(tripServiceProvider);
      final trip = await tripService.requestTrip(
        origin: origin,
        destination: destination,
        price: price,
      );

      if (state.status != RideRequestStatus.searching) return;

      state = state.copyWith(tripId: trip.id);
      _startPolling(trip.id);
    } catch (e) {
      state = RideRequestState(
        status: RideRequestStatus.error,
        errorMessage: 'Não foi possível solicitar a viagem. Verifique a conexão.',
      );
    }
  }

  void _startPolling(int tripId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final current = state.status;
      if (current == RideRequestStatus.initial ||
          current == RideRequestStatus.completed ||
          current == RideRequestStatus.error) {
        _pollingTimer?.cancel();
        return;
      }

      try {
        final updated = await ref.read(tripServiceProvider).getTrip(tripId);

        if (updated.isCancelled) {
          _pollingTimer?.cancel();
          state = const RideRequestState(
            status: RideRequestStatus.initial,
            errorMessage: 'Viagem cancelada.',
          );
          return;
        }

        if (updated.isCompleted) {
          _pollingTimer?.cancel();
          state = state.copyWith(status: RideRequestStatus.completed);
          return;
        }

        if (updated.isInProgress &&
            current != RideRequestStatus.inTransit &&
            current != RideRequestStatus.driverArrived) {
          state = state.copyWith(
            status: RideRequestStatus.inTransit,
            driverInfo: updated.driver != null
                ? {...updated.driver!.toMap(), 'etaMins': 12}
                : state.driverInfo,
          );
          return;
        }

        if (updated.isAccepted &&
            current == RideRequestStatus.searching &&
            updated.driver != null) {
          state = state.copyWith(
            status: RideRequestStatus.accepted,
            driverInfo: updated.driver!.toMap(),
          );
          return;
        }
      } catch (_) {
        // Ignora falhas de polling isoladas
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
