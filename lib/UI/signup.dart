import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/service/database.dart';
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
  UserMode userMode;
  String _password, _email;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
              Navigator.pop(context);
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
    MediaQueryData md = MediaQuery.of(context);
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
                    key: _formKey,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                        RocketButton(
                          screenWidth: screenWidth,
                          onTap: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              SignupResult signupResult = await Authentication()
                                  .signUp(_email + "@skcet.ac.in", _password);
                              print(signupResult);
                              if (signupResult ==
                                  SignupResult.emailalreadyinuse) {
                                await alertEmailAlready(context);
                              }
                              print("in");
                            }
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
