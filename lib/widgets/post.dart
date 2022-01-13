//import 'dart:async';
//
//import 'package:animator/animator.dart';
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/scheduler.dart';
//import 'package:Pettogram/models/user.dart';
//import 'package:Pettogram/pages/comments.dart';
//import 'package:Pettogram/pages/home.dart';
//import 'package:Pettogram/widgets/progress.dart';
//
//import 'custom_image.dart';
//
//class Post extends StatefulWidget {
//  final String postId;
//  final String ownerId;
//  final String username;
//  final String location;
//  final String description;
//  final String mediaUrl;
//  final dynamic likes;
//
//  Post(
//      {this.postId,
//      this.ownerId,
//      this.username,
//      this.location,
//      this.description,
//      this.mediaUrl,
//      this.likes});
//  factory Post.fromDocument(DocumentSnapshot doc) {
//    return Post(
//      postId: doc.data()['postId'],
//      ownerId: doc.data()['ownerId'],
//      username: doc.data()['username'],
//      location: doc.data()['location'],
//      description: doc.data()['description'],
//      mediaUrl: doc.data()['mediaUrl'],
//      likes: doc.data()['likes'],
//    );
//  }
//  int getLikeCount(likes) {
//    int count = 0;
//    if (likes == null) {
//      return 0;
//    }
//    likes.values.forEach((val) {
//      if (val == true) {
//        count += 1;
//      }
//    });
//    return count;
//  }
//
//  @override
//  _PostState createState() => _PostState(
//        postId: this.postId,
//        ownerId: this.ownerId,
//        username: this.username,
//        location: this.location,
//        description: this.description,
//        mediaUrl: this.mediaUrl,
//        likes: this.likes,
//        likeCount: getLikeCount(this.likes),
//      );
//}
//
//class _PostState extends State<Post> {
//  final String currentUserId = currentUser.id;
//  final String postId;
//  final String ownerId;
//  final String username;
//  final String location;
//  final String description;
//  final String mediaUrl;
//  int likeCount;
//  Map likes;
//  bool isLiked;
//  bool showHeart = false;
//
//  _PostState(
//      {this.postId,
//      this.ownerId,
//      this.username,
//      this.location,
//      this.description,
//      this.mediaUrl,
//      this.likes,
//      this.likeCount});
//  @override
//  void dispose() {
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    handleLikePost() {
//      bool _isLiked = likes[currentUserId] == true;
//      if (_isLiked) {
//        postref
//            .doc(ownerId)
//            .collection('userPosts')
//            .doc(postId)
//            .update({'likes.$currentUserId': false});
//        setState(() {
//          likeCount -= 1;
//          isLiked = false;
//          likes[currentUserId] = false;
//        });
//      } else if (!_isLiked) {
//        postref
//            .doc(ownerId)
//            .collection('userPosts')
//            .doc(postId)
//            .update({'likes.$currentUserId': true});
//        setState(() {
//          likeCount += 1;
//          isLiked = true;
//          likes[currentUserId] = true;
//          showHeart = true;
//          Timer(Duration(milliseconds: 500), () {
//            setState(() {
//              showHeart = false;
//            });
//          });
//        });
//      }
//    }
//
//    buildPostHeader() {
//      return FutureBuilder(
//          future: usersref.doc(ownerId).get(),
//          builder: (context, snapshot) {
//            if (!snapshot.hasData) {
//              return circularProgress();
//            }
//            User user = User.fromDocument(snapshot.data);
//            return ListTile(
//              leading: CircleAvatar(
//                backgroundImage: NetworkImage("${user.photoUrl}"),
//                backgroundColor: Colors.orange,
//              ),
//              title: GestureDetector(
//                child: Text(
//                  user.username,
//                  style: TextStyle(
//                    color: Colors.black,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//              ),
//              subtitle: Text(location),
//              trailing: IconButton(
//                  icon: Icon(
//                    Icons.more_vert,
//                    color: Colors.black,
//                  ),
//                  onPressed: () => print("ok google ")),
//            );
//          });
//    }
//
//    buildPostImage() {
//      return GestureDetector(
//        onDoubleTap: handleLikePost,
//        child: Stack(
//          alignment: Alignment.center,
//          children: <Widget>[
//            CachedNetworkImage(
//              imageUrl: mediaUrl,
//              placeholder: (context, url) => new CircularProgressIndicator(),
//              errorWidget: (context, url, error) => RaisedButton.icon(
//                  onPressed: cachedNetworkImage(mediaUrl),
//                  icon: Icon(Icons.error),
//                  label: Text("Could not load image.")),
//            ),
//            showHeart
//                ? Animator(
//                    duration: Duration(milliseconds: 300),
//                    tween: Tween(begin: 0.8, end: 1.4),
//                    curve: Curves.elasticOut,
//                    cycles: 0,
//                    builder: (context, animatorState, child) => Transform.scale(
//                      scale: animatorState.value,
//                      child: Icon(
//                        Icons.favorite,
//                        size: 80,
//                        color: Colors.red,
//                      ),
//                    ),
//                  )
//                : Text(""),
//          ],
//        ),
//      );
//    }
//
//    buildPostFooter() {
//      return Column(
//        children: <Widget>[
//          Row(
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              Padding(
//                padding: EdgeInsets.only(top: 40.0, left: 20.0),
//              ),
//              GestureDetector(
//                onTap: handleLikePost,
//                child: Icon(
//                  isLiked ? Icons.favorite : Icons.favorite_border,
//                  size: 28.0,
//                  color: Colors.pink,
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.only(right: 20.0),
//              ),
//              GestureDetector(
//                onTap: showComments(
//                  context,
//                  postId: postId,
//                  ownerId: ownerId,
//                  mediaUrl: mediaUrl,
//                ),
//                child: Icon(
//                  Icons.chat,
//                  size: 28.0,
//                  color: Colors.black87,
//                ),
//              ),
//            ],
//          ),
//          Row(
//            children: <Widget>[
//              Container(
//                margin: EdgeInsets.only(left: 20.0),
//                child: Text(
//                  "$likeCount Likes",
//                  style: TextStyle(
//                    color: Colors.black,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//              ),
//            ],
//          ),
//          Padding(
//            padding: const EdgeInsets.only(top: 8.0),
//            child: Row(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Container(
//                  margin: EdgeInsets.only(left: 20.0),
//                  child: Text(
//                    "$username :\t ",
//                    style: TextStyle(
//                      color: Colors.black,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                ),
//                Expanded(child: Text(description)),
//                Container(
//                  alignment: Alignment.topLeft,
//                  margin: EdgeInsets.only(left: 20.0),
//                  child: Text(
//                    "$timestamp",
//                    style: TextStyle(
//                      color: Colors.black,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ],
//      );
//    }
//
//    isLiked = (likes[currentUserId] == true);
//    return Column(
//      mainAxisSize: MainAxisSize.min,
//      children: <Widget>[
//        buildPostHeader(),
//        buildPostImage(),
//        buildPostFooter(),
//      ],
//    );
//  }
//}
//
//showComments(BuildContext context,
//    {String postId, String ownerId, String mediaUrl}) {
//  Future.delayed(Duration.zero, () async {
//    SchedulerBinding.instance.addPostFrameCallback((_) {
//      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//        return Comments(
//          postId: postId,
//          postownerId: ownerId,
//          postmediaUrl: mediaUrl,
//        );
//      }));
//    });
//  });
//}
import 'dart:async';

import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/activity_feed.dart';
import 'package:Pettogram/pages/comments.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/widgets/custom_image.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc.data()['postId'],
      ownerId: doc.data()['ownerId'],
      username: doc.data()['username'],
      location: doc.data()['location'],
      description: doc.data()['description'],
      mediaUrl: doc.data()['mediaUrl'],
      likes: doc.data()['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;

  bool showHeart = false;
  bool isLiked;
  int likeCount;
  Map likes;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });
  buildPostHeader() {
    return FutureBuilder(
      future: usersref.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(Icons.more_vert),
                )
              : Text(""),
        );
      },
    );
  }

//Delete post : ownerId==currentuserId.
  deletePost() async {
    postref
        .doc(currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //Deleting the uplaoded image.
    storageRef.child("post_$postId.jpg").delete();
    //Deleting all activity feed notification
    QuerySnapshot activityFeedSnapshot = await activityref
        .doc(currentUser.id)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    QuerySnapshot commentSnapshot =
        await commentsref.doc(postId).collection('comments').get();
    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Delete this post?"),
            children: <Widget>[
              Divider(height: 10, thickness: 1),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
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

  addLikeToActivityFeed() async {
    bool isNotPostOwner = currentUser != ownerId;
    if (isNotPostOwner) {
      await activityref.doc(ownerId).collection('feedItems').doc(postId).set({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() async {
    bool isNotPostOwner = currentUser != ownerId;
    if (isNotPostOwner) {
      await activityref
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  handleLikePost() async {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      await postref
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      await postref
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: mediaUrl,
            placeholder: (context, url) => new CircularProgressIndicator(),
            errorWidget: (context, url, error) => RaisedButton.icon(
                onPressed: cachedNetworkImage(mediaUrl),
                icon: Icon(Icons.error),
                label: Text("Could not load image.")),
          ),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, animatorState, child) => Transform.scale(
                    scale: animatorState.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.red,
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                FontAwesome.comment_o,
                size: 30.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  "$username :\t",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Text(description)),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  "$timestamp",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postownerId: ownerId,
      postmediaUrl: mediaUrl,
    );
  }));
}
