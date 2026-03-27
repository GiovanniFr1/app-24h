import 'package:dio/dio.dart';
import '../api/token_storage.dart';

class AuthService {
  final Dio _dio;
  final TokenStorage _storage;

  AuthService(this._dio, this._storage);

  /// Retorna o perfil do usuário logado, ou null se não autenticado
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final loginRes = await _dio.post(
      '/api/v1/users/login/',
      data: {'email': email, 'password': password},
    );

    final access = loginRes.data['access'] as String;
    final refresh = loginRes.data['refresh'] as String;

    // Salva tokens temporariamente para poder chamar profile
    await _storage.saveSession(
      access: access,
      refresh: refresh,
      isDriver: false,
    );

    // Busca perfil para saber se é motorista
    final profileRes = await _dio.get('/api/v1/users/profile/');
    final profile = profileRes.data as Map<String, dynamic>;

    final isDriver = profile['is_driver'] as bool? ??
        profile['driver'] != null ||
        profile['role'] == 'driver';

    final userName = profile['name'] as String? ??
        profile['username'] as String? ??
        profile['first_name'] as String?;

    await _storage.saveSession(
      access: access,
      refresh: refresh,
      isDriver: isDriver,
      userName: userName,
      userEmail: email,
    );

    return {
      ...profile,
      'is_driver': isDriver,
    };
  }

  Future<void> logout() async {
    try {
      final refresh = await _storage.getRefreshToken();
      if (refresh != null) {
        await _dio.post(
          '/api/v1/users/logout/',
          data: {'refresh': refresh},
        );
      }
    } catch (_) {
      // Mesmo se o backend falhar, limpa sessão local
    } finally {
      await _storage.clearSession();
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final res = await _dio.get('/api/v1/users/profile/');
    return res.data as Map<String, dynamic>;
  }
}
