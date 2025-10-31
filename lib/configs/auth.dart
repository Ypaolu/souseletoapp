import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String?> registrar({
    required String email,
    required String senha,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return 'Sucesso';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Senha fraca. Escolha uma senha mais forte.';
      } else if (e.code == 'email-already-in-use') {
        return 'Já existe uma conta para esse email.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String senha,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return 'Successo!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {

        return 'Credenciais inválidas. Verifique seu email e/ou senha.';

      } else if (e.code == 'invalid-email') {
        return 'O formato do email é inválido.';
      } else {
        return e.message ?? 'Erro desconhecido durante o login.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return 'Logout bem-sucedido!';
    } catch (e) {
      return e.toString();
    }
  }
}