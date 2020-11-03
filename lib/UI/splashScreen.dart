import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:krish_connect/UI/dashboard/dashboardScreen.dart';
import 'package:krish_connect/UI/detailsScreen.dart';
import 'package:krish_connect/UI/emailVerify.dart';
import 'package:krish_connect/UI/login.dart';

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
          Student student = await getIt.getAsync<Student>();

          if (!student.isEmpty) {
            Navigator.pushReplacementNamed(context, DashboardScreen.id);
          } else {
            Navigator.pushReplacementNamed(context, DetailsScreen.id);
          }
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
