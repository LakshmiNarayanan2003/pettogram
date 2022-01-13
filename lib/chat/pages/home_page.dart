import 'package:Pettogram/chat/pages/chat_page.dart';
import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/home.dart';
import 'package:Pettogram/pages/timeline.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

String authToken;

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserToken;

  HomeScreen({this.currentUserId, this.currentUserToken});

  @override
  State createState() => HomeScreenState(
        currentUserToken: currentUserToken,
        currentUserId: currentUserId,
      );
}

class HomeScreenState extends State<HomeScreen> {
  final String currentUserToken;
  final String currentUserId;
  var queryResultSet = [];
  var tempSearchStore = [];
  List<User> users = [];
  User recentUser;
  List<User_Result> recentUserList = [];
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsField;
  HomeScreenState({this.currentUserToken, this.currentUserId});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      authToken = currentUserToken;
      print(authToken);
    });
  }

  @override
  initiateSearch(query) {
    if (query.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    var capsValue = query.substring(0, 1).toUpperCase() + query.substring(1);
    Future<QuerySnapshot> searchKey = userref
        .where("searchKey", isEqualTo: query.substring(0, 1).toUpperCase())
        .get();
    if (queryResultSet.length == 0 && query.length == 1) {
      searchKey.then((QuerySnapshot doc) {
        for (int i = 0; i < doc.docs.length; ++i) {
          queryResultSet.add(doc.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['displayName'].startsWith(capsValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        userref.where("displayName", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsField = users;
    });
    buildSearchResults();
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      queryResultSet = [];
      tempSearchStore = [];
    });
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsField,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<User_Result> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          users.add(user);
          User_Result searchResult = User_Result(user);

          if (currentUser.id != doc["id"]) {
            searchResults.add(searchResult);
          }
        });

        return ListView(
          shrinkWrap: true,
          children: tempSearchStore.map<Widget>((element) {
            return suggestedUsers(element);
          }).toList(),
        );
      },
    );
  }

  buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: TextField(
        onChanged: (query) {
          initiateSearch(query);
        },
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search!",
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.black,
            ),
            onPressed: clearSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          contentPadding: EdgeInsets.all(8),
        ),
        onSubmitted: handleSearch,
      ),
    );
  }

  suggestedUsers(data) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Chat(
                    receiverToken: authToken,
                    receiverId: data['id'],
                    receiverAvatar: data['photoURL'],
                    receiverName: data['displayName']);
              }));
              recentUser = data as User;
              User_Result searchResult = User_Result(recentUser);

              recentUserList.add(searchResult);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(
                    data['photoURL'] == null
                        ? data['displayName'][0]
                        : data['photoURL']),
              ),
              title: Text(
                data['displayName'],
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                data['username'],
                style: TextStyle(color: Colors.black38),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              "Connect & Share",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 40.0,
                  fontStyle: FontStyle.italic,
                  fontFamily: "Kalam"),
            )
          ],
        ),
      ),
    );

//      Container(
//        child: Center(
//          child: ListView(shrinkWrap: true, children: <Widget>[
//            ListTile(
//              leading: CircleAvatar(
//                backgroundColor: Colors.black,
//                backgroundImage: CachedNetworkImageProvider(
//                    recentUserphotoUrl[0] == null
//                        ? recentUserDisplayName[0][0]
//                        : recentUserphotoUrl[0]),
//              ),
//              title: Text(
//                recentUserDisplayName[0],
//                style: TextStyle(
//                  color: Colors.black87,
//                  fontWeight: FontWeight.bold,
//                ),
//              ),
//              subtitle: Text(
//                recentUsername[0],
//                style: TextStyle(color: Colors.black38),
//              ),
//            ),
//            Divider(
//              height: 2.0,
//              color: Colors.white54,
//            ),
//          ]),
//        ),
//      );
  }

  buildrecentResults() {
//    final suggestionList = searchResultsField == null
//        ? users.where((name) => name.startsWith(searchResultsField)).toList()
//        : Text("");
    return ListView(
      shrinkWrap: true,
      children: recentUserList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResultsField == null
          ? recentUserList == null
              ? buildNoContent()
              : buildrecentResults()
          : buildSearchResults(),
    );
  }
}
//  handleSearch(String query) {
//    Future<QuerySnapshot> users =
//        usersref.where("displayName", isGreaterThanOrEqualTo: query).get();
//    setState(() {
//      searchResultsField = users;
//    });
//  }
//
//  clearSearch() {
//    searchController.clear();
//  }
//
//  buildSearchResults() {
//    return FutureBuilder(
//      future: searchResultsField,
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return circularProgress();
//        }
//        List<User_Result> searchResults = [];
//        snapshot.data.documents.forEach((doc) {
//          User user = User.fromDocument(doc);
//          User_Result searchResult = User_Result(user);
//
//          if (currentUser.id != doc["id"]) {
//            searchResults.add(searchResult);
//          }
//        });
//        return ListView(
//          children: searchResults,
//        );
//      },
//    );
//  }
//
//  AppBar buildSearchField() {
//    return AppBar(
//      backgroundColor: Colors.white,
//      title: TextFormField(
//        controller: searchController,
//        decoration: InputDecoration(
//          hintText: "Search",
//          filled: true,
//          prefixIcon: Icon(
//            Icons.search,
//            size: 28.0,
//          ),
//          suffixIcon: IconButton(
//            icon: Icon(
//              Icons.clear,
//              color: Colors.black,
//            ),
//            onPressed: clearSearch,
//          ),
//          border: OutlineInputBorder(
//            borderRadius: BorderRadius.circular(10),
//          ),
//          contentPadding: EdgeInsets.all(8),
//        ),
//        onFieldSubmitted: handleSearch,
//      ),
//      automaticallyImplyLeading: false,
//      centerTitle: true,
//    );
//  }
//
//  buildNoContent() {
//    final Orientation orientation = MediaQuery.of(context).orientation;
//    return Container(
//      child: Center(
//        child: ListView(
//          shrinkWrap: true,
//          children: <Widget>[
//            SvgPicture.asset(
//              'assets/images/search.svg',
//              height: orientation == Orientation.portrait ? 300.0 : 200.0,
//            ),
//            Text(
//              "Connect & share!",
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                color: Colors.black,
//                fontSize: 40.0,
//                fontStyle: FontStyle.italic,
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: buildSearchField(),
//      body:
//          searchResultsField == null ? buildNoContent() : buildSearchResults(),
//    );
//  }

class User_Result extends StatelessWidget {
  final User user;

  User_Result(this.user);
  @override
  Widget build(BuildContext context) {
    show_chatscreen(BuildContext context) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Chat(
            receiverToken: authToken,
            receiverId: user.id,
            receiverAvatar: user.photoUrl,
            receiverName: user.displayName);
      }));
    }

    return Container(
      color: Colors.grey.withOpacity(0.01),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              show_chatscreen(context);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(
                    user.photoUrl == null
                        ? user.displayName[0]
                        : user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.black38),
              ),
            ),
          ),
          Divider(
            thickness: 1.0,
            height: 2.0,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
