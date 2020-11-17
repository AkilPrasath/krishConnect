import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:krish_connect/UI/student/dashboard/dashboardScreen.dart';
import 'package:krish_connect/widgets/appBackground.dart';
import 'package:provider/provider.dart';

class StaffDashboard extends StatefulWidget {
  static String id = "staff Dashboard";
  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  double screenHeight;
  double screenWidth;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: AppBackground(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Provider.of<AnimationProvider>(context, listen: true).toggle();
              },
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.bars,
                  color: Colors.blue[700],
                ),
              ),
            ),
            title: Text(
              "KRISH CONNECT",
              style: TextStyle(
                color: Colors.blue[700],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: Container(),
        ),
      ),
    );
  }
}
