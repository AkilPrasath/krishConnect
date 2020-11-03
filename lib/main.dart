import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:krish_connect/UI/dashboard/dashboardScreen.dart';
import 'package:krish_connect/UI/detailsScreen.dart';
import 'package:krish_connect/UI/emailVerify.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/requestsStudent.dart';
import 'package:krish_connect/UI/signup.dart';
import 'package:krish_connect/UI/splashScreen.dart';
import 'package:krish_connect/data/student.dart';

import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: SplashScreen.id,
    routes: {
      SplashScreen.id: (context) => SplashScreen(),
      SignupScreen.id: (context) => SignupScreen(),
      LoginScreen.id: (context) => LoginScreen(),
      DetailsScreen.id: (context) => DetailsScreen(),
      VerifyEmailScreen.id: (context) => VerifyEmailScreen(),
      DashboardScreen.id: (context) => DashboardScreen(),
      RequestStudent.id: (context) => RequestStudent(),
    },
  ));
}

GetIt getIt = GetIt.instance;
void setupLocator() {
  getIt.registerSingleton(Authentication());
  getIt.registerSingleton(Database());

  getIt.registerLazySingletonAsync<Student>(() async {
    return Student.create(
        getIt<Authentication>().currentUser.email.substring(0, 9));
  });
}
