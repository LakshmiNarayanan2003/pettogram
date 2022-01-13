import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Story extends StatefulWidget {
  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Stories"),
      ),
      body: PageView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Fluttertoast.showToast(msg: "Pressed");
            },
            child: IconButton(
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
