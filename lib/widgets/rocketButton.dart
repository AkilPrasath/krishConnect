import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RocketButton extends StatelessWidget {
  const RocketButton({
    Key key,
    @required this.onTap,
    @required this.screenWidth,
  }) : super(key: key);

  final double screenWidth;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.2 * screenWidth,
      height: 0.2 * screenWidth,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 0.16 * screenWidth,
          height: 0.16 * screenWidth,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffFF6A83),
                Color(0xffF98875),
                Color(0xffF3A866),
              ],
              
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: pi / 4,
                child: FaIcon(
                  FontAwesomeIcons.rocket,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
