import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:krish_connect/UI/staff/announcement_list.dart';
import 'package:krish_connect/UI/student/student_requests.dart';
import 'package:krish_connect/data/staff.dart';
import 'package:krish_connect/main.dart';
import 'package:krish_connect/service/staffDatabase.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/rocketButton.dart';
import 'package:krish_connect/widgets/signupTextField.dart';
import 'package:logger/logger.dart';

class PostAnnouncementPage extends StatefulWidget {
  @override
  _PostAnnouncementPageState createState() => _PostAnnouncementPageState();
}

class _PostAnnouncementPageState extends State<PostAnnouncementPage> {
  double screenHeight;
  double screenWidth;
  bool prioritySelected;
  bool typeSelected;
  String title;
  String body;
  String lastDate;
  Staff staff;
  TextEditingController dateController;
  GlobalKey<FormState> _announcementFormKey = GlobalKey<FormState>();
  int priority;

  List<String> classList;
  String announcementType = "broadcast";
  String selectedDestinationClass;
  bool firstLoad = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  setStaffSubjectData() {
    // Logger().w(staff.subjects);
    // Logger().w(staff.tutor);
    classList.clear();

    staff.subjects.forEach((element) {
      classList.add(element["semester"].toString() +
          "-" +
          element["department"] +
          "-" +
          element["section"]);
    });
    if (staff.tutor != null) {
      String tutorClass = staff.tutor["semester"].toString() +
          "-" +
          staff.tutor["department"] +
          "-" +
          staff.tutor["section"];
      if (classList.indexOf(tutorClass) == -1) {
        classList.add(tutorClass);
      }
    }
    selectedDestinationClass = classList[0];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateController = TextEditingController();
    priority = 0;
    prioritySelected = true;
    typeSelected = true;
    classList = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: AppBackground(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: Colors.blue[700],
                ),
              ),
            ),
            title: Text(
              "Announcements",
              style: TextStyle(
                color: Colors.blue[700],
              ),
            ),
            actions: [
              Builder(builder: (context) {
                return InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return LayoutBuilder(
                                builder: (context, BoxConstraints constraints) {
                              return Container(
                                height: 0.75 * screenHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                  color: Colors.white,
                                ),
                                width: constraints.maxWidth,
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Form(
                                    key: _announcementFormKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Text(
                                            "New Announcement",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 8),
                                          child: Text("Class"),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              DropdownButton<String>(
                                                value: selectedDestinationClass,
                                                items: classList
                                                    .map((e) =>
                                                        DropdownMenuItem(
                                                            value: e,
                                                            child: Text(e)))
                                                    .toList(),
                                                onChanged: (String curClass) {
                                                  setState(() {
                                                    selectedDestinationClass =
                                                        curClass;
                                                  });
                                                  Logger().i(
                                                      selectedDestinationClass);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 8),
                                          child: Text("Priority"),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            RequestReasonSelectorItem(
                                              isSelected: !prioritySelected,
                                              text: "Usual🧊",
                                              onTap: () {
                                                if (prioritySelected == false) {
                                                  setState(() {
                                                    prioritySelected =
                                                        !prioritySelected;
                                                  });
                                                }
                                                priority = 0;
                                              },
                                            ),
                                            RequestReasonSelectorItem(
                                              isSelected: prioritySelected,
                                              text: "High🔥",
                                              onTap: () {
                                                if (prioritySelected == true) {
                                                  setState(() {
                                                    prioritySelected =
                                                        !prioritySelected;
                                                  });
                                                }
                                                priority = 1;
                                              },
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 8),
                                          child: Text("Type"),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            RequestReasonSelectorItem(
                                              isSelected: !typeSelected,
                                              text: "Broadcast",
                                              onTap: () {
                                                if (typeSelected == false) {
                                                  setState(() {
                                                    typeSelected =
                                                        !typeSelected;
                                                  });
                                                }
                                                announcementType = "broadcast";
                                              },
                                            ),
                                            RequestReasonSelectorItem(
                                              isSelected: typeSelected,
                                              text: "Yes/No",
                                              onTap: () {
                                                if (typeSelected == true) {
                                                  setState(() {
                                                    typeSelected =
                                                        !typeSelected;
                                                  });
                                                }
                                                announcementType = "yesorno";
                                              },
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 4),
                                          child: Text("Title"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 4),
                                          child: SignupTextField(
                                              isPassword: false,
                                              labelText: "",
                                              isEmail: false,
                                              validator: (String val) {
                                                if (val == null) {
                                                  return "Enter Title";
                                                }
                                                if (val.isEmpty) {
                                                  return "Enter Title";
                                                }
                                                return null;
                                              },
                                              onSaved: (String value) {
                                                title = value;
                                              }),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 8),
                                          child: Text("Body"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blue,
                                                width: 2,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 2, 8, 0),
                                              child: SignupTextField(
                                                  isPassword: false,
                                                  labelText: "",
                                                  maxLines: 5,
                                                  isEmail: false,
                                                  validator: (String val) {
                                                    if (val == null) {
                                                      return "Enter body";
                                                    }
                                                    if (val.isEmpty) {
                                                      return "Enter body";
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (String value) {
                                                    body = value;
                                                  }),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32.0, vertical: 8),
                                          child: SignupTextField(
                                              controller: dateController,
                                              isPassword: false,
                                              labelText: "Last Date",
                                              isEmail: false,
                                              onTap: () async {
                                                DateTime date =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime(2020),
                                                        firstDate:
                                                            DateTime(2020),
                                                        lastDate:
                                                            DateTime(2025));
                                                if (date != null) {
                                                  dateController.text =
                                                      Jiffy(date).yMMMd;
                                                }
                                                //dismiss keyboard
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);

                                                if (!currentFocus
                                                        .hasPrimaryFocus &&
                                                    currentFocus.focusedChild !=
                                                        null) {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      .unfocus();
                                                }
                                              },
                                              validator: (String string) {
                                                if (dateController.text ==
                                                        null ||
                                                    dateController.text == "") {
                                                  return "Select Last Date";
                                                }
                                                return null;
                                              },
                                              onSaved: (String value) {
                                                lastDate = dateController.text;
                                              }),
                                        ),
                                        SizedBox(height: 8),
                                        RocketButton(
                                            onTap: () async {
                                              if (_announcementFormKey
                                                  .currentState
                                                  .validate()) {
                                                _announcementFormKey
                                                    .currentState
                                                    .save();
                                                Map<String, dynamic>
                                                    announcementData = {
                                                  "class":
                                                      selectedDestinationClass,
                                                  "priority": priority,
                                                  "type": announcementType,
                                                  "title": title,
                                                  "body": body,
                                                  "lastDate": lastDate,
                                                };
                                                // Logger().w(announcementData);
                                                await getIt<StaffDatabase>()
                                                    .postAnnouncement(
                                                        announcementData);
                                                dateController.clear();
                                                Navigator.pop(context);
                                                _scaffoldKey.currentState
                                                    .showSnackBar(SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  content: Text(
                                                      "Announcement Posted successfully!"),
                                                ));
                                              }
                                            },
                                            screenWidth: screenWidth),
                                        SizedBox(height: 8),
                                        Text(
                                          "Post Announcement",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 75),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                          });
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.add, color: Colors.blue[700], size: 35),
                  ),
                );
              })
            ],
          ),
          body: FutureBuilder<Staff>(
              future: getIt.getAsync<Staff>(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  staff = snapshot.data;
                  if (firstLoad) {
                    setStaffSubjectData();

                    firstLoad = false;
                  }
                  return AnnouncementListStaff(staff: staff);
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }
}
