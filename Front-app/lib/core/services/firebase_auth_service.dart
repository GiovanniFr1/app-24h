import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final snapshot = await _usersCollection.doc(user.uid).get();
    return snapshot.data();
  }

  Future<bool> hasUserProfile() async {
    final user = currentUser;
    if (user == null) return false;
    final snapshot = await _usersCollection.doc(user.uid).get();
    return snapshot.exists;
  }

  Future<bool?> isDriver() async {
    final profile = await getUserProfile();
    if (profile == null) return null;
    final isDriver = profile['is_driver'] as bool?;
    final role = profile['role'] as String?;
    return isDriver ?? role?.toLowerCase() == 'driver';
  }

  Future<void> _callSetRole({
    required String role,
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated Firebase user available.',
      );
    }

    final idToken = await user.getIdToken();
    final body = {
      'data': {
        'role': role,
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone': phoneNumber,
      },
    };

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://us-central1-app-acre-24h.cloudfunctions.net',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      ),
    );

    try {
      final response = await dio.post('/setRole', data: body);
      if (response.statusCode != 200) {
        final responseBody = response.data is String
            ? response.data
            : jsonEncode(response.data);
        throw FirebaseAuthException(
          code: 'backend-failed',
          message: 'setRole failed (${response.statusCode}): $responseBody',
        );
      }
    } on DioException catch (error) {
      final responseBody = error.response?.data ?? error.message;
      throw FirebaseAuthException(
        code: 'backend-failed',
        message: 'setRole failed: $responseBody',
      );
    }
  }

  Future<void> createUserProfile({
    required String name,
    required String role,
    String? email,
    String? phoneNumber,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated Firebase user available.',
      );
    }

    final finalEmail = email?.isNotEmpty == true ? email : user.email;
    await _callSetRole(
      role: role,
      name: name,
      email: finalEmail,
      phoneNumber: phoneNumber ?? user.phoneNumber,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
