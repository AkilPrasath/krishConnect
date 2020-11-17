import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard.dart';

import 'package:krish_connect/UI/staff/staffDetailsScreen.dart';
import 'package:krish_connect/UI/student/dashboard/dashboardScreen.dart';
import 'package:krish_connect/UI/student/studentDetailsScreen.dart';
import 'package:krish_connect/UI/emailVerify.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/data/staff.dart';

import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';

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
    Future.delayed(Duration(milliseconds: 300)).then((value) async {
      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      } else {
        if (currentUser.emailVerified) {
          String email = currentUser.email;
          RegExp studentRegex = RegExp(r"[0-9]{2}[a-zA-Z]{4}[0-9]{3}");
          if (studentRegex.stringMatch(email) == null) {
            //staff
            Staff staff = await getIt.getAsync<Staff>();
            if (!staff.isEmpty) {
              Navigator.pushReplacementNamed(context, StaffDashboard.id);
            } else {
              Navigator.pushReplacementNamed(context, StaffDetailsScreen.id);
            }
          } else if (studentRegex.stringMatch(email).length == email.length) {
            //  student
            Student student = await getIt.getAsync<Student>();
            if (!student.isEmpty) {
              Navigator.pushReplacementNamed(context, DashboardScreen.id);
            } else {
              Navigator.pushReplacementNamed(context, StudentDetailsScreen.id);
            }
          }
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
            child: Hero(
              tag: Key("appLogo"),
              child: Text(
                "Krish Connect",
                style: GoogleFonts.josefinSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
