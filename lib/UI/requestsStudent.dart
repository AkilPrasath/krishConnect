import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krish_connect/data/student.dart';
import 'package:krish_connect/service/database.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/columnBuilder.dart';
import 'package:krish_connect/widgets/customExpandableTile.dart';
import 'package:krish_connect/widgets/rocketButton.dart';

import '../main.dart';

class RequestStudent extends StatefulWidget {
  static final String id = "Request student";
  @override
  _RequestStudentState createState() => _RequestStudentState();
}

class _RequestStudentState extends State<RequestStudent> {
  double screenHeight, screenWidth;
  bool isSelected = true;
  final _formKey = GlobalKey<FormState>();
  String selectedTutor;
  String type = "OD";
  String dateRange;
  String reason;
  String proofURL;
  Map<String, dynamic> tutorsMap;
  RegExp urlRegex = RegExp(
      r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
  TextEditingController dateRangeController;
  List<String> monthData = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateRangeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            onPressed: () async {
              selectedTutor = null;
              dateRangeController.clear();
              showBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return LayoutBuilder(
                        builder: (context, BoxConstraints constraints) {
                      return StatefulBuilder(builder: (context, setState) {
                        return Container(
                          height: 0.75 * screenHeight,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[600],
                                offset: Offset(0.0, 2.0),
                                blurRadius: 10.0,
                                spreadRadius: 1,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      "New Request",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RequestReasonSelectorItem(
                                        isSelected: !isSelected,
                                        text: "Leave",
                                        onTap: () {
                                          if (isSelected == false) {
                                            setState(() {
                                              isSelected = !isSelected;
                                            });
                                          }
                                          type = "Leave";
                                        },
                                      ),
                                      RequestReasonSelectorItem(
                                        isSelected: isSelected,
                                        text: "OD",
                                        onTap: () {
                                          if (isSelected == true) {
                                            setState(() {
                                              isSelected = !isSelected;
                                            });
                                          }
                                          type = "OD";
                                        },
                                      ),
                                    ],
                                  ),
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: getIt<Database>().getTutors(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (!snapshot.hasData) {
                                        return Text("Notified to all tutors");
                                      }
                                      if (snapshot.hasData) {
                                        tutorsMap = snapshot.data;
                                        List<String> tutors =
                                            snapshot.data.keys.toList();

                                        print(tutors);
                                        return DropdownButton(
                                          value: selectedTutor,
                                          items: tutors
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem(
                                                value: value,
                                                child: Text(value));
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTutor = value;
                                            });
                                          },
                                          hint: Text("Tutor"),
                                        );
                                      }
                                    },
                                  ),
                                  Container(
                                    width: screenWidth * 0.7,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        hintText: "Date Range",
                                      ),
                                      controller: dateRangeController,
                                      onTap: () async {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        DateTimeRange dateRange =
                                            await showDateRangePicker(
                                                context: context,
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2050));
                                        if (dateRange == null) {
                                          return;
                                        }
                                        DateTime start = dateRange.start;
                                        DateTime end = dateRange.end;
                                        dateRangeController.text =
                                            start.day.toString() +
                                                " " +
                                                monthData[end.month - 1] +
                                                " " +
                                                start.year.toString();
                                        dateRangeController.text =
                                            dateRangeController.text +
                                                " - " +
                                                end.day.toString() +
                                                " " +
                                                monthData[end.month - 1] +
                                                " " +
                                                end.year.toString();
                                      },
                                      validator: (String val) {
                                        if (dateRangeController.text
                                            .toString()
                                            .isEmpty) {
                                          return "Select date range";
                                        }
                                        return null;
                                      },
                                      onSaved: (String s) {
                                        dateRange = dateRangeController.text;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    width: 0.7 * screenWidth,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: "Reason",
                                      ),
                                      textAlign: TextAlign.center,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return "Enter valid reason";
                                        }
                                        return null;
                                      },
                                      onSaved: (String s) {
                                        reason = s;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    width: 0.7 * screenWidth,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: "Proof URL",
                                      ),
                                      textAlign: TextAlign.center,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return null;
                                        }
                                        if (urlRegex.stringMatch(value) ==
                                            null) {
                                          return "invalid Url";
                                        }
                                        if (!(urlRegex
                                                .stringMatch(value)
                                                .length ==
                                            value.length)) {
                                          return "invalid URL";
                                        }
                                        return null;
                                      },
                                      onSaved: (String value) {
                                        proofURL = value;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  RocketButton(
                                    onTap: () async {
                                      // getIt<Database>()
                                      //     .addNewRequest({"aaa": true});
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                        Student currentStudent =
                                            await getIt.getAsync<Student>();
                                        Map<String, dynamic> requestMap = {
                                          "addressed": tutorsMap[selectedTutor],
                                          "body": reason,
                                          "date": dateRange,
                                          "name": currentStudent.name,
                                          "response": 0,
                                          "rollno": currentStudent.rollno,
                                          "timestamp": DateTime.now(),
                                          "type": type,
                                          "proofURL": proofURL ?? "",
                                        };
                                        await getIt<Database>()
                                            .addNewRequest(requestMap);
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 3),
                                          content: Text(
                                              "Request submitted to tutor ${selectedTutor}"),
                                        ));
                                        Navigator.pop(context);
                                      }
                                    },
                                    screenWidth: screenWidth,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Center(
                                      child: Text(
                                    "Send Request",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    });
                  });
            },
            child: Icon(Icons.add),
          );
        }),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.chevron_left,
              color: Colors.blue,
            ),
          ),
          title: Text(
            "My Requests",
            style: TextStyle(fontSize: 30, color: Colors.blue),
          ),
        ),
        body: AppBackground(
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          child: SingleChildScrollView(
            child: Container(
              child: FutureBuilder<Student>(
                future: getIt.getAsync<Student>(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("No data"),
                    );
                  }
                  if (snapshot.hasData)
                    return StreamBuilder<dynamic>(
                        stream: getIt<Database>().requestsStream(snapshot.data),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData) {
                            return Center(
                              child: Text("no data"),
                            );
                          }
                          if (snapshot.data.length == 0) {
                            return Center(child: Text("No Requests made yet "));
                          }
                          if (snapshot.hasData) {
                            return ColumnBuilder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Dismissible(
                                    confirmDismiss: (dismissDirection) async {
                                      if (snapshot.data[index]["response"] ==
                                          0) {
                                        await getIt<Database>().deleteRequest(
                                            snapshot.data[index]["timestamp"]);
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                              "Request Deleted Successfully!"),
                                        ));
                                        return Future.value(true);
                                      } else {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                              "Only pending requests can be deleted"),
                                        ));
                                        print("false");
                                        return Future.value(false);
                                      }
                                    },
                                    direction: DismissDirection.startToEnd,
                                    background: Container(
                                      color: Colors.red,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                          ),
                                          FaIcon(
                                            FontAwesomeIcons.trash,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                            "Release to Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(
                                            flex: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onDismissed: (dismissDirection) {},
                                    key: UniqueKey(),
                                    child: CustomExpandableListTile(
                                      studentMap: snapshot.data[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RequestReasonSelectorItem extends StatelessWidget {
  const RequestReasonSelectorItem({
    Key key,
    @required this.isSelected,
    @required this.text,
    this.onTap,
  }) : super(key: key);

  final bool isSelected;
  final String text;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: AnimatedDefaultTextStyle(
            style: !isSelected
                ? TextStyle(
                    fontSize: 30,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  )
                : TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
            duration: Duration(milliseconds: 200),
            child: Text(
              "$text",
              style: TextStyle(),
            ),
          ),
        ),
      ),
    );
  }
}
