import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    forceCodeForRefreshToken: true,
  );

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> registerWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.sendEmailVerification();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!cred.user!.emailVerified) {
        throw Exception('E-mail não verificado. Verifique sua caixa de entrada.');
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
  try {
    await _googleSignIn.signOut();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCred = await _auth.signInWithCredential(credential);
    return userCred;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception("Usuário não encontrado");
    } else {
      throw Exception("Erro ao entrar com Google: ${e.message}");
    }
  } catch (e) {
    throw Exception("Erro ao fazer login com Google: $e");
  }
}

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'E-mail já cadastrado';
      case 'invalid-email':
        return 'E-mail inválido';
      case 'user-disabled':
        return 'Usuário desativado';
      default:
        return 'Erro: ${e.message}';
    }
  }
}
