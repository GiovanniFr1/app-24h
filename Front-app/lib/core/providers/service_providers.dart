import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/token_storage.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/trip_service.dart';
import '../services/location_service.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<Dio>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return createApiClient(storage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.read(apiClientProvider),
    ref.read(tokenStorageProvider),
  );
});

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(ref.read(apiClientProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(ref.read(apiClientProvider));
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});
