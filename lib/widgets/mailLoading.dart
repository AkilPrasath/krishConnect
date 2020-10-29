import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MailLoading extends StatelessWidget {
  const MailLoading({
    Key key,
    @required this.load,
    @required this.screenHeight,
  }) : super(key: key);

  final bool load;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: load,
      child: Center(
        child: AnimatedOpacity(
          duration: Duration(
            milliseconds: 1000,
          ),
          opacity: load ? 1 : 0,
          child: Container(
            color: Colors.white.withOpacity(0.5),
            height: screenHeight,
            child: Lottie.asset(
              "assets/lottie/mailLoading.json",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
