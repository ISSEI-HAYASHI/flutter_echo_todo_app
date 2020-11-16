import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FormLabelWidget extends StatelessWidget {
  final String data;

  const FormLabelWidget(this.data, {Key key})
      : assert(data != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        data,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }
}
