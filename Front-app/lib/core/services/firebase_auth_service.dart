import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Auth Service focado unicamente na obtenção de credenciais de login
/// (Secure Identity Provider). 
/// Qualquer lógica de negócio (como 'getUserProfile' e 'isDriver') foi 
/// transferida para o Backend Django para respeitar a arquitetura "Single Source of Truth".
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Obtenção do usuário logado localmente na SDK do Firebase.
  User? get currentUser => _auth.currentUser;

  /// Stream reativa para escutar mudanças no status primário do celular.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gera e atualiza obrigatoriamente (forceRefresh) um ID Token JWT 
  /// puro e verificado pelas chaves do Google.
  /// Este é o Token que seu App usará no Header para autenticar e consumir 
  /// a Web API Rest Python/Django.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  /// Inicia a validação física do Número de Celular disparando OTP.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
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

  /// Verifica o Código SMS recebido.
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

  /// Tela de Consentimento Social com a Google.
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

  /// Logon tradicional com Credencial Fixa.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Cadastro tradicional limpo. Os dados adicionais (Nome, CPF, Veículo)
  /// deverão ser enviados na rota POST /api/v1/users/register do Backend Django.
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Limpa cache e desloga localmente a sessão do aparelho.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
