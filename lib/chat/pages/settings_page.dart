import 'dart:io';

import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class settings_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.orangeAccent,
        title: Text(
          "Account Settings",
          style: TextStyle(
            fontFamily: "Kalam",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _displayNameValid = true;
  bool _bioValid = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nickFocusNode = FocusNode();
  final FocusNode bioFocusNode = FocusNode();
  readDataFromLocal() async {}
  Future getImage() async {
    File newImgFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImgFile != null) {
      setState(() {
        this.imageFileAvatar = newImgFile;
        isLoading = true;
      });
    }
  }

  Future uploadImgToFirestore() async {
    String mFileName = currentUser.id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(mFileName);
    StorageUploadTask storageUploadTask =
        storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
//          currentUser.photoUrl=newImageDownloadUrl;
          Firestore.instance
              .collection('users')
              .doc(currentUser.id)
              .update({"photoUrl": newImageDownloadUrl, "chattingWith": null});
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "An unexpected error has occured.");
        });
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }

  logout() {
    googleSignIn.signOut();
  }

  updateData() {
    setState(() {
      nicknameController.text.trim().length < 3 ||
              nicknameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 50
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_displayNameValid && _bioValid) {
      usersref.doc(currentUser.id).update({
        "displayName": nicknameController.text,
        "bio": bioController.text,
      });
      SnackBar snackbar = SnackBar(
        content: Text("Profile Updated!"),
        backgroundColor: Colors.orange,
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _scaffoldKey,
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
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.orangeAccent),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(125.0)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125.0)),
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
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isLoading ? linearProgress() : Container(),
                  ),
                  Container(
                    child: Text(
                      "About me",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.orangeAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Bio..",
                          contentPadding: EdgeInsets.all(5.0),
                          helperStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        controller: bioController,
                        onChanged: updateData(),
                        focusNode: bioFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                  //BIO
                  Container(
                    child: Text(
                      "Profile Name",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.orangeAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Bio",
                          contentPadding: EdgeInsets.all(5.0),
                          helperStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        controller: nicknameController,
                        onChanged: updateData(),
                        focusNode: nickFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              //Button
              Container(
                child: FlatButton(
                  onPressed: null,
                  child: Text(
                    "Update",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Colors.lightBlueAccent,
                  highlightColor: Colors.blue,
                  splashColor: Colors.transparent,
                  textColor: Colors.black,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
              ),
              Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0),
                child: RaisedButton(
                  onPressed: logout,
                  child: Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
