import 'package:firebase_auth/firebase_auth.dart';
import 'package:krish_connect/data/enums.dart';

class Authentication {
  // UserCredential userCred;
  User currentUser;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Authentication() {
    currentUser = _firebaseAuth.currentUser;
  }

  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser.reload();
    currentUser = _firebaseAuth.currentUser;
    return Future.value(1);
  }

  Future<void> logoutUser() async {
    await _firebaseAuth.signOut();
    // await reloadUser();
    return Future.value(1);
  }

  Future<SignupResult> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
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
      await reloadUser();
      await currentUser.sendEmailVerification();
      print("Link is sent");
      return true;
    } catch (e) {
      print("An error occured while trying to send email        verification");
      print(e);
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    await reloadUser();
    print(currentUser.emailVerified);
    if (currentUser.emailVerified) {
      return true;
    } else {
      return false;
    }
  }

  Future<LoginResult> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
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
