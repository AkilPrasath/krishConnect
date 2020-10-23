import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/UI/service/authentication.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/rocketButton.dart';
import 'package:krish_connect/widgets/signupTextField.dart';

class SignupScreen extends StatefulWidget {
  static final String id = "Signup Screen";
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  double screenWidth;
  double screenHeight;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: AppBackground(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "Krish Connect",
                    style: GoogleFonts.josefinSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "Create\nAccount",
                    style: GoogleFonts.aBeeZee(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Form(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: SignupTextField(
                            isEmail: true,
                            isPassword: false,
                            labelText: "Email",
                          ),
                        ),
                        SizedBox(
                          height: 0.03 * screenHeight,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: SignupTextField(
                            isEmail: false,
                            isPassword: true,
                            labelText: "Password",
                          ),
                        ),
                        SizedBox(
                          height: 0.05 * screenHeight,
                        ),
                        RocketButton(
                          screenWidth: screenWidth,
                          onTap: () async {
                            print("WTF");
                            await Authentication()
                                .signUp("dfs", "dfsdfdfafdsffadsf");
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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
