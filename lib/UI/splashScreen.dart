import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard_screen.dart';

import 'package:krish_connect/UI/staff/staffDetailsScreen.dart';
import 'package:krish_connect/UI/student/dashboard/student_dashboard_screen.dart';
import 'package:krish_connect/UI/student/studentDetailsScreen.dart';
import 'package:krish_connect/UI/emailVerify.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/data/staff.dart';

import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';
import 'package:logger/logger.dart';

class SplashScreen extends StatefulWidget {
  static final String id = "Splashscreen";
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  checkUser() async {
    User currentUser = getIt<Authentication>().currentUser;
    Logger().e("inside check user");
    Future.delayed(Duration(milliseconds: 300)).then((value) async {
      Logger().e("inside future delayed");
      if (currentUser == null) {
        Logger().e("current user null");
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      } else {
        if (currentUser.emailVerified) {
          Logger().e("current user email verified" + currentUser.email);
          String email = currentUser.email;
          RegExp studentRegex = RegExp(r"[0-9]{2}[a-zA-Z]{4}[0-9]{3}");
          // if (studentRegex.stringMatch(email) == null) {
          if (!studentRegex.hasMatch(email)) {
            //staff
            Logger().e("before staff");
            Staff staff = await getIt.getAsync<Staff>();
            Logger().e("after staff");
            if (!staff.isEmpty) {
              Navigator.pushReplacementNamed(context, StaffDashboardScreen.id);
            } else {
              Navigator.pushReplacementNamed(context, StaffDetailsScreen.id);
            }
            // } else if (studentRegex.stringMatch(email).length == email.length) {
            // } else if (studentRegex.hasMatch(email)) {
          } else {
            //  student
            Logger().e("before student");
            Student student = await getIt.getAsync<Student>();
            Logger().e("after student");
            if (!student.isEmpty) {
              Navigator.pushReplacementNamed(context, DashboardScreen.id);
            } else {
              Navigator.pushReplacementNamed(context, StudentDetailsScreen.id);
            }
          }
          Logger().e("blank");
          //blah

        } else {
          Navigator.pushReplacementNamed(context, VerifyEmailScreen.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  child: Image.asset("assets/images/icon.png"),
                ),
                SizedBox(height: 8),
                Hero(
                  tag: Key("appLogo"),
                  child: Text(
                    "Krish Connect",
                    style: GoogleFonts.josefinSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
