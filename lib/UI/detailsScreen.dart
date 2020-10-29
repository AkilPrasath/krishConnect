import 'package:flutter/material.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:krish_connect/widgets/mailLoading.dart';
import 'package:krish_connect/widgets/rocketButton.dart';
import 'package:numberpicker/numberpicker.dart';

class DetailsScreen extends StatefulWidget {
  static final String id = "Details Screen";
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  double screenHeight;
  double screenWidth;
  String email = "18eucs008";
  int currentSemester;
  bool privacySwitchValue;
  bool load;
  int currentSection;
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
    currentSemester = 1;
    currentSection = 1;
    privacySwitchValue = false;
    load = false;
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
              onTap: () {
                Navigator.pop(context);
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
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: BodyTextField(
                          isNumber: false,
                          label: "Name",
                          onSaved: (val) {},
                          validator: (val) {
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
                          onSaved: (val) {},
                          validator: (val) {
                            return null;
                          },
                          enabled: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: BodyTextField(
                          isNumber: false,
                          label: "18eucs008",
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
                          label: findDepartment(email.substring(4, 6)),
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
                              onTap: () {},
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
