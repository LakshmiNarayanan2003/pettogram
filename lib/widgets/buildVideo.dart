import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class buildVideo extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final bool autoPlay;
  final bool showControlsOnInitialize;
  buildVideo(
      {this.videoPlayerController,
      this.looping,
      this.autoPlay,
      this.showControlsOnInitialize});
  @override
  _buildVideoState createState() => _buildVideoState();
}

class _buildVideoState extends State<buildVideo> {
  ChewieController _chewieController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chewieController = ChewieController(
        materialProgressColors: ChewieProgressColors(
            backgroundColor: Colors.transparent,
            playedColor: Colors.orange,
            bufferedColor: Colors.grey.shade500),
        showControls: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        autoPlay: widget.autoPlay,
        videoPlayerController: widget.videoPlayerController,
        aspectRatio: 9 / 9,
        autoInitialize: true,
        looping: widget.looping,
        allowFullScreen: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(errorMessage,
                style: TextStyle(
                    color: Colors.white, backgroundColor: Colors.black)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
  }
}

//class VideoWidget extends StatefulWidget {
//  @override
//  _VideoWidgetState createState() => _VideoWidgetState();
//}
//
//class _VideoWidgetState extends State<VideoWidget> {
//  VideoPlayerController videoPlayerController;
//  Future<void> _initializeVideoPlayerFuture;
//
//  @override
//  Widget build(BuildContext context) {
//    return Container();
//  }
//}
