import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:krish_connect/UI/login.dart';

import 'package:krish_connect/UI/student/dashboard/student_dashboard_screen.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';

import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/mailLoading.dart';
import 'package:krish_connect/widgets/rocketButton.dart';
import 'package:lottie/lottie.dart';
import 'package:numberpicker/numberpicker.dart';

class StudentDetailsScreen extends StatefulWidget {
  static final String id = "Details Screen";
  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  double screenHeight;
  double screenWidth;
  String email;
  String name;
  String phoneNumber;
  int currentSemester;
  bool privacySwitchValue;
  bool load;

  int currentSection;
  final _formKey = GlobalKey<FormState>();
  findDepartment(String code) {
    Map<String, String> codeMap = {
      "cs": "CSE",
      "ee": "EEE",
      "ec": "ECE",
      "it": "IT",
      "mc": "MECH",
      "mt": "MCT",
      "cv": "CIVIL",
      "null": "Error",
    };
    return codeMap["$code"];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = getIt<Authentication>().currentUser.email;
    name = "";

    phoneNumber = "";
    currentSemester = 1;
    currentSection = 1;
    privacySwitchValue = false;
    load = false;
  }

  Future<bool> saveDetails() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Student student = await getIt.getAsync<Student>();
      await student.updateDetails({
        "department": findDepartment(email.substring(4, 6)),
        "name": name,
        "location": "",
        "locationPrivacy": privacySwitchValue,
        "phoneNumber": phoneNumber,
        "rollno": email.substring(0, 9),
        "section": ["A", "B", "C"][currentSection],
        "semester": currentSemester,
      });
      return true;
    }
    return false;
  }

  alertSuccess(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        title: Text("Update Success!"),
        content: Lottie.asset("assets/lottie/verifyAnimation.json"),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, DashboardScreen.id);
            },
            child: Text("Go to Dashboard"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: AppBackground(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: InkWell(
              onTap: () async {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Student student = await getIt.getAsync<Student>();
                  student.clearData();
                  await getIt<Authentication>().logoutUser();

                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                }
              },
              child: Icon(
                Icons.chevron_left,
                color: Colors.blue[700],
                size: 40,
              ),
            ),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            title: Text(
              "Edit Info",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 24,
              ),
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: BodyTextField(
                            isNumber: false,
                            label: "Name",
                            onSaved: (val) {
                              name = val.trim();
                            },
                            validator: (val) {
                              if (val == null) {
                                return "Enter name";
                              }
                              return null;
                            },
                            enabled: true,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: BodyTextField(
                            isNumber: true,
                            label: "Mobile no",
                            onSaved: (val) {
                              phoneNumber = val;
                            },
                            validator: (val) {
                              if (val == null) {
                                return "Enter mobile no";
                              }
                              val = val.trim();
                              if (val.length != 10) {
                                return "10 digits required";
                              }
                              var number = int.tryParse(val);
                              if (number == null) {
                                return "Enter correct format";
                              }
                              return null;
                            },
                            enabled: true,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: BodyTextField(
                            isNumber: false,
                            label: email.substring(0, 9),
                            onSaved: (val) {},
                            validator: (val) {
                              return null;
                            },
                            enabled: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: BodyTextField(
                            isNumber: false,
                            label:
                                "Dept " + findDepartment(email.substring(4, 6)),
                            onSaved: (val) {},
                            validator: (val) {
                              return null;
                            },
                            enabled: false,
                          ),
                        ),
                        Row(
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Semester",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  NumberPicker.horizontal(
                                      haptics: true,
                                      listViewHeight: 40,
                                      initialValue: currentSemester,
                                      minValue: 1,
                                      maxValue: 8,
                                      onChanged: (num val) {
                                        setState(() {
                                          currentSemester = val;
                                        });
                                      }),
                                ],
                              ),
                            ),
                            Container(
                              width: 1.0,
                              height: 80,
                              color: Colors.blue.withOpacity(0.4),
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    child: Text(
                                      "Section",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  NumberPicker.horizontal(
                                      haptics: true,
                                      textMapper: (val) {
                                        return ["A", "B", "C"][int.parse(val)];
                                      },
                                      listViewHeight: 40,
                                      initialValue: currentSection,
                                      minValue: 0,
                                      maxValue: 2,
                                      onChanged: (num val) {
                                        setState(() {
                                          currentSection = val;
                                        });
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: privacySwitchValue,
                          onChanged: (val) {
                            setState(() {
                              privacySwitchValue = val;
                            });
                          },
                          title: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Location Privacy",
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "You can change this later",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              RocketButton(
                                onTap: () async {
                                  var connectivityResult = await (Connectivity()
                                      .checkConnectivity());
                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Please Check your Internet Connection!"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    load = true;
                                  });
                                  if (await saveDetails()) {
                                    //success
                                    setState(() {
                                      load = false;
                                    });
                                    alertSuccess(context);
                                  }
                                  setState(() {
                                    load = false;
                                  });
                                },
                                screenWidth: screenWidth,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Finish",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MailLoading(
                load: load,
                screenHeight: screenHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BodyTextField extends StatelessWidget {
  BodyTextField({
    @required this.label,
    @required this.onSaved,
    @required this.validator,
    @required this.enabled,
    @required this.isNumber,
    Key key,
  }) : super(key: key);
  final String label;
  final Function(String) onSaved;
  final String Function(String) validator;
  final bool enabled;
  bool isNumber = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue,
          width: 0.1,
        ),
      ),
      height: 38,
      child: TextFormField(
        validator: validator,
        onSaved: onSaved,
        style: TextStyle(
          fontSize: 16,
        ),
        enabled: enabled,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.name,
        decoration: InputDecoration(
          labelText: "$label",
          labelStyle: enabled
              ? TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700],
                )
              : TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 20,
                ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              width: 1.75,
              color: Colors.blue[700],
            ),
            gapPadding: 0,
          ),
        ),
      ),
    );
  }
}
