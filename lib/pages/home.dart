import 'dart:io';

import 'package:Pettogram/models/data.dart';
import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/activity_feed.dart';
import 'package:Pettogram/pages/create_account.dart';
import 'package:Pettogram/pages/profile.dart';
import 'package:Pettogram/pages/search.dart';
import 'package:Pettogram/pages/story_screen.dart';
import 'package:Pettogram/pages/timeline.dart';
import 'package:Pettogram/pages/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersref = FirebaseFirestore.instance.collection('users');
final postref = FirebaseFirestore.instance.collection('posts');
final commentsref = FirebaseFirestore.instance.collection('comments');
final activityref = FirebaseFirestore.instance.collection('feed');
final followersref = FirebaseFirestore.instance.collection('followers');
final followingref = FirebaseFirestore.instance.collection('following');
final timelineref = FirebaseFirestore.instance.collection('timeline');
final messageref = FirebaseFirestore.instance.collection('messages');
final DateTime timestamp = DateTime.now();
User currentUser;
String authToken;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      Fluttertoast.showToast(
          msg: "Welcome to Pettogram.", backgroundColor: Colors.deepOrange);
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  void _navigateToDetail(Map<String, dynamic> message) {
    _firebaseMessaging.getToken().then((token) {
      print("Firebase messaging token : $token");

      usersref.doc(currentUser.id).update({"androidNotificationToken": token});
    });

    final String body = message['notification']['body'];

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ActivityFeed();
    }));
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) {
      getiOSPermission();
    }
    _firebaseMessaging.getToken().then((token) {
      print("Firebase messaging token : $token");
      setState(() {
        currentUser.androidNotificationToken = token;
      });
      usersref.doc(user.id).update({"receiverToken": token});
      usersref.doc(user.id).update({"androidNotificationToken": token});
    });
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        _firebaseMessaging.getToken().then((token) {
          print("Firebase messaging token : $token");
          usersref.doc(user.id).update({"receiverToken": token});
          usersref.doc(user.id).update({"androidNotificationToken": token});
        });
//        print("On Launch : $message\n");
//        _navigateToDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _firebaseMessaging.getToken().then((token) {
          print("Firebase messaging token : $token");
          usersref.doc(user.id).update({"receiverToken": token});
          usersref.doc(user.id).update({"androidNotificationToken": token});
        });
        print("On Resume : $message");
        _navigateToDetail(message);
      },
      onMessage: (Map<String, dynamic> message) async {
        print("On message : $message\n");

        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          //Notification shown");
          SnackBar snackBar = SnackBar(
            backgroundColor: Colors.blueAccent,
            content: Text(
              body,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            action: SnackBarAction(
                label: "Go",
                textColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ActivityFeed();
                    }),
                  );
                }),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
        //Notifications not shown.");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      //settings registered : $settings");
    });
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersref.doc(user.id).get();

    if (!doc.exists) {
      // 2) if the user does not exist, then we want to take them to the create account page.
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersref.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoURL": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
        "receiverToken": "",
        "searchKey": user.displayName[0],
      });
      //Making user their own follower, i.e., displaying their posts in the timeline
      await followersref
          .doc(user.id)
          .collection('userFollowers')
          .doc(user.id)
          .set({});
      doc = await usersref.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn);
  }

//  buildAuth1Screen() {
//    final Size size = MediaQuery.of(context).size;
//    return Scaffold(
//      key: _scaffoldKey,
//      body: Stack(
//        overflow: Overflow.visible,
//        children: [
//          Positioned(
//            bottom: 0,
//            left: 0,
//            child: Container(
//              width: size.width,
//              height: 80,
//              color: Colors.black,
//              child: Stack(
//                children: <Widget>[
//                  CustomPaint(
//                    size: Size(size.width, 80),
//                    painter: BNBCustomPainter(),
//
////            child: PageView(
////              children: <Widget>[
////                Timeline(currentUser: currentUser),
//////          RaisedButton(
//////            child: Text('Logout'),
//////            onPressed: logout,
//////          ),
////                Search(),
////                Upload(currentUser: currentUser),
////                ActivityFeed(),
////                Profile(profileId: currentUser?.id),
////              ],
////              controller: pageController,
////              onPageChanged: onPageChanged,
////              physics: NeverScrollableScrollPhysics(),
////            ),
//                  ),
//                  Center(
//                    heightFactor: 0.6,
//                    child: FloatingActionButton(
//                        backgroundColor: Colors.orange,
//                        child: Icon(Icons.shopping_basket),
//                        elevation: 0.1,
//                        onPressed: () {
//                          Navigator.push(context,
//                              MaterialPageRoute(builder: (context) {
//                            return Upload(
//                              currentUser: currentUser,
//                            );
//                          }));
//                        }),
//                  ),
//                  Container(
//                    width: size.width,
//                    height: 80,
//                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                        children: [
//                          IconButton(
//                            icon: Icon(
//                              FontAwesome.paw,
//                              color: currentIndex == 0
//                                  ? Colors.orange
//                                  : Colors.grey.shade400,
//                            ),
//                            onPressed: () {
//                              Navigator.push(context,
//                                  MaterialPageRoute(builder: (context) {
//                                return Timeline(
//                                  currentUser: currentUser,
//                                );
//                              }));
//                              setBottomBarIndex(0);
//                            },
//                            splashColor: Colors.white,
//                          ),
//                          IconButton(
//                              icon: Icon(
//                                Icons.search,
//                                color: currentIndex == 1
//                                    ? Colors.orange
//                                    : Colors.grey.shade400,
//                              ),
//                              onPressed: () {
//                                Navigator.push(context,
//                                    MaterialPageRoute(builder: (context) {
//                                  return Search();
//                                }));
//                                setBottomBarIndex(1);
//                              }),
//                          Container(
//                            width: size.width * 0.20,
//                          ),
//                          IconButton(
//                              icon: Icon(
//                                Icons.notifications,
//                                color: currentIndex == 2
//                                    ? Colors.orange
//                                    : Colors.grey.shade400,
//                              ),
//                              onPressed: () {
//                                Navigator.push(context,
//                                    MaterialPageRoute(builder: (context) {
//                                  return ActivityFeed();
//                                }));
//                                setBottomBarIndex(2);
//                              }),
//                          IconButton(
//                              icon: Icon(
//                                FontAwesome.user_circle_o,
//                                color: currentIndex == 3
//                                    ? Colors.orange
//                                    : Colors.grey.shade400,
//                              ),
//                              onPressed: () {
//                                Navigator.push(context,
//                                    MaterialPageRoute(builder: (context) {
//                                  return Profile(profileId: currentUser?.id);
//                                }));
//                                setBottomBarIndex(3);
//                              }),
//                        ]),
//                  ),
//                ],
//              ),
//            ),
//          ),
//        ],
//      ),
////      bottomNavigationBar: CupertinoTabBar(
////          currentIndex: pageIndex,
////          onTap: onTap,
////          inactiveColor: Colors.black,
////          activeColor: Colors.orangeAccent.withOpacity(1),
////          items: [
////            BottomNavigationBarItem(
////              icon: Icon(FontAwesome.paw),
////            ),
////            BottomNavigationBarItem(icon: Icon(FontAwesome.search)),
////            BottomNavigationBarItem(
////              icon: Icon(
////                FontAwesome.plus_square_o,
////                size: 35.0,
////              ),
////            ),
////            BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
////            BottomNavigationBarItem(icon: Icon(FontAwesome.user_circle_o)),
////          ]),
//    );
//    // return RaisedButton(
//    //   child: Text('Logout'),
//    //   onPressed: logout,
//    // );
//  }

//      ),
//      ],
//      ),
//    );
//  }
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
            Profile(
              profileId: currentUser?.id,
            ),
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

  Scaffold buildUnAuthScreen() {
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
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0); // Start
    path.quadraticBezierTo(size.width * 0.10, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width * 7, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
