import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/data/enums.dart';
import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/database.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/rocketButton.dart';
import 'package:krish_connect/widgets/signupTextField.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  static final String id = "Login Screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double screenWidth;
  double screenHeight;
  UserMode userMode;
  String _password, _email;
  bool load = false;
  final _formKey = GlobalKey<FormState>();

  login(context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      LoginResult loginResult =
          await Authentication().signIn(_email, _password);
      if (loginResult == LoginResult.success) {
        //lazy load get_it user instance
        //check data
        // if data is empty go to data page
        // if data is ready go to dashboard page
      }
    }
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
          body: Stack(
            children: [
              Container(
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
                        "Sign\nIn",
                        style: GoogleFonts.aBeeZee(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: SignupTextField(
                                isEmail: true,
                                isPassword: false,
                                labelText: "Email",
                                onSaved: (value) {
                                  _email = value;
                                  RegExp studentRegex =
                                      RegExp(r"[0-9]{2}[a-zA-Z]{4}[0-9]{3}");
                                  if (studentRegex.stringMatch(value) == null) {
                                    userMode = UserMode.staff;
                                  } else if (studentRegex
                                          .stringMatch(value)
                                          .length ==
                                      value.length) {
                                    userMode = UserMode.student;
                                  }
                                },
                                validator: (value) {
                                  RegExp emailRegex =
                                      RegExp(r"^([a-zA-Z0-9_\-\.]+)");

                                  if (!(emailRegex.stringMatch(value).length ==
                                      value.length)) {
                                    return "Check the email format!";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 0.03 * screenHeight,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: SignupTextField(
                                isEmail: false,
                                isPassword: true,
                                labelText: "Password",
                                onSaved: (value) {
                                  _password = value;
                                },
                                validator: (value) {
                                  if (value.length <= 8) {
                                    return "Minimum 8 characters";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 0.05 * screenHeight,
                            ),
                            Builder(builder: (context) {
                              return RocketButton(
                                screenWidth: screenWidth,
                                onTap: () {
                                  login(context);
                                },
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Sign In",
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
              Visibility(
                visible: load,
                child: Center(
                  child: AnimatedOpacity(
                    duration: Duration(
                      milliseconds: 400,
                    ),
                    opacity: load ? 1 : 0,
                    child: Container(
                      color: Colors.white.withOpacity(0.5),
                      height: screenHeight,
                      child: Lottie.asset(
                        "assets/lottie/mailLoading.json",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
