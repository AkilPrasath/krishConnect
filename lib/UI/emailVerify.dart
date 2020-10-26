import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/database.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

class VerifyEmailScreen extends StatefulWidget {
  VerifyEmailScreen({@required authenticate});
  Authentication authenticate;
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  double screenHeight, screenWidth;
  bool isButtonDisabled = true, checkLinkSent = false;
  String validityText = "", errorText = "";
  int flag;
  bool load=true;
  @override
  Widget build(BuildContext context) {
    flag = 0;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (checkLinkSent) {
      emailVerifyProcess();
      checkLinkSent=false;
    }
    return SafeArea(
      child: AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "Verify Your\n   E-mail",
                    style: GoogleFonts.aBeeZee(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                //mail loading json
                Center(child:Lottie.asset("assets/lottie/mailLoading.json")),
                SizedBox(height: 0.2 * screenWidth),
                Text(
                  "Click the Button to recieve\n    E-mail Verification link",
                  style: GoogleFonts.lato(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 0.1 * screenWidth,
                ),
                GestureDetector(
                  onTap: () async {
                    if(isButtonDisabled)
                    if (await getIt<Authentication>().sendVerification()) {
                      setState(() {
                        isButtonDisabled = false;
                        validityText = "Link will become invalid in 1 minute";
                        checkLinkSent = true;
                      });
                    } else {
                      errorText = "Some error occurred. Try after some time";
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
          screenWidth: screenWidth,
          screenHeight: screenHeight),
    );
  }

  emailVerifyProcess() async{
    for (int i = 0; i < 20; i++) {
      sleep(Duration(seconds: 3));
      bool check=await getIt<Authentication>().checkEmailVerified();
      if (check) {
        print("whattttttttttttttttttttttttttttttttttttt");
        flag=1;
        break;
      }
    }
    if(flag==1){
      Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
    }
    else{
      setState(() {
        isButtonDisabled=true;
        validityText="";
        errorText="";
      });
    }
  }
}
