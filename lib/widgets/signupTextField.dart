import 'package:flutter/material.dart';

class SignupTextField extends StatelessWidget {
  SignupTextField({
    Key key,
    @required this.isPassword,
    @required this.labelText,
    @required this.isEmail,
    @required this.onSaved,
    this.validator,
    this.enabled,
    this.controller,
    this.onChanged,
    this.isNumber,
    this.maxLines,
    this.onTap,
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final bool isEmail;
  final bool isNumber;
  final bool isPassword;
  final int maxLines;
  bool enabled = false;
  final Function onSaved;
  final String Function(String) validator;
  final Function onChanged, onTap;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      onChanged: onChanged,
      validator: validator,
      controller: controller,
      style: TextStyle(
        fontSize: 20,
        color: Colors.blueGrey[900],
      ),
      obscureText: isPassword,
      onTap: onTap,
      keyboardType: (isNumber ?? false) ? TextInputType.phone : null,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        enabled: enabled ?? true,
        labelText: "$labelText",
        labelStyle: TextStyle(
          fontSize: 15,
        ),
        suffixText: isEmail ? "@skcet.ac.in" : null,
        suffixStyle: TextStyle(
          fontSize: 18,
          color: Colors.blueGrey[700],
          fontStyle: FontStyle.italic,
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: 4,
        ),
      ),
    );
  }
}
