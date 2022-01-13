import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/widgets/buildVideo.dart';
import 'package:Pettogram/widgets/post.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostScreen extends StatefulWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postref
          .doc(widget.userId)
          .collection('userPosts')
          .doc(widget.postId)
          .get(),
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
                shrinkWrap: true,
                children: <Widget>[
                  SafeArea(
                    child: Container(
                      child: post.mediaUrl.contains(".mp4")
                          ? buildVideo(
                              videoPlayerController:
                                  VideoPlayerController.network(post.mediaUrl),
                              looping: true,
                              autoPlay: true,
                              showControlsOnInitialize: true,
                            )
                          : post,
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    buildVideo();
  }
}
