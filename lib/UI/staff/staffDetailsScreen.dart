import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krish_connect/UI/login.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard_screen.dart';
import 'package:krish_connect/data/constants.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/authentication.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/signupTextField.dart';
import 'package:numberpicker/numberpicker.dart';

class StaffDetailsScreen extends StatefulWidget {
  static final String id = "staff details screen";
  @override
  _StaffDetailsScreenState createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  double screenHeight;
  double screenWidth;
  String tutorDepartment;
  int tutorSemester;
  int tutorSection;
  bool tutorSwitch;
  String email;
  int currentTutorSection;
  int currentTutorSemester;
  ScrollController scrollController;
  List<Widget> subjectInputItems = [];
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> tutorDetails = {};
  static List<Map<String, dynamic>> subjectMapList = [
    {
      "code": "",
      "semester": 1,
      "section": "B",
      "department": "${departmentsList[0]}"
    }
  ];
  String name;
  String phoneNumber;
  bool locationPrivacy;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = getIt<Authentication>().currentUser.email;
    scrollController = ScrollController();
    locationPrivacy = false;
    tutorSwitch = false;
    currentTutorSection = 1;
    currentTutorSemester = 1;
    tutorDepartment = departmentsList[0];
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
                  Staff staff = await getIt.getAsync<Staff>();
                  staff.clearData();
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
            actions: [
              Center(
                child: InkWell(
                  onTap: false
                      ? () async {
                          (await getIt.getAsync<Staff>()).clearData();
                          getIt<Authentication>().logoutUser();
                          Navigator.pushReplacementNamed(
                              context, LoginScreen.id);
                        }
                      : () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            var connectivityResult =
                                await (Connectivity().checkConnectivity());
                            if (connectivityResult == ConnectivityResult.none) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Please Check your Internet Connection!"),
                                duration: Duration(seconds: 2),
                              ));
                              return;
                            }
                            Staff staff = await getIt.getAsync<Staff>();
                            await staff.updateDetails(
                              name: name,
                              locationPrivacy: locationPrivacy,
                              phoneNumber: phoneNumber,
                              subjectMapList: subjectMapList,
                              tutorMap: tutorDetails,
                              email: email,
                            );
                            Navigator.pushReplacementNamed(
                                context, StaffDashboardScreen.id);
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            physics: BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8),
                    child: SignupTextField(
                      enabled: true,
                      isPassword: false,
                      labelText: "Name",
                      isEmail: false,
                      onSaved: (String value) {
                        name = value;
                      },
                      validator: (String val) {
                        if (val.trim().isEmpty) {
                          return "name cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8),
                    child: SignupTextField(
                        enabled: false,
                        isPassword: false,
                        labelText: "$email",
                        isEmail: true,
                        onSaved: (String value) {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8),
                    child: SignupTextField(
                      enabled: true,
                      isPassword: false,
                      labelText: "phone number",
                      isEmail: false,
                      isNumber: true,
                      onSaved: (String value) {
                        phoneNumber = value;
                      },
                      validator: (String value) {
                        if (value.trim().isEmpty) {
                          return "phone number cannot be empty";
                        }
                        if (value.trim().length != 10) {
                          return "10 digits required";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: locationPrivacy,
                      activeColor: Colors.green[800],
                      onChanged: (val) {
                        setState(() {
                          locationPrivacy = val;
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
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                      child: Text(
                        "Handling Subjects",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ..._getSubjects(),
                  Center(
                    child: FlatButton(
                      onPressed: () {
                        subjectMapList.insert(subjectMapList.length, {
                          "code": "",
                          "semester": 1,
                          "section": "B",
                          "department": departmentsList[0],
                        });
                        setState(() {});
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.plusCircle,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Add Subject",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                      child: Row(
                        children: [
                          Text(
                            "I'm a Tutor",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                              value: tutorSwitch,
                              onChanged: (bool switchValue) {
                                setState(() {
                                  tutorSwitch = switchValue;
                                });
                                if (switchValue) {
                                  Future.delayed(Duration(milliseconds: 200))
                                      .then((value) {
                                    scrollController.animateTo(120,
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.bounceIn);
                                  });
                                }
                                if (switchValue) {
                                  tutorDetails = {
                                    "semester": 1,
                                    "section": "B",
                                    "department": "CSE"
                                  };
                                } else {
                                  tutorDetails = {};
                                }
                              }),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 750),
                    child: !tutorSwitch
                        ? Container()
                        : Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 0, 24, 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Department",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      DropdownButton(
                                          value: tutorDepartment,
                                          items: departmentsList.map((e) {
                                            return DropdownMenuItem(
                                                value: e,
                                                key: Key(e),
                                                child: Text(e.toString()));
                                          }).toList(),
                                          onChanged: (department) {
                                            setState(() {
                                              tutorDepartment = department;
                                              tutorDetails["department"] =
                                                  department;
                                            });
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                textBaseline: TextBaseline.alphabetic,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Semester",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        NumberPicker.horizontal(
                                            haptics: true,
                                            listViewHeight: 40,
                                            initialValue: currentTutorSemester,
                                            minValue: 1,
                                            maxValue: 8,
                                            onChanged: (num val) {
                                              setState(() {
                                                currentTutorSemester = val;
                                                tutorDetails["semester"] = val;
                                              });
                                            }),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1.0,
                                    height: 50,
                                    color: Colors.blue.withOpacity(0.4),
                                  ),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Section",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        NumberPicker.horizontal(
                                            haptics: true,
                                            textMapper: (val) {
                                              return [
                                                "A",
                                                "B",
                                                "C"
                                              ][int.parse(val)];
                                            },
                                            listViewHeight: 40,
                                            initialValue: currentTutorSection,
                                            minValue: 0,
                                            maxValue: 2,
                                            onChanged: (num val) {
                                              setState(() {
                                                currentTutorSection = val;
                                                tutorDetails["section"] =
                                                    ["A", "B", "C"][val];
                                              });
                                            }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getSubjects() {
    subjectInputItems.clear();
    for (int i = 0; i < subjectMapList.length; i++) {
      subjectInputItems.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: SubjectInputItem(i)),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                subjectMapList.removeAt(i);
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FaIcon(
                  FontAwesomeIcons.minusCircle,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            )
          ],
        ),
      ));
    }
    return subjectInputItems;
  }

  // Widget _addRemoveButton(int index) {
  //   return InkWell(
  //     borderRadius: BorderRadius.circular(20),
  //     onTap: () {

  //       subjectMapList.removeAt(index);
  //       setState(() {});

  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //       child: FaIcon(
  //         FontAwesomeIcons.minusCircle,
  //         color: Colors.red,
  //         size: 24,
  //       ),
  //     ),
  //   );
  // }
}

class SubjectInputItem extends StatefulWidget {
  final int index;
  SubjectInputItem(this.index);
  @override
  _SubjectInputItemState createState() => _SubjectInputItemState();
}

class _SubjectInputItemState extends State<SubjectInputItem> {
  int currentSemester;
  int currentSection;
  String department;

  TextEditingController subjectCodeController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    department = departmentsList[0];
    currentSemester =
        _StaffDetailsScreenState.subjectMapList[widget.index]["semester"];
    currentSection = ["A", "B", "C"].indexOf(
        _StaffDetailsScreenState.subjectMapList[widget.index]
            ["section"]); // 1 is B Section (starts from 0)
    subjectCodeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      subjectCodeController.text =
          _StaffDetailsScreenState.subjectMapList[widget.index]["code"];
    });
  }

  @override
  void dispose() {
    subjectCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 8, top: 4, bottom: 0),
            child: Text(
              "Subject ${widget.index + 1}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
          child: Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Flexible(
                child: SignupTextField(
                  controller: subjectCodeController,
                  enabled: true,
                  isPassword: false,
                  labelText: "Subject Code",
                  isEmail: false,
                  validator: (String value) {
                    if (value.trim().isEmpty) {
                      return "Subject code cannot be empty";
                    }
                    if (value.trim().length != 7) {
                      return "7 characters required";
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    _StaffDetailsScreenState.subjectMapList[widget.index]
                        ["code"] = value;
                  },
                  onChanged: (String value) {},
                ),
              ),
              SizedBox(width: 8),
              DropdownButton(
                  elevation: 0,
                  underline: SizedBox(),
                  value: department,
                  items: departmentsList.map((e) {
                    return DropdownMenuItem(
                        value: e, key: Key(e), child: Text(e.toString()));
                  }).toList(),
                  onChanged: (changedDepartment) {
                    setState(() {
                      department = changedDepartment;
                    });
                    _StaffDetailsScreenState.subjectMapList[widget.index]
                        ["department"] = changedDepartment;
                  }),
            ],
          ),
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Semester",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
                        _StaffDetailsScreenState.subjectMapList[widget.index]
                            ["semester"] = val;
                      }),
                ],
              ),
            ),
            Container(
              width: 1.0,
              height: 50,
              color: Colors.blue.withOpacity(0.4),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Section",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
                        _StaffDetailsScreenState.subjectMapList[widget.index]
                            ["section"] = ["A", "B", "C"][val];
                      }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
