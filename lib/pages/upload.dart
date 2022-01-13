import 'dart:io';

import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/widgets/buildVideo.dart';
import 'package:Pettogram/widgets/buildauthscreen.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

String videoUrl;

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  VideoPlayerController videoPlayerController;
  File file;
  ChewieController _chewieController;

  bool isVideo = false;
  bool looping;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleFromCamera() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  Future handleFromGalleryVideo() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
    setState(() {
      isVideo = true;
      this.file = file;
    });
//    var uuid = Uuid();
//    dynamic id = uuid.v1();
//    googleSignIn.signInSilently(suppressErrors: false).then((value) async {
//      StorageReference ref = FirebaseStorage.instance
//          .ref()
//          .child("Videos")
//          .child("${widget.currentUser.username}_$postId.mp4");
//      StorageUploadTask uploadTask =
//          ref.putFile(file, StorageMetadata(contentType: 'video/mp4'));
//      var storageTaskSnapshot = await uploadTask.onComplete;
//      var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
//      final String url = downloadUrl.toString();
//      setState(() {
//        videoUrl = url;
//      });
//      setState(() {});
//    });
  }

  handleFromGalleryImage() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Create Post",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Kalam"),
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Divider(
                height: 10,
                thickness: 2,
                color: Colors.black,
              ),
            ),
            SimpleDialogOption(
              child: Text(
                "Take a picture!",
              ),
              onPressed: handleFromCamera,
            ),
            Divider(
              height: 10,
              thickness: 0.3,
            ),
            SimpleDialogOption(
              onPressed: handleFromGalleryImage,
              child: Text("Upload Images!"),
            ),
            Divider(
              height: 10,
              thickness: 0.3,
            ),
            SimpleDialogOption(
              onPressed: handleFromGalleryVideo,
              child: Text("Upload Videos!"),
            ),
            Divider(
              height: 10,
              thickness: 0.3,
            ),
            SimpleDialogOption(
              child: Text("Choose from others post."),
            ),
            Divider(
              height: 10,
              thickness: 0.5,
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade500,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Colors.orangeAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "Upload Images",
                  style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Kalam"),
                ),
                color: Colors.red.withOpacity(0.5),
                onPressed: () => selectImage(context)),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageRef
        .child("post_${widget.currentUser.username}_$postId.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postref.doc(widget.currentUser.id).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  createPostInFirestoreVideo(
      {String mediaUrl, String location, String description}) {
    postref.doc(widget.currentUser.id).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile =
        File('$path/img_${widget.currentUser.username}_$postId.jpg')
          ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future videoSubmit() async {
    Fluttertoast.showToast(
        msg: "Will be uploaded shortly, continue browsing!",
        backgroundColor: Colors.deepOrange);
    setState(() {
      isUploading = true;
    });
    var uuid = Uuid();
    dynamic id = uuid.v1();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("Videos")
        .child("${widget.currentUser.username}_$postId.mp4");
    StorageUploadTask uploadTask =
        ref.putFile(file, StorageMetadata(contentType: 'video/mp4'));
    var storageTaskSnapshot = await uploadTask.onComplete;
    var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    final String url = downloadUrl.toString();
    createPostInFirestoreVideo(
      mediaUrl: url,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      isVideo = false;
      videoUrl = url;
      postId = Uuid().v4();
    });

    Fluttertoast.showToast(
        msg: "Posted successfully!", backgroundColor: Colors.deepOrange);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return buildAuth();
    }));
  }

  handleSubmit() async {
    Fluttertoast.showToast(
        msg: "Will be uploaded shortly, continue browsing!",
        backgroundColor: Colors.deepOrange);
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
    Fluttertoast.showToast(
        msg: "Posted successfully!", backgroundColor: Colors.deepOrange);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return buildAuth();
    }));
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading
                ? null
                : () {
                    if (isVideo == false) {
                      handleSubmit();
                    } else {
                      videoSubmit();
                    }
                  },
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          ListTile(
            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage: CachedNetworkImageProvider(
                  widget.currentUser.photoUrl == null
                      ? widget.currentUser.username[0]
                      : widget.currentUser.photoUrl),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 25),
              child: Container(
                width: 250.0,
                child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                    hintText: "Describe here!",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.black,
            height: 10,
            thickness: 2,
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: isVideo == false
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 9 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(file),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 9 / 9,
                          child: buildVideo(
                            videoPlayerController:
                                VideoPlayerController.file(file),
                            looping: false,
                            autoPlay: true,
                          ),
                        ),
                      ),
                    )),
          Divider(
            color: Colors.black,
            height: 10,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 3),
            child: ListTile(
              leading: Icon(
                Icons.place,
                color: Colors.blueAccent.withOpacity(0.9),
                size: 35.0,
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: "Where was this photo taken?",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.5),
            height: 10,
            thickness: 1,
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}.";
    locationController.text = formattedAddress;
  }

  bool get wantKeepAlive => true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Permission.location.isGranted;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    buildVideo();
    videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
