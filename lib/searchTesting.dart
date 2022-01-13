//import 'package:Pettogram/models/user.dart';
//import 'package:Pettogram/pages/activity_feed.dart';
//import 'package:Pettogram/pages/timeline.dart';
//import 'package:Pettogram/widgets/progress.dart';
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
//
//TextEditingController searchController = TextEditingController();
//Future<QuerySnapshot> searchResultsField;
//
//class SearchState extends SearchDelegate<String> {
//  handleSearch(String query) {
//    Future<QuerySnapshot> users =
//    userref.where("displayName", isGreaterThanOrEqualTo: query).get();
//    searchResultsField = users;
//
//  }
//
//  clearSearch() {
//    searchController.clear();
//  }
//
//  AppBar buildSearchField() {
//    return AppBar(
//      backgroundColor: Colors.white,
//      title: TextFormField(
//        controller: searchController,
//        decoration: InputDecoration(
//          hintText: "Woof. Right here!",
//          filled: true,
//          prefixIcon: Icon(
//            Icons.search,
//            size: 28.0,
//          ),
//
//          border: OutlineInputBorder(
//            borderRadius: BorderRadius.circular(10),
//          ),
//          contentPadding: EdgeInsets.all(8),
//        ),
//
//      ),
//    );
//  }
//
////  buildNoContent() {
////    final Orientation orientation = MediaQuery.of(context).orientation;
////    return Container(
////      child: Center(
////        child: ListView(
////          shrinkWrap: true,
////          children: <Widget>[
////            SvgPicture.asset(
////              'assets/images/search.svg',
////              height: orientation == Orientation.portrait ? 300.0 : 200.0,
////            ),
////            Text(
////              "Find Pets",
////              textAlign: TextAlign.center,
////              style: TextStyle(
////                  color: Colors.black,
////                  fontSize: 40.0,
////                  fontStyle: FontStyle.italic,
////                  fontFamily: "Kalam"),
////            )
////          ],
////        ),
////      ),
////    );
////  }
//
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: buildSearchField(),
//      body:
//
//      searchResultsField == null ? buildNoContent() : buildResults(context),
//    );
//  }
//
//  @override
//  List<Widget> buildActions(BuildContext context) {
//    return [IconButton(
//      icon: Icon(
//        Icons.clear,
//        color: Colors.black.withOpacity(0.8),
//      ),
//      onPressed: clearSearch,
//    ),];
//  }
//
//  @override
//  Widget buildLeading(BuildContext context) {
//    return IconButton(
//      icon: AnimatedIcon(
//        icon: AnimatedIcons.menu_arrow,
//        progress: transitionAnimation,
//      ),
//      onPressed: () {
//        Navigator.pop(context);
//      },
//    );
//  }
//  @override
//  // TODO: implement query
//
//  @override
//  Widget buildResults(BuildContext context) {
//    return FutureBuilder(
//
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return circularProgress();
//
//        }
//        List<UserResult> searchResults = [];
//        snapshot.data.documents.forEach((doc) {
//          User user = User.fromDocument(doc);
//          UserResult searchResult = UserResult(user);
//          searchResults.add(searchResult);
//        });
//        return ListView(
//
//          children: searchResults,
//        );
//      },
//    );
//  }
//
//  @override
//  Widget buildSuggestions(BuildContext context) {
//    var suggestionList= query.isEmpty ? query.
//  }
//}
//
//class UserResult extends StatelessWidget {
//  final User user;
//
//  UserResult(this.user);
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      color: Colors.grey.shade200,
//      child: Column(
//        children: <Widget>[
//          GestureDetector(
//            onTap: () {
//              showProfile(context, profileId: user.id);
//            },
//            child: ListTile(
//              leading: CircleAvatar(
//                backgroundColor: Colors.black,
//                backgroundImage: CachedNetworkImageProvider(
//                    user.photoUrl == null
//                        ? user.displayName[0]
//                        : user.photoUrl),
//              ),
//              title: Text(
//                user.displayName,
//                style: TextStyle(
//                  color: Colors.black87,
//                  fontWeight: FontWeight.bold,
//                ),
//              ),
//              subtitle: Text(
//                user.username,
//                style: TextStyle(color: Colors.black38),
//              ),
//            ),
//          ),
//          Divider(
//            height: 2.0,
//            color: Colors.white54,
//          ),
//        ],
//      ),
//    );
//  }
//}
