import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:krish_connect/UI/dashboard/dashboardScreen.dart';
import 'package:krish_connect/UI/detailsScreen.dart';
import 'package:krish_connect/UI/emailVerify.dart';
import 'package:krish_connect/UI/signup.dart';
import 'package:krish_connect/data/enums.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';

import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/mailLoading.dart';
import 'package:krish_connect/widgets/rocketButton.dart';
import 'package:krish_connect/widgets/signupTextField.dart';

class LoginScreen extends StatefulWidget {
  static final String id = "Login Screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double screenWidth;
  double screenHeight;
  UserMode userMode;
  String _password = "", _email = "";
  bool load = false;
  final _formKey = GlobalKey<FormState>();

  Future errorAlert(String text1, String text2) async {
    await showDialog(
      context: context,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Login Error",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: text1 + " ",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: text2,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Okay"),
          ),
        ],
      ),
      barrierDismissible: true,
      useSafeArea: true,
    );
  }

  login(context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        load = true;
      });
      LoginResult loginResult =
          await getIt<Authentication>().signIn(_email, _password);
      setState(() {
        load = false;
      });
      if (loginResult == LoginResult.usernotfound) {
        print("the error has reached here");
        await errorAlert("User not found for", _email);
      } else if (loginResult == LoginResult.wrongpassword) {
        await errorAlert("Incorrect Password for", _email);
      } else if (loginResult == LoginResult.success) {
        await getIt<Authentication>().reloadUser();
        if (!getIt<Authentication>().currentUser.emailVerified) {
          Navigator.pushReplacementNamed(context, VerifyEmailScreen.id);
          return;
        }
        if (userMode == UserMode.student) {
          Student student = await getIt.getAsync<Student>();
          // Student.create(_email.substring(0, 9));
          print(student);
          if (student.isEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(),
              ),
            );
          } else {
            Navigator.pushNamed(
              context,
              DashboardScreen.id,
            );
          }
        } else {
          // go to staff
          print("stafffffff");
        }
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
                                  _email = value + "@skcet.ac.in";

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
                                  if (value == null) {
                                    value = "";
                                  }
                                  if (emailRegex.stringMatch(value) == null) {
                                    return "Email cannot be empty!";
                                  }
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
                                  if (value == null) {
                                    return "Password cannot be empty!";
                                  }
                                  if (value.length < 8) {
                                    return "Minimum 8 characters";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 0.05 * screenHeight,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, SignupScreen.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: Text(
                                  "Signup",
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Builder(builder: (context) {
                              return RocketButton(
                                screenWidth: screenWidth,
                                onTap: () async {
                                  var connectivityResult = await (Connectivity()
                                      .checkConnectivity());
                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "Please Check your Internet Connection!"),
                                      duration: Duration(seconds: 2),
                                    ));
                                    return;
                                  }
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
              MailLoading(load: load, screenHeight: screenHeight),
            ],
          ),
        ),
      ),
    );
  }
}
