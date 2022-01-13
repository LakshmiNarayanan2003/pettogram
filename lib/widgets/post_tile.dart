import 'package:Pettogram/pages/post_screen.dart';
import 'package:Pettogram/widgets/custom_image.dart';
import 'package:Pettogram/widgets/post.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class PostTile extends StatefulWidget {
  final Post post;

  PostTile({this.post});
  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  VideoPlayerController _controller;
  String finalthumbnail;

  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(widget.post.mediaUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    Permission.storage.isGranted;
    Permission.accessMediaLocation.isGranted;
  }

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  userId: widget.post.ownerId,
                  postId: widget.post.postId,
                )));
  }

  profileContent(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(),
      child: GestureDetector(
        onTap: () => showPost(context),
        child: widget.post.mediaUrl.contains(".mp4")
            ? VideoPlayer(_controller)
            : cachedNetworkImage(widget.post.mediaUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return profileContent(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}
