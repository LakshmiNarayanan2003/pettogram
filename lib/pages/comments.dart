import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/pages/profile.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postownerId;
  final String postmediaUrl;

  Comments({this.postId, this.postownerId, this.postmediaUrl});

  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postownerId: this.postownerId,
      postmediaUrl: this.postmediaUrl);
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postownerId;
  final String postmediaUrl;

  CommentsState({this.postId, this.postownerId, this.postmediaUrl});
  @override
  Widget build(BuildContext context) {
    buildComments() {
      return StreamBuilder(
          stream: commentsref
              .doc(postId)
              .collection('comments')
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<Comment> comments = [];
            snapshot.data.documents.forEach((doc) {
              comments.add(Comment.fromDocument(doc));
            });
            return ListView(children: comments);
          });
    }

    addComment() {
      commentsref.doc(postId).collection('comments').add({
        "username": currentUser.username,
        "comment": commentController.text,
        "timestamp": timestamp,
        "avatarUrl": currentUser.photoUrl,
        "userId": currentUser.id,
        "postId": postId,
      });
      bool isNotPostOwner = postownerId != currentUser.id;
      if (isNotPostOwner) {
        activityref.doc(postownerId).collection('feedItems').add({
          "type": "comment",
          "commentData": commentController.text,
          "timestamp": timestamp,
          "postId": postId,
          "userId": currentUser.id,
          "username": currentUser.username,
          "userProfileImg": currentUser.photoUrl,
          "mediaUrl": postmediaUrl,
        });
      }

      commentController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        title: Text(
          "Comments",
          style: TextStyle(
            fontFamily: "Kalam",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: TextFormField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Write a comment..",
                  ),
                ),
              ),
              trailing: OutlineButton(
                onPressed: addComment,
                borderSide: BorderSide.none,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    "Post",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment(
      {this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp});
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc.data()['username'],
      userId: doc.data()['userId'],
      avatarUrl: doc.data()['avatarUrl'],
      comment: doc.data()['comment'],
      timestamp: doc.data()['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Profile(
                profileId: userId,
              );
            }));
          },
          title: Text(comment),
          leading: CircleAvatar(
            backgroundColor: Colors.orangeAccent,
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(TimeAgo.getTimeAgo(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
