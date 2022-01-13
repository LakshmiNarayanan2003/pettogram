import 'package:Pettogram/pages/grid_layout.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/pages/post_screen.dart';
import 'package:Pettogram/pages/profile.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_time_ago/get_time_ago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  String activityFeed = "likes";
  @override
  Widget build(BuildContext context) {
    getActivityFeed() async {
      QuerySnapshot snapshot = await activityref
          .doc(currentUser.id)
          .collection('feedItems')
          .orderBy("timestamp", descending: true)
          .limit(50)
          .get();
      List<ActivityFeedItem> feedItems = [];
      snapshot.docs.forEach((doc) {
        feedItems.add(ActivityFeedItem.fromDocument(doc));
      });
//        print('Activity Feed item : ${doc.data()}');
//      });
      return feedItems;
    }

    buildFeed() {
      return Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return Container(
              child: ListView(
                shrinkWrap: true,
                children: snapshot.data,
              ),
            );
          },
        ),
      );
    }

    setFeedOrientation(String activityFeed) {
      setState(() {
        this.activityFeed = activityFeed;
      });
    }

    buildToggleFeedOrientation() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => setFeedOrientation("likes"),
            color: activityFeed == "likes" ? Colors.red : Colors.grey,
          ),
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () => setFeedOrientation("comment"),
            color: activityFeed == "comment" ? Colors.black87 : Colors.grey,
          )
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Notifications",
          style: TextStyle(
              fontFamily: "Kalam",
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          buildToggleFeedOrientation(),
          Divider(
            thickness: 1,
          ),
          buildFeed(),
        ],
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem(
      {this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.postId,
      this.userProfileImg,
      this.commentData,
      this.timestamp});
  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc.data()['username'],
      userId: doc.data()['userId'],
      type: doc.data()['type'],
      postId: doc.data()['postId'],
      userProfileImg: doc.data()['userProfileImg'],
      commentData: doc.data()['commentData'],
      timestamp: doc.data()['timestamp'],
      mediaUrl: doc.data()['mediaUrl'],
    );
  }
  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  userId: userId,
                  postId: postId,
                )));
  }

  showGridPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Grid_Screen(
                  userId: userId,
                  postId: postId,
                )));
  }

  configureMediaPreview(context) {
    if (type == "like") {
      mediaPreview = GestureDetector(
        onTap: () {
          showGridPost(context);
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(mediaUrl),
              )),
            ),
          ),
        ),
      );
    } else if (type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () {
          showGridPost(context);
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(currentUser.photoUrl),
              )),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (type == "like") {
      activityItemText = " liked your post.";
    } else if (type == "comment") {
      activityItemText = " replied : $commentData";
    } else if (type == 'follow') {
      activityItemText = " is following you.";
    } else {
      activityItemText = 'Error: Unknown type. $type';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () {
              showProfile(context, profileId: userId);
            },
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '$activityItemText'),
                  ]),
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              showProfile(context, profileId: userId);
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          subtitle: Text(
            timeago.TimeAgo.getTimeAgo(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Profile(
                profileId: profileId,
                postTestId: postref.id,
              )));
}

showPost(context, {String userId, String postId}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostScreen(
                userId: userId,
                postId: postId,
              )));
}
