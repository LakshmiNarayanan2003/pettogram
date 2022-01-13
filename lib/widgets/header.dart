import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar header() {
  return AppBar(
    backgroundColor: Colors.deepOrangeAccent,
    centerTitle: true,
    title: Text(
      "Pettogram",
      style: TextStyle(
        fontFamily: "Kalam",
        fontSize: 35.0,
        fontStyle: FontStyle.normal,
      ),
    ),
  );
}
