import 'package:Pettogram/pages/activity_feed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class ThumbnailTest extends StatefulWidget {
  @override
  _ThumbnailTestState createState() => _ThumbnailTestState();
}

class _ThumbnailTestState extends State<ThumbnailTest> {
  @override
  VideoPlayerController _controller;

  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(
        'https://firebasestorage.googleapis.com/v0/b/pettogram2003.appspot.com/o/Videos%2FSLN_d26d7239-6954-44e3-8bff-368bc6cc8d3f.mp4?alt=media&token=b2058bb1-0ce6-4589-a452-456627332b04')
      ..initialize().then((_) {
        setState(() {});
      });
    Permission.storage.isGranted;
    Permission.accessMediaLocation.isGranted;
//    Directory("Thumbfiles").create(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(),
      child: GestureDetector(
          onTap: () => showPost(context), child: VideoPlayer(_controller)),
    );
  }

//    var thumbnail = Thumbnails.getThumbnail(
//        videoFile:
//            'https://firebasestorage.googleapis.com/v0/b/pettogram2003.appspot.com/o/Videos%2FSLN_d26d7239-6954-44e3-8bff-368bc6cc8d3f.mp4?alt=media&token=b2058bb1-0ce6-4589-a452-456627332b04',
////        thumbnailFolder: 'Thumbfiles',
//        imageType: ThumbFormat.JPEG,
//        quality: 60);
//    CachedNetworkImageProvider(thumbnail);
//    var url;
//    return FutureBuilder(
//        future: thumbnail,
//        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//          if (!snapshot.hasData) {
//            CircularProgressIndicator();
//          }
//          thumbnail.then((String result) {
//            setState(() {
//              print(result);
//              url = result;
//            });
//          });
//          return Image.network(url.toString());
//        });
//  }
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

//class ThumbnailTest extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    var thumbnail = Thumbnails.getThumbnail(
//        videoFile:
//            'https://firebasestorage.googleapis.com/v0/b/pettogram2003.appspot.com/o/Videos%2FSLN_d26d7239-6954-44e3-8bff-368bc6cc8d3f.mp4?alt=media&token=b2058bb1-0ce6-4589-a452-456627332b04',
//        thumbnailFolder: '/storage/emulated/0/Videos/Thumbnails',
//        imageType: ThumbFormat.JPEG,
//        quality: 60);
//    var url;
//    return FutureBuilder(
//        future: thumbnail,
//        builder: (BuildContext context, snapshot) {
//          if (!snapshot.hasData) {
//            circularProgress();
//          }
//          thumbnail.then((String result) {
//            setState(() {
//              url = result;
//            });
//          });
//          return Image.network(thumbnail.then((value) {
//            return value;
//          }).toString());
//        });
////    return Scaffold(
////      appBar: AppBar(
////        title: Text("Pettogram"),
////      ),
////      body: VideoCompress.getFileThumbnail('https://firebasestorage.googleapis.com/v0/b/pettogram2003.appspot.com/o/Videos%2FSLN_d26d7239-6954-44e3-8bff-368bc6cc8d3f.mp4?alt=media&token=b2058bb1-0ce6-4589-a452-456627332b04')
////    );
//  }
//}
