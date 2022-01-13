import 'package:Pettogram/pages/StartPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Pettogram",
    home: StartScreen(),
  ));
}
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:Pettogram/pages/activity_feed.dart';
//import 'package:Pettogram/pages/profile.dart';
//import 'package:Pettogram/pages/search.dart';
//import 'package:Pettogram/pages/timeline.dart';
//import 'package:Pettogram/pages/upload.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//
//final GoogleSignIn googleSignIn = GoogleSignIn();
//final StorageReference storageRef = FirebaseStorage.instance.ref();
//final userref = FirebaseFirestore.instance.collection('users');
//final postref = FirebaseFirestore.instance.collection('posts');
//User currentUser;
//
//final DateTime timestamp = DateTime.now();
//
//class Home extends StatefulWidget {
//  @override
//  _HomeState createState() => _HomeState();
//}
//
//class _HomeState extends State<Home> {
//  bool isAuth = false;
//  PageController pageController;
//  int pageIndex = 0;
//
//  @override
//  void initState() {
//    super.initState();
//    pageController = PageController();
//    // Detects when user signed in
//    googleSignIn.onCurrentUserChanged.listen((account) {
//      handleSignIn(account);
//    }, onError: (err) {
//      print('Error signing in: $err');
//    });
//    // Reauthenticate user when app is opened
//    googleSignIn.signInSilently(suppressErrors: false).then((account) {
//      handleSignIn(account);
//    }).catchError((err) {
//      print('Error signing in: $err');
//    });
//  }
//
//  handleSignIn(GoogleSignInAccount account) {
//    if (account != null) {
//      print('User signed in!: $account');
//      setState(() {
//        isAuth = true;
//      });
//    } else {
//      setState(() {
//        isAuth = false;
//      });
//    }
//  }
//
//  @override
//  void dispose() {
//    pageController.dispose();
//    super.dispose();
//  }
//
//  login() {
//    googleSignIn.signIn();
//  }
//
//  logout() {
//    googleSignIn.signOut();
//  }
//
//  onPageChanged(int pageIndex) {
//    setState(() {
//      this.pageIndex = pageIndex;
//    });
//  }
//
//  onTap(int pageIndex) {
//    pageController.jumpToPage(
//      pageIndex,
//    );
//  }
//
//  Scaffold buildAuthScreen() {
//    return Scaffold(
//      body: PageView(
//        children: <Widget>[
//          //Timeline(),
//          ActivityFeed(),
//          Upload(currentUser: currentUser,),
//          Search(),
//          Profile(),
//        ],
//        controller: pageController,
//        onPageChanged: onPageChanged,
//        physics: NeverScrollableScrollPhysics(),
//      ),
//      bottomNavigationBar: CupertinoTabBar(
//          currentIndex: pageIndex,
//          onTap: onTap,
//          activeColor: Theme.of(context).primaryColor,
//          items: [
//            BottomNavigationBarItem(
//              icon: Icon(Icons.whatshot),
//            ),
//            BottomNavigationBarItem(
//              icon: Icon(Icons.notifications_active),
//            ),
//            BottomNavigationBarItem(
//              icon: Icon(
//                Icons.photo_camera,
//                size: 35.0,
//              ),
//            ),
//            BottomNavigationBarItem(
//              icon: Icon(Icons.search),
//            ),
//            BottomNavigationBarItem(
//              icon: Icon(Icons.account_circle),
//            ),
//          ]),
//    );
//    // return RaisedButton(
//    //   child: Text('Logout'),
//    //   onPressed: logout,
//    // );
//  }
//
//  Scaffold buildUnAuthScreen() {
//    return Scaffold(
//      body: Container(
//        decoration: BoxDecoration(
//          gradient: LinearGradient(
//            begin: Alignment.topRight,
//            end: Alignment.bottomLeft,
//            colors: [
//              Theme.of(context).accentColor,
//              Theme.of(context).primaryColor,
//            ],
//          ),
//        ),
//        alignment: Alignment.center,
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              'Pettogram',
//              style: TextStyle(
//                fontFamily: "Signatra",
//                fontSize: 90.0,
//                color: Colors.white,
//              ),
//            ),
//            GestureDetector(
//              onTap: login,
//              child: Container(
//                width: 260.0,
//                height: 60.0,
//                decoration: BoxDecoration(
//                  image: DecorationImage(
//                    image: AssetImage(
//                      'assets/images/google_signin_button.png',
//                    ),
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
//  }
//}
