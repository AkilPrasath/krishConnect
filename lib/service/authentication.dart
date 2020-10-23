import 'package:firebase_auth/firebase_auth.dart';
import 'package:krish_connect/data/enums.dart';

class Authentication {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //
  Future<SignupResult> signUp(String email, String password) async {
    try {
      UserCredential userCred;

      userCred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (ex) {
      if (ex.runtimeType == FirebaseAuthException) {
        String errorCode = ex.code.toString().replaceAll("-", "");

        SignupResult authResult = SignupResult.values.map((e) {
          if (e.toString() == "SignupResult." + errorCode) {
            return e;
          }
        }).toList()[0];
        return authResult;
      }
    }
    return SignupResult.success;
  }

  signIn(String email, String password) async {
    try {
      UserCredential userCred = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (ex) {
      if (ex.runtimeType == FirebaseAuthException) {
        String errorCode = ex.code.toString().replaceAll("-", "");

        LoginResult authResult = LoginResult.values.map((e) {
          if (e.toString() == "LoginResult." + errorCode) {
            return e;
          }
        }).toList()[0];
        return authResult;
      }
    }
    return LoginResult.success;
  }
}
