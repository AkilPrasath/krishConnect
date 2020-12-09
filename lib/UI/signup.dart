import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/UI/emailVerify.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/data/constants.dart';
import 'package:krish_connect/main.dart';

import 'package:krish_connect/service/authentication.dart';

import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/mailLoading.dart';
import 'package:krish_connect/widgets/rocketButton.dart';
import 'package:krish_connect/widgets/signupTextField.dart';
import 'package:connectivity/connectivity.dart';

import 'emailVerify.dart';

class SignupScreen extends StatefulWidget {
  static final String id = "Signup Screen";
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  double screenWidth;
  double screenHeight;
  String _password, _email;
  bool load = false;
  Authentication authenticate = new Authentication();
  final _formKey = GlobalKey<FormState>();

  Future<void> alertEmailAlready(context) async {
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
              "Signup Error",
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
                text: "$_email@skcet.ac.in",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: " is already in use !",
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
            textColor: Colors.blue,
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.id);
            },
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close"),
          ),
        ],
      ),
      barrierDismissible: true,
      useSafeArea: true,
    );
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
                                },
                                validator: (value) {
                                  RegExp emailRegex =
                                      RegExp(r"^([a-zA-Z0-9_\-\.]+)");

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
                                    return "Password cannot be empty";
                                  }
                                  if (value.length < 8) {
                                    return "Minimum 8 characters";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, LoginScreen.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: Text(
                                  "Login",
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
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    var connectivityResult =
                                        await (Connectivity()
                                            .checkConnectivity());
                                    if (connectivityResult ==
                                        ConnectivityResult.none) {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            "Please Check your Internet Connection!"),
                                        duration: Duration(seconds: 2),
                                      ));
                                      return;
                                    }
                                    setState(() {
                                      load = true;
                                    });
                                    //TODO: dummy mail added
                                    SignupResult signupResult =
                                        await getIt<Authentication>().signUp(
                                            _email + "@skcet.ac.in", _password);
                                    // _email + "@gmail.com",
                                    // _password);
                                    setState(() {
                                      load = false;
                                    });
                                    if (signupResult ==
                                        SignupResult.emailalreadyinuse) {
                                      await alertEmailAlready(context);
                                    } else if (signupResult ==
                                        SignupResult.success) {
                                      Future.delayed(
                                              Duration(milliseconds: 400))
                                          .then(
                                        (value) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VerifyEmailScreen(),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        duration: Duration(seconds: 2),
                                        content: Text(
                                            "Unable to create account. Please try again!"),
                                      ));
                                    }
                                  }
                                },
                              );
                            }),
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
              MailLoading(load: load, screenHeight: screenHeight),
            ],
          ),
        ),
      ),
    );
  }
}
