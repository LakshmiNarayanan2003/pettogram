import 'package:Pettogram/models/data.dart';
import 'package:Pettogram/pages/activity_feed.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/pages/profile.dart';
import 'package:Pettogram/pages/search.dart';
import 'package:Pettogram/pages/story_screen.dart';
import 'package:Pettogram/pages/timeline.dart';
import 'package:Pettogram/pages/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class buildAuth extends StatefulWidget {
  @override
  _buildAuthState createState() => _buildAuthState();
}

class _buildAuthState extends State<buildAuth> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  PageController pageController;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    onTap(int pageIndex) {
      pageController.animateToPage(pageIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.fastLinearToSlowEaseIn);
    }

    onPageChanged(int pageIndex) {
      setState(() {
        this.pageIndex = pageIndex;
      });
    }

    Scaffold buildAuthScreen() {
      final Size size = MediaQuery.of(context).size;
      return Scaffold(
        key: _scaffoldKey,
        body: CustomPaint(
          painter: BNBCustomPainter(),
          size: Size(size.width, 80),
          child: PageView(
            children: <Widget>[
              Timeline(currentUser: currentUser),
              Search(),
              StoryScreen(
                stories: stories,
              ),
              Upload(currentUser: currentUser),
              ActivityFeed(),
              Profile(profileId: currentUser?.id),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          iconSize: 25,
          inactiveColor: Colors.grey,
          activeColor: Colors.orangeAccent.withOpacity(1),
          items: [
            BottomNavigationBarItem(
              icon: Icon(FontAwesome.paw),
            ),
            BottomNavigationBarItem(icon: Icon(FontAwesome.search)),
            BottomNavigationBarItem(icon: Icon(FontAwesome.star_o)),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 10),
                child: Icon(
                  FontAwesome.plus_circle,
                  size: 47.0,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.notifications_active),
                icon: Icon(Icons.notifications)),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orangeAccent,
                backgroundImage: CachedNetworkImageProvider(
                    currentUser.photoUrl == null
                        ? currentUser.username[0]
                        : currentUser.photoUrl),
              ),
            ),
          ],
        ),
      );
      // return RaisedButton(
      //   child: Text('Logout'),
      //   onPressed: logout,
      // );
    }

    return buildAuthScreen();
  }
}
