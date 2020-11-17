import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard.dart';
import 'package:krish_connect/UI/student/dashboard/dashboardScreen.dart';

import 'package:krish_connect/UI/student/studentDetailsScreen.dart';
import 'package:krish_connect/UI/emailVerify.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/student/requestsStudent.dart';
import 'package:krish_connect/UI/signup.dart';
import 'package:krish_connect/UI/splashScreen.dart';
import 'package:krish_connect/UI/staff/staffDetailsScreen.dart';
import 'package:krish_connect/UI/student/viewAllAnnouncements.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/service/Geofencing.dart';

import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/staffDatabase.dart';
import 'package:krish_connect/service/studentDatabase.dart';

const EVENTS_KEY = "fetch_events";
void backgroundFetchHeadlessTask(String taskId) async {
  print("Akil Headless event received: $taskId");
  Geofencing fence = Geofencing();
  FirebaseApp firebaseApp;
  if (Firebase.app() == null) {
    firebaseApp = await Firebase.initializeApp();
  }
  await fence.updateLocationCallback();
  await firebaseApp.delete();
  BackgroundFetch.finish(taskId);

  if (taskId == 'flutter_background_fetch') {
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 5000,
        periodic: false,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseApp firebaseApp = await Firebase.initializeApp();
  setupLocator();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: SplashScreen.id,
    routes: {
      SplashScreen.id: (context) => SplashScreen(),
      SignupScreen.id: (context) => SignupScreen(),
      LoginScreen.id: (context) => LoginScreen(),
      StudentDetailsScreen.id: (context) => StudentDetailsScreen(),
      VerifyEmailScreen.id: (context) => VerifyEmailScreen(),
      DashboardScreen.id: (context) => DashboardScreen(),
      RequestStudent.id: (context) => RequestStudent(),
      ViewAllAnnouncementPage.id: (context) => ViewAllAnnouncementPage(),
      StaffDetailsScreen.id: (context) => StaffDetailsScreen(),
      StaffDashboard.id: (context) => StaffDashboard(),
    },
  ));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

GetIt getIt = GetIt.instance;
void setupLocator() {
  getIt.registerSingleton(Authentication());
  getIt.registerSingleton(StudentDatabase());
  getIt.registerSingleton(StaffDatabase());

  getIt.registerLazySingletonAsync<Student>(() async {
    return Student.create(
        getIt<Authentication>().currentUser.email.substring(0, 9));
  });
  getIt.registerLazySingletonAsync<Staff>(() async {
    return Staff.create(
        getIt<Authentication>().currentUser.email.split("@")[0]);
  });
}
