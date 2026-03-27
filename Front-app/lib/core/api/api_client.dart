import 'package:dio/dio.dart';
import 'token_storage.dart';

// Linux desktop / iOS Simulator / web: localhost
// Emulador Android: 10.0.2.2
// Dispositivo físico: IP da máquina na rede (ex: 192.168.1.x)
const String kBaseUrl = 'http://localhost:8000';

Dio createApiClient(TokenStorage tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await tokenStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: kBaseUrl));
              final response = await refreshDio.post(
                '/api/v1/users/token/refresh/',
                data: {'refresh': refreshToken},
              );
              final newAccess = response.data['access'] as String;
              final isDriver = await tokenStorage.getIsDriver();
              await tokenStorage.saveSession(
                access: newAccess,
                refresh: refreshToken,
                isDriver: isDriver,
              );
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccess';
              final retryResponse = await dio.fetch(error.requestOptions);
              handler.resolve(retryResponse);
              return;
            } catch (_) {
              await tokenStorage.clearSession();
            }
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}
