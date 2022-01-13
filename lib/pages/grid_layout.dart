import 'package:Pettogram/widgets/post.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class Grid_Screen extends StatelessWidget {
  final String userId;
  final String postId;

  Grid_Screen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          postref.doc(currentUser.id).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          Post post = Post.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
              appBar: AppBar(
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
              ),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
