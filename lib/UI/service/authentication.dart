import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  signUp(String email, String password) async {
    try {
      UserCredential userCred =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: "akilprasathr@gmail.com", password: password);
    } catch (ex) {
      if (ex.runtimeType == FirebaseAuthException) {
        print(ex.code);
        print("do");
      }
    }
    print("end");
  }
}
