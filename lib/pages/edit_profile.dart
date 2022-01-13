import 'dart:io';

import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/pages/timeline.dart';
import 'package:Pettogram/widgets/buildauthscreen.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  const EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  SharedPreferences preferences;
  File imageFileAvatar;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  String photoUrl = currentUser.photoUrl;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future updateProfileData() async {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 50
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_displayNameValid && _bioValid) {
      await usersref.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      Fluttertoast.showToast(
          msg: "Updated successfully.", backgroundColor: Colors.green);
    }
  }

  Column buildDisplayName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Display Name :",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update DisplayName",
            errorText: _displayNameValid ? null : "Display Name too Short.",
          ),
        ),
      ],
    );
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  Future getImage() async {
    File newImgFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImgFile != null) {
      setState(() {
        this.imageFileAvatar = newImgFile;
        isLoading = true;
      });
    }
    uploadImgToFirestore(newImgFile);
  }

  buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio :",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            errorText: _bioValid ? null : "Description too long.",
            hintText: "Update Bio",
          ),
        ),
      ],
    );
  }

  editprofile() async {
    return FutureBuilder(
        key: _scaffoldKey,
        future: userref.doc(currentUser.id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          } else {
            User user = User.fromDocument(snapshot.data);
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(
                  "Edit Profile",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.done,
                      size: 30.0,
                      color: Colors.green,
                    ),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Home();
                    })),
                  ),
                ],
              ),
              body: isLoading
                  ? linearProgress()
                  : ListView(
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Center(
                                  child: Stack(
                                    children: <Widget>[
                                      (imageFileAvatar == null)
                                          ? (currentUser.photoUrl != "")
                                              ? Material(
                                                  //Displaying existing file/image.
                                                  child: CachedNetworkImage(
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors
                                                                    .orangeAccent),
                                                      ),
                                                      width: 200.0,
                                                      height: 200.0,
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                    ),
                                                    imageUrl:
                                                        currentUser.photoUrl,
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              125.0)),
                                                  clipBehavior: Clip.hardEdge,
                                                )
                                              : Icon(
                                                  Icons.account_circle,
                                                  size: 90.0,
                                                  color: Colors.grey,
                                                )
                                          : Material(
                                              child: CircleAvatar(
                                                radius: 300,
                                                backgroundColor:
                                                    Colors.orangeAccent,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        user.photoUrl == null
                                                            ? user.username[0]
                                                            : user.photoUrl),
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(125.0)),
                                              clipBehavior: Clip.hardEdge,
                                              //Displaying new file/image.
                                            ),
                                      IconButton(
                                        icon: Icon(
                                          FontAwesome.camera,
                                          size: 50,
                                          color: Colors.transparent,
                                        ),
                                        onPressed: getImage,
                                        padding: EdgeInsets.all(0.0),
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.blue,
                                        iconSize: 200.0,
                                      ),
                                    ],
                                  ),
                                ),
                                width: double.infinity,
                                margin: EdgeInsets.all(20.0),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  children: <Widget>[
                                    buildDisplayName(),
                                    buildBioField(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 70),
                                child: RaisedButton(
                                  color: Colors.blue,
                                  onPressed: () {
                                    updateProfileData();
                                  },
                                  child: Text(
                                    "Update Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: RaisedButton(
                                  color: Colors.red,
                                  onPressed: () {
                                    handleLogout(context);
                                  },
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
            );
          }
        });
//    return Scaffold(
//        key: _scaffoldKey,
//        appBar: AppBar(
//          backgroundColor: Colors.white,
//          title: Text(
//            "Edit Profile",
//            style: TextStyle(
//              color: Colors.black,
//            ),
//          ),
//          actions: <Widget>[
//            IconButton(
//                icon: Icon(
//                  Icons.done,
//                  size: 30.0,
//                  color: Colors.green,
//                ),
//                onPressed: () => Navigator.pop(context))
//          ],
//        ),
//        body: isLoading
//            ? linearProgress()
//            : RefreshIndicator(
//          onRefresh: () => editprofile(),
//          child: ListView(
//            children: <Widget>[
//              SingleChildScrollView(
//                child: Column(
//                  children: <Widget>[
//                    Container(
//                      child: Center(
//                        child: Stack(
//                          children: <Widget>[
//                            (imageFileAvatar == null)
//                                ? (currentUser.photoUrl != "")
//                                ? Material(
//                              //Displaying existing file/image.
//                              child: CachedNetworkImage(
//                                placeholder: await (context,
//                                    url) =>
//                                    Container(
//                                      child:
//                                      CircularProgressIndicator(
//                                        strokeWidth: 2.0,
//                                        valueColor:
//                                        AlwaysStoppedAnimation<
//                                            Color>(
//                                            Colors
//                                                .orangeAccent),
//                                      ),
//                                      width: 200.0,
//                                      height: 200.0,
//                                      padding:
//                                      EdgeInsets.all(20.0),
//                                    ),
//                                imageUrl:
//                                await currentUser.photoUrl,
//                                width: 200.0,
//                                height: 200.0,
//                                fit: BoxFit.cover,
//                              ),
//                              borderRadius: BorderRadius.all(
//                                  Radius.circular(125.0)),
//                              clipBehavior: Clip.hardEdge,
//                            )
//                                : Icon(
//                              Icons.account_circle,
//                              size: 90.0,
//                              color: Colors.grey,
//                            )
//                                : Material(
//                              child: Image.network(
//                                await currentUser.photoUrl,
//                                width: 200.0,
//                                height: 200.0,
//                                fit: BoxFit.cover,
//                              ),
//                              borderRadius: BorderRadius.all(
//                                  Radius.circular(125.0)),
//                              clipBehavior: Clip.hardEdge,
//                              //Displaying new file/image.
//                            ),
//                            IconButton(
//                              icon: Icon(
//                                FontAwesome.camera,
//                                size: 50,
//                                color: Colors.transparent,
//                              ),
//                              onPressed: getImage,
//                              padding: EdgeInsets.all(0.0),
//                              splashColor: Colors.transparent,
//                              highlightColor: Colors.blue,
//                              iconSize: 200.0,
//                            ),
//                          ],
//                        ),
//                      ),
//                      width: double.infinity,
//                      margin: EdgeInsets.all(20.0),
//                    ),
//                    Padding(
//                      padding: EdgeInsets.all(16.0),
//                      child: Column(
//                        children: <Widget>[
//                          buildDisplayName(),
//                          buildBioField(),
//                        ],
//                      ),
//                    ),
//                    Padding(
//                      padding: const EdgeInsets.symmetric(
//                          vertical: 3, horizontal: 70),
//                      child: RaisedButton(
//                        color: Colors.blue,
//                        onPressed: () {
//                          updateProfileData();
//                        },
//                        child: Text(
//                          "Update Profile",
//                          style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 20.0,
//                            fontWeight: FontWeight.bold,
//                          ),
//                        ),
//                      ),
//                    ),
//                    Padding(
//                      padding: EdgeInsets.all(16.0),
//                      child: RaisedButton(
//                        color: Colors.red,
//                        onPressed: () {
//                          handleLogout(context);
//                        },
//                        child: Text(
//                          "Logout",
//                          style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 20.0,
//                            fontWeight: FontWeight.bold,
//                          ),
//                        ),
//                      ),
//                    )
//                  ],
//                ),
//              ),
//            ],
//          ),
//        ));
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersref.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUser();
  }

  Future uploadImgToFirestore(newImgFile) async {
    String mFileName = currentUser.id;
    StorageReference storageReference =
        await FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask =
        await storageReference.putFile(newImgFile);
    StorageTaskSnapshot storageTaskSnapshot;
    await storageUploadTask.onComplete.then(
      (value) async {
        if (value.error == null) {
          storageTaskSnapshot = await value;
          await storageTaskSnapshot.ref.getDownloadURL().then(
              (newImageDownloadUrl) async {
            photoUrl = await newImageDownloadUrl;
            await usersref
                .doc(currentUser.id)
                .update({"photoURL": photoUrl, "chattingWith": null});
//
//
            setState(() {
              isLoading = false;
            });
//
            Fluttertoast.showToast(
                msg: "Updated successfully.", backgroundColor: Colors.green);
            await activityref
                .doc(user.id)
                .collection('feedItems')
                .doc(currentUser.id)
                .update({"userProfileImg": user.photoUrl});
          }, onError: (err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "An unexpected error has occured.");
          });
        }
      },
    );
  }

  handleLogout(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Logout?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            children: <Widget>[
              Divider(height: 10, thickness: 1),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    logout();
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done,
                size: 30.0,
                color: Colors.green,
              ),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                return buildAuth();
              })),
            )
          ],
        ),
        body: isLoading
            ? linearProgress()
            : RefreshIndicator(
                onRefresh: () => editprofile(),
                child: ListView(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: Stack(
                                children: <Widget>[
                                  (imageFileAvatar == null)
                                      ? (currentUser.photoUrl != "")
                                          ? Material(
                                              //Displaying existing file/image.
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    Container(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors
                                                                .orangeAccent),
                                                  ),
                                                  width: 200.0,
                                                  height: 200.0,
                                                  padding: EdgeInsets.all(20.0),
                                                ),
                                                imageUrl: currentUser.photoUrl,
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(125.0)),
                                              clipBehavior: Clip.hardEdge,
                                            )
                                          : Icon(
                                              Icons.account_circle,
                                              size: 90.0,
                                              color: Colors.grey,
                                            )
                                      : Material(
                                          child: Image.file(
                                            imageFileAvatar,
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(125.0)),
                                          clipBehavior: Clip.hardEdge,
                                          //Displaying new file/image.
                                        ),
                                  IconButton(
                                    icon: Icon(
                                      FontAwesome.camera,
                                      size: 50,
                                      color: Colors.transparent,
                                    ),
                                    onPressed: getImage,
                                    padding: EdgeInsets.all(0.0),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.blue,
                                    iconSize: 200.0,
                                  ),
                                ],
                              ),
                            ),
                            width: double.infinity,
                            margin: EdgeInsets.all(20.0),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                buildDisplayName(),
                                buildBioField(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 70),
                            child: RaisedButton(
                              color: Colors.blue,
                              onPressed: () {
                                updateProfileData();
                              },
                              child: Text(
                                "Update Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: RaisedButton(
                              color: Colors.red,
                              onPressed: () {
                                handleLogout(context);
                              },
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }
}
