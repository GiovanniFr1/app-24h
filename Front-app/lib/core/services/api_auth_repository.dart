import 'package:dio/dio.dart';
import '../../models/kyc_models.dart';
import 'firebase_auth_service.dart';

/// Repositório Backend Seguro - Single Source of Truth 
/// Focado nas restrições pesadas de Mobilidade (EAR, Veículo, Ficha).
class ApiAuthRepository {
  final Dio _dio;
  final FirebaseAuthService _firebaseAuth;

  ApiAuthRepository({
    required FirebaseAuthService firebaseAuth,
  })  : _firebaseAuth = firebaseAuth,
        _dio = Dio(BaseOptions(
          // URL do seu Backend Django
          baseUrl: 'https://seu-backend-django-aqui.com/api/v1', 
        )) {
    // Interceptor para injetar silenciosamente o IDToken do Firebase.
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final idToken = await _firebaseAuth.getIdToken();
        if (idToken != null) {
          options.headers['Authorization'] = 'Bearer $idToken';
        }
        return handler.next(options);
      },
    ));
  }

  /// Cadastro Simplificado do Passageiro.
  /// Contém verificação etária e de CPF ativo.
  Future<Map<String, dynamic>> registerPassenger(
      PassengerRegistrationPayload payload) async {
    
    // Verificações In-Device 
    final frontEndError = payload.validateClientSide();
    if (frontEndError != null) throw Exception(frontEndError);

    try {
      final response = await _dio.post(
        '/auth/register-passenger',
        data: {
          'cpf': payload.cpf,
          'full_name': payload.fullName,
          'email': payload.email,
          'phone': payload.phoneVerified,
          'is_over_18': payload.isOver18,
          'payment_method': payload.defaultPaymentMethod,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Passageiro recusado no servidor: ${e.response?.data ?? e.message}');
    }
  }

  /// Submete os documentos rigorosos do Motorista para OCR e BackOffice.
  /// Protegido pelas regras front-end de PPD e EAR e portas.
  Future<Map<String, dynamic>> registerDriverKyc(
      DriverKycPayload payload) async {
        
    // Corta fluxo sujo se ele tentar inserir CNH Provisória ou Carro Inadequado.
    final frontEndError = payload.validateClientSide();
    if (frontEndError != null) throw Exception(frontEndError);

    try {
      final formData = FormData.fromMap({
        // Pessoais
        'cpf': payload.cpf,
        'full_name': payload.fullyName,
        'phone': payload.phoneVerified,
        'has_ear': payload.hasEar,
        'cnh_type': payload.isDefinitiveCnh ? 'DEFINITIVA' : 'PPD',
        'background_consent': payload.backgroundCheckConsent,
        'cnh_document': await MultipartFile.fromFile(payload.cnhFilePath, filename: 'cnh.jpg'),
        'user_selfie': await MultipartFile.fromFile(payload.selfieFilePath, filename: 'selfie.jpg'),
        
        // Veículo
        'car_year': payload.carYear,
        'car_doors': payload.carDoors,
        'has_ac': payload.hasAc,
        'seat_capacity': payload.seatCapacity,
        'is_not_van': payload.isNotPickupOrVan,
        'crlv_document': await MultipartFile.fromFile(payload.crlvFilePath, filename: 'crlv.pdf'),
      });

      final response = await _dio.post(
        '/auth/driver-kyc',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Rejeição KYC Motorista: ${e.response?.data ?? e.message}');
    }
  }

  /// Buscando o saldo atual de forma atômica para pagamentos no Dashboard.
  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _dio.get('/users/profile');
    return response.data;
  }
}
