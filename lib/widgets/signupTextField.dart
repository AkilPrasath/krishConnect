import 'package:flutter/material.dart';

class SignupTextField extends StatelessWidget {
  const SignupTextField({
    Key key,
    @required this.isPassword,
    @required this.labelText,
    @required this.isEmail,
    @required this.onSaved,
    this.validator,
    TextEditingController textEditingController,
  })  : _textEditingController = textEditingController,
        super(key: key);

  final TextEditingController _textEditingController;
  final String labelText;
  final bool isEmail;
  final bool isPassword;
  final Function onSaved;
  final String Function(String) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      validator: validator,
      controller: _textEditingController,
      style: TextStyle(
        fontSize: 20,
        color: Colors.blueGrey[900],
      ),
      obscureText: isPassword,
      decoration: InputDecoration(
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
