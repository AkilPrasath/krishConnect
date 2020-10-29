import 'package:firebase_auth/firebase_auth.dart';
import 'package:krish_connect/data/enums.dart';

class Authentication {
  UserCredential userCred;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //
  Future<SignupResult> signUp(String email, String password) async {
    try {
      // UserCredential userCred;

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

  Future<bool> sendVerification() async {
    try {
      await userCred.user.sendEmailVerification();
      print("Link is sent");
      return true;
    } catch (e) {
      print("An error occured while trying to send email        verification");
      print(e);
      return false;
    }
    print("link is not sent");
    return false;
  }

  Future<bool> checkEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    await user.reload();
    print(user.emailVerified);
    if (user.emailVerified) {
      return true;
    } else {
      return false;
    }
  }

  Future<LoginResult> signIn(String email, String password) async {
    try {
      UserCredential userCred = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (ex) {
      if (ex.runtimeType == FirebaseAuthException) {
        String errorCode = ex.code.toString().replaceAll("-", "");

        List<LoginResult> authResult = LoginResult.values.map((e) {
          if (e.toString() == "LoginResult." + errorCode) {
            print(e);
            return e;
          }
        }).toList();
        LoginResult authRes;
        authResult.forEach((element) {
          if (element != null) {
            authRes = element;
          }
        });
        return authRes;
      }
    }
    return LoginResult.success;
  }
}
