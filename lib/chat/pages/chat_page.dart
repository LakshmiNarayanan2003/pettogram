import 'dart:io';
import 'dart:ui';

import 'package:Pettogram/chat/widgets/full_image_widget.dart';
import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/activity_feed.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverToken;
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  Chat(
      {this.receiverId,
      this.receiverAvatar,
      this.receiverName,
      this.receiverToken});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                showProfile(context, profileId: receiverId);
              },
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(
                    receiverAvatar == null ? receiverName[0] : receiverAvatar),
              ),
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          receiverName,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(
          receiverToken: receiverToken,
          receiverId: receiverId,
          receiverAvatar: receiverAvatar,
          receiverName: receiverName),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverToken;
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  ChatScreen(
      {this.receiverId,
      this.receiverAvatar,
      this.receiverName,
      this.receiverToken});
  @override
  State createState() => ChatScreenState(
        receiverId: receiverId,
        receiverAvatar: receiverAvatar,
        receiverName: receiverName,
        receiverToken: receiverToken,
      );
}

class ChatScreenState extends State<ChatScreen> {
  File imgFile;
  final String receiverToken;
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;
  final ScrollController listScrollController = ScrollController();
  final TextEditingController chatTextController = TextEditingController();
  final FocusNode ChatFocusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading = false;
  GiphyGif _gif;
  String imageUrl;
  String chatId;
  String id;
  var listMsg;
  User user;
  SharedPreferences preferences;
  ChatScreenState(
      {this.receiverId,
      this.receiverAvatar,
      this.receiverName,
      this.receiverToken});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatId = "";
    readLocal();
    ChatFocusNode.addListener(onFocusChange);
    isDisplaySticker = false;
    isLoading = false;
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = currentUser.id;
    if (id.hashCode <= receiverId.hashCode) {
      chatId = '$id-$receiverId';
    } else {
      chatId = '$receiverId-$id';
    }
    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"chattingWith": receiverId});
  }

  onFocusChange() {
    if (ChatFocusNode.hasFocus) {
      //Hiding stickers when keypad appears.
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  Future getImgFromGallery() async {
    imgFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imgFile != null) {
      isLoading = true;
    } else {
      return;
    }
    uploadImgFile();
  }

  uploadImgFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("chat Images").child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imgFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      sendMsg(imageUrl, 1);
      setState(() {
        isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Error : $error",
          textColor: Colors.white,
          backgroundColor: Colors.red);
    });
  }

  @override
  void sendMsg(String contentMsg, int type) {
    //type==0 text message,
    //type==1, image file,
    //type 2,  gif/emoji,
    if (contentMsg != "") {
      chatTextController.clear();
      var docRef = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('messageInfo')
          .doc(DateTime.now().millisecondsSinceEpoch.toString());
      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          docRef,
          {
            "idFrom": currentUser.id,
            "idTo": receiverId,
            "timestamp": timestamp.millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
            "receiverName": receiverName,
            "fromUser": currentUser.username,
            "chatId": chatId,
            "receiverToken": receiverToken,
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Empty Message. Cannot be sent.");
    }
  }

  getGIF() async {
    final gif = await GiphyPicker.pickGif(
        title: Text(
          "GIF",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: "Kalam"),
        ),
        fullScreenDialog: true,
        showPreviewPage: true,
        decorator: GiphyDecorator(
          showAppBar: false,
          searchElevation: 4,
          giphyTheme: ThemeData.dark(),
        ),
        searchText: 'Search for GIF',
        context: context,
        apiKey: 'LTtim1zfq4StYjVmwlBvLZ9X33qL7XU4');

    ChatFocusNode.unfocus();
    sendMsg(gif.images.original.url, 2);
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(5.0),
      height: 180,
    );
  }

//  createStickers() {
//    return Container(
//      child: Column(
//        children: <Widget>[
//          FlatButton(
//              onPressed: null,
//              child: Image.asset(
//                'images/mimi1.gif',
//                width: 50.0,
//                height: 50.0,
//                fit: BoxFit.cover,
//              ))
//        ],
//      ),
//    );
//  }
  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createLoading() {
    return Positioned(
      child: isLoading ? linearProgress() : Container(),
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //Create list of messages
              createListMsg(),
              Divider(),
              //Showing Stickers
//              isDisplaySticker ? createStickers() : Container(),

              //Input controllers
              createInput(),
            ],
          ),
//          createLoading(),
        ],
      ),
    );
  }

  createListMsg() {
    return Flexible(
      child: chatId == ""
          ? Padding(
              padding: const EdgeInsets.only(top: 200, bottom: 420),
              child: Text(
                "Start typing the message, to view the chat.",
                softWrap: true,
                style: TextStyle(
                    decorationStyle: TextDecorationStyle.double,
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.black),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatId)
                  .collection('messageInfo')
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                } else {
                  listMsg = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return createItem(index, snapshot.data.documents[index]);
                    },
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              }),
    );
  }

  bool isLastMsgLeft(index) {
    if ((index > 0 &&
            listMsg != null &&
            listMsg[index - 1]["idFrom"] == currentUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(index) {
    if ((index > 0 &&
            listMsg != null &&
            listMsg[index - 1]['idFrom'] != currentUser.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot document) {
    //My messages - Right side.
    if (document["idFrom"] == currentUser.id) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          document["type"] == 0
              ? Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 27.0),
                )
              :
              //IMG files
              document["type"] == 1
                  ? Container(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullPhoto(url: document["content"]),
                              ));
                        },
                        child: Material(
                          child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.deepOrange),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                  ),
                              errorWidget: (context, url, error) => Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                              imageUrl: document["content"],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  :
                  //GIF/sticker
                  Container(
                      child: CachedNetworkImage(
                        imageUrl: document["content"],
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 27.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else
    //Received Messages - Left
    {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMsgLeft(index)
                    //Profile img
                    ? Material(
                        child: GestureDetector(
                          onTap: () {
                            showProfile(context, profileId: receiverId);
                          },
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepOrange),
                              ),
                              width: 35.0,
                              height: 35.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: receiverAvatar,
                            width: 35.0,
                            height: 35.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35.0,
                      ),
                //Display Messages
                document["type"] == 0
                    ? Container(
                        child: Text(
                          document["content"],
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMsgLeft(index) ? 20.0 : 10.0,
                            left: 15),
                      )
                    : document["type"] == 1
                        ? Container(
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullPhoto(url: document["content"]),
                                    ));
                              },
                              child: Material(
                                child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.deepOrange),
                                          ),
                                          width: 200.0,
                                          height: 200.0,
                                          padding: EdgeInsets.all(70.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Material(
                                          child: Image.asset(
                                            'images/img_not_available.jpeg',
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                    imageUrl: document["content"],
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                            ),
                            margin: EdgeInsets.only(
                              right: 25.0,
                            ),
                          )
                        :
                        //GIF/sticker
                        Container(
                            child: CachedNetworkImage(
                              imageUrl: document["content"],
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                                left: 17),
                          ),
              ],
            ),

            //Time of the message sent
            SafeArea(
              child: Text(
                DateFormat(
                        "\t\t        \n                    dd MMMM, yyyy - hh:mm:aa")
                    .format(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document["timestamp"]))),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                ),
                softWrap: true,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  createInput() {
    return Container(
      child: Row(
        children: <Widget>[
          //IMG from Gallery
          Material(
            borderOnForeground: true,
            child: Container(
              child: IconButton(
                  icon: Icon(
                    Icons.crop_original,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: getImgFromGallery),
            ),
          ),
          //GIF
          Material(
            borderOnForeground: true,
            child: Container(
              child: IconButton(
                  icon: Icon(
                    Icons.gif,
                  ),
                  color: Colors.grey.shade700,
                  onPressed: getGIF),
            ),
          ),
          //Text field
          Flexible(
              child: Container(
            child: TextField(
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
              ),
              controller: chatTextController,
              decoration: InputDecoration.collapsed(
                hintText: "Type the message",
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
              focusNode: ChatFocusNode,
            ),
          )),
          Material(
            borderRadius: BorderRadius.only(),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 0.0),
              child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.deepOrange,
                  ),
                  onPressed: () => sendMsg(chatTextController.text, 0)),
            ),
            color: Colors.white,
          )
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}
