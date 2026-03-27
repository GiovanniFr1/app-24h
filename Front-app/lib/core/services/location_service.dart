import 'package:dio/dio.dart';

class LocationService {
  final Dio _dio;

  LocationService(this._dio);

  Future<void> updateLocation(double lat, double lng) async {
    await _dio.put(
      '/api/v1/locations/me/',
      data: {'latitude': lat, 'longitude': lng},
    );
  }

  Future<List<Map<String, dynamic>>> getNearbyDrivers() async {
    final res = await _dio.get('/api/v1/locations/nearby/');
    final data = res.data;
    final list = data is List ? data : (data['results'] as List? ?? []);
    return list.whereType<Map<String, dynamic>>().toList();
  }
}
