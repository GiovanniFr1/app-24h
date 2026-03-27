import 'package:dio/dio.dart';
import '../models/trip_model.dart';

class TripService {
  final Dio _dio;

  TripService(this._dio);

  Future<Trip> requestTrip({
    required String origin,
    required String destination,
    required double price,
  }) async {
    final res = await _dio.post(
      '/api/v1/trips/request/',
      data: {
        'origin': origin,
        'destination': destination,
        'price': price,
      },
    );
    return Trip.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Trip> getTrip(int id) async {
    final res = await _dio.get('/api/v1/trips/$id/');
    return Trip.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Trip>> getTrips() async {
    final res = await _dio.get('/api/v1/trips/');
    final data = res.data;
    final list = data is List ? data : (data['results'] as List? ?? []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Trip.fromJson)
        .toList();
  }

  Future<Trip> acceptTrip(int id) async {
    final res = await _dio.post('/api/v1/trips/$id/accept/');
    return Trip.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Trip> startTrip(int id) async {
    final res = await _dio.post('/api/v1/trips/$id/start/');
    return Trip.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Trip> completeTrip(int id) async {
    final res = await _dio.post('/api/v1/trips/$id/complete/');
    return Trip.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Trip> cancelTrip(int id) async {
    final res = await _dio.post('/api/v1/trips/$id/cancel/');
    return Trip.fromJson(res.data as Map<String, dynamic>);
  }
}
