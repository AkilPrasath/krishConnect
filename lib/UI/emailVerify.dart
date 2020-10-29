import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/UI/detailsScreen.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/signup.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/database.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

class VerifyEmailScreen extends StatefulWidget {
  static final String id = "Email verify";
  VerifyEmailScreen();

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  double screenHeight, screenWidth;
  bool isButtonDisabled = true, checkLinkSent = false;
  String validityText = "", errorText = "";
  int flag;
  bool load = true;
  @override
  Widget build(BuildContext context) {
    flag = 0;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (checkLinkSent) {
      emailVerifyProcess();
      checkLinkSent = false;
    }
    return SafeArea(
      child: AppBackground(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    print("I am unpoppable");
                  }
                },
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.blue[700],
                  size: 40,
                ),
              ),
              title: Text(
                "Verify Email",
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 24,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            body: Container(
              width: screenWidth,
              height: screenHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  //mail loading json
                  Container(
                    height: screenHeight * 0.4,
                    child: Lottie.asset(
                      "assets/lottie/mailLoading.json",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 0.2 * screenWidth),
                  Text(
                    "Click the Button to recieve\n    E-mail Verification link",
                    style: GoogleFonts.lato(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, LoginScreen.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "Not ${getIt<Authentication>().currentUser.email} ? Sign In with different account",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 0.1 * screenWidth,
                  ),
                  GestureDetector(
                    onTap: () async {
                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.none) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Please Check your Internet Connection!"),
                          duration: Duration(seconds: 2),
                        ));
                        return;
                      }
                      if (isButtonDisabled) if (await getIt<Authentication>()
                          .sendVerification()) {
                        setState(() {
                          isButtonDisabled = false;
                          validityText = "Link will become invalid in 1 minute";
                          checkLinkSent = true;
                        });
                      } else {
                        setState(() {
                          errorText =
                              "Some error occurred. Try after some time";
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      height: 0.1 * screenWidth,
                      width: 0.3 * screenWidth,
                      child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Send Link",
                                style: GoogleFonts.lato(
                                    color: isButtonDisabled
                                        ? Colors.green[400]
                                        : Colors.grey),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: isButtonDisabled
                                    ? Colors.green[400]
                                    : Colors.grey,
                              )
                            ]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    validityText,
                    style: GoogleFonts.lato(
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    errorText,
                    style: GoogleFonts.lato(color: Colors.red, fontSize: 15.0),
                  ),
                ],
              ),
            ),
          ),
          screenWidth: screenWidth,
          screenHeight: screenHeight),
    );
  }

  emailVerifyProcess() async {
    for (int i = 0; i < 40; i++) {
      sleep(Duration(seconds: 3));
      bool check = await getIt<Authentication>().checkEmailVerified();
      if (check) {
        flag = 1;
        break;
      }
    }
    if (flag == 1) {
      await Student.create(
          getIt<Authentication>().currentUser.email.substring(0, 9));
      Navigator.pushReplacementNamed(context, DetailsScreen.id);
    } else {
      setState(() {
        isButtonDisabled = true;
        validityText = "";
        errorText = "";
      });
    }
  }
}
