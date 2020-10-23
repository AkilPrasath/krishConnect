import 'package:firebase_auth/firebase_auth.dart';

enum SignupResult {
  emailalreadyinuse,
  invalidemail,
  operationnotallowed,
  weakpassword, //less than 6 chars
  success,
}

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
          // print(e.toString() + " " + errorCode);
          if (e.toString() == "SignupResult." + errorCode) {
            return e;
          }
        }).toList()[0];
        return authResult;
      }
    }
    return SignupResult.success;
  }
}
