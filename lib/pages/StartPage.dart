import 'dart:async';

import 'package:Pettogram/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  callback() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }

  startTimer() async {
    var duration = Duration(seconds: 2);
    return Timer(duration, callback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.orange,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 225, bottom: 225, left: 35, right: 35),
              child: Text(
                'Pettogram',
                style: TextStyle(
                  fontFamily: "Kalam",
                  fontSize: 64.0,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: 260.0,
              height: 60.0,
              child: Image.asset(
                'assets/images/Good doggy-bro.svg',
                fit: BoxFit.cover,
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }
}
