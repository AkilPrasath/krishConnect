import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:krish_connect/UI/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: SignupScreen.id,
    routes: {
      SignupScreen.id: (context) => SignupScreen(),
    },
  ));
}
