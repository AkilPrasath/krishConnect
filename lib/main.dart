import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:krish_connect/UI/detailsScreen.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/signup.dart';

import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: DetailsScreen.id,
    routes: {
      SignupScreen.id: (context) => SignupScreen(),
      LoginScreen.id: (context) => LoginScreen(),
      DetailsScreen.id: (context) => DetailsScreen(),
    },
  ));
}

GetIt getIt = GetIt.instance;
void setupLocator() {
  getIt.registerSingleton(Authentication());
  getIt.registerSingleton(Database());

  // getIt.registerLazySingleton<Future<Person>>(() async {
  //   return await Person.create();
  // });
}
