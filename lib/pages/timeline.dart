import 'dart:async';

import 'package:Pettogram/chat/pages/home_page.dart';
import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/pages/search.dart';
import 'package:Pettogram/widgets/buildauthscreen.dart';
import 'package:Pettogram/widgets/post.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

final userref = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];
  bool isLoading;

  List<dynamic> users = [];
  getTimeline() async {
    QuerySnapshot snapshot = await timelineref
        .doc(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    posts.shuffle();
    setState(() {
      this.posts = posts;
    });
  }

  //  getUserbyID() async {
//    final QuerySnapshot snapshot = await userref.get();
//    setState(() {
//      users = snapshot.docs;
//    });
//  }

//  updateuser() async {
//    final doc = await userref.doc("asbdweqwewq").get();
//    if (doc.exists) {
//      doc.reference.update({
//        "username": "Roshan",
//        "isAdmin": false,
//        "posts": 4,
//      });
//    }
//  }

  deleteuser() async {
    final DocumentSnapshot doc = await userref.doc("asbdweqwewq").get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingref
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  buildUsersToFollow() {
    return StreamBuilder(
        stream: userref.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          snapshot.data.docs.forEach((doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser.id == user.id;
            final bool isFollowingUser = followingList.contains(user.id);

            //Removing the auth user from the recommended list.
            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              return;
            } else {
              UserResult userResult = UserResult(user);
              userResults.add(userResult);
            }
          });
          return Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Colors.black87,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "Users to Follow",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Grandstander",
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: userResults),
              ],
            ),
          );
        });
  }

  buildTimeline() {
    if (posts == null) {
      return ShimmerProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(children: posts);
    }
  }

  show_chat() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomeScreen(
          currentUserId: currentUser?.id,
          currentUserToken: currentUser.androidNotificationToken);
    }));
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        actions: [
          IconButton(
              icon: Icon(
                FontAwesome.comments,
                size: 25,
              ),
              onPressed: show_chat),
        ],
      ),
      body: RefreshIndicator(
          child: buildTimeline(),
          // ignore: missing_return
          onRefresh: () {
            setState(() {
              isLoading = true;
            });
            return Refresh();
          }),
//        body: StreamBuilder<QuerySnapshot>(
//          stream: userref.snapshots(),
//          builder: (context, snapshot) {
//            if (!snapshot.hasData) {
//              return ShimmerProgress();
//            }
//            final List<Text> children = snapshot.data.docs
//                .map((doc) => Text(doc.data()['username']))
//                .toList();
//            return Container(
//              child: ListView(
//                children: children,
//              ),
//            );
//          },
//        )
    );
  }

  @override
  void initState() {
//    getUserbyID();

    super.initState();
    getTimeline();
    getFollowing();
  }

  callback() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return buildAuth();
    }));
  }

  Future Refresh() async {
    var duration = Duration(milliseconds: 10);
    return Timer(duration, callback);
    initState();
//    setState(() {
//      isLoading = true;
//      ShimmerProgress();
//    });

    Completer<Null> completer = new Completer<Null>();
    Future.delayed(Duration(seconds: 2)).then((_) {
      setState(() {
        return ShimmerProgress();
      });
    });
    return getTimeline();
  }
}
