import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String receiverToken;
  final String chattingWith;
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;
  final String username;
  final String bio;
  final String searchKey;
  String androidNotificationToken;

  User(
      {this.id,
      this.searchKey,
      this.receiverToken,
      this.username,
      this.photoUrl,
      this.email,
      this.displayName,
      this.bio,
      this.androidNotificationToken,
      this.chattingWith});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      receiverToken: doc.data()['receiverToken'],
      chattingWith: doc.data()['chattingWith'],
      id: doc.data()['id'],
      searchKey: doc.data()['searchKey'],
      username: doc.data()['username'],
      photoUrl: doc.data()['photoURL'],
      email: doc.data()['email'],
      displayName: doc.data()['displayName'],
      bio: doc.data()['bio'],
      androidNotificationToken: doc.data()['androidNotificationToken'],
    );
  }
}
