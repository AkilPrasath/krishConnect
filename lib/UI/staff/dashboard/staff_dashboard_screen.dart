import 'package:flutter/material.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_dashboard.dart';
import 'package:krish_connect/UI/staff/dashboard/staff_drawer_menu.dart';

import 'package:krish_connect/widgets/appBackground.dart';
import 'package:provider/provider.dart';

class StaffDashboardScreen extends StatefulWidget {
  static String id = "staff Dashboard";
  @override
  _StaffDashboardScreenState createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen>
    with TickerProviderStateMixin {
  double screenHeight;
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierProvider(
          builder: (context) => StaffDrawerAnimationProvider(vsync: this),
          child: AppBackground(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            child: Stack(
              children: [
                StaffDrawerMenu(),
                StaffDashboard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StaffDrawerAnimationProvider with ChangeNotifier {
  AnimationController controller;
  TickerProvider vsync;
  StaffDrawerAnimationProvider({@required this.vsync}) {
    controller = AnimationController(
        vsync: vsync, duration: Duration(milliseconds: 300));
    controller.addListener(() {
      notifyListeners();
    });
  }
  open() {
    controller.forward();
  }

  close() {
    controller.reverse();
  }

  toggle() {
    if (controller.status == AnimationStatus.completed) {
      close();
    } else if (controller.status == AnimationStatus.dismissed) {
      open();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    controller.dispose();
  }
}
