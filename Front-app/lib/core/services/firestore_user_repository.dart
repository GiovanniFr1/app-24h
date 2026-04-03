import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_auth_service.dart';

/// Repositório Firebase-only — toda lógica de role passa pelas Cloud Functions.
class FirestoreUserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuthService _auth;

  FirestoreUserRepository({required FirebaseAuthService auth}) : _auth = auth;

  /// Obtém o perfil do usuário via Cloud Function `getMyProfile`.
  /// Nunca lê Firestore diretamente para checar role.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final callable = _functions.httpsCallable('getMyProfile');
    final result = await callable.call();
    if (result.data == null) return null;
    return Map<String, dynamic>.from(result.data as Map);
  }

  /// Chama a Cloud Function `setRole` para definir a role do usuário.
  /// Também aplica custom claims no Firebase Auth token.
  /// Roles válidas: "passenger", "driver", "admin".
  Future<void> setRole(String role, {String? cpf, String? cnh}) async {
    final callable = _functions.httpsCallable('setRole');
    await callable.call(<String, dynamic>{
      'role': role,
      if (cpf != null && cpf.isNotEmpty) 'cpf': cpf,
      if (cnh != null && cnh.isNotEmpty) 'cnh': cnh,
    });
  }

  /// Atualiza campos adicionais do perfil diretamente no Firestore.
  Future<void> updateProfile({String? name, String? phone}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final data = <String, dynamic>{};
    if (name != null && name.isNotEmpty) data['name'] = name;
    if (phone != null && phone.isNotEmpty) data['phone'] = phone;
    if (data.isNotEmpty) {
      await _db.collection('users').doc(user.uid).set(
        data,
        SetOptions(merge: true),
      );
    }
  }
}
