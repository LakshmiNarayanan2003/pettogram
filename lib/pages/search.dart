import 'package:Pettogram/models/user.dart';
import 'package:Pettogram/pages/activity_feed.dart';
import 'package:Pettogram/pages/timeline.dart';
import 'package:Pettogram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

//class Search extends SearchDelegate<String> {
//  @override
//  List<Widget> buildActions(BuildContext context) {
//    //clear button
//    return [
//      IconButton(
//        icon: Icon(Icons.clear),
//        color: Colors.grey,
//        onPressed: () {
//          query = "";
//        },
//      )
//    ];
//  }
//
//  @override
//  Widget buildLeading(BuildContext context) {
//    //Circular Avatar of the particular user on the left side
//    return IconButton(
//      icon: AnimatedIcon(
//          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
//      onPressed: () {
//        close(context, null);
//      },
//    );
//  }
//
//  @override
//  Widget buildResults(BuildContext context) {
//    // TODO: implement buildResults
//    throw UnimplementedError();
//  }
//
//  @override
//  Widget buildSuggestions(BuildContext context) {
//    final suggestionList = query.isEmpty
//        ? recentCities
//        : cities.where((name) => name.startsWith(query)).toList();
//    return ListView.builder(
//      itemBuilder: (context, index) => ListTile(
//          leading: Icon(Icons.location_city),
//          title: RichText(
//            text: TextSpan(
//                text: suggestionList[index].substring(0, query.length),
//                style: TextStyle(
//                  color: Colors.black,
//                  fontWeight: FontWeight.bold,
//                ),
//                children: [
//                  TextSpan(
//                      text: suggestionList[index].substring(query.length),
//                      style: TextStyle(color: Colors.grey)),
//                ]),
//          )),
//      itemCount: suggestionList.length,
//    );
//  }
//}
//class Search extends StatefulWidget {
//  @override
//  _SearchState createState() => _SearchState();
//}
//
//class _SearchState extends State<Search> {
//  TextEditingController searchController = TextEditingController();
//  Future<QuerySnapshot> searchResultsField;
//  List recentSuggestions = [];
//
//  handleSearch(String query) {
//    Future<QuerySnapshot> users =
//        userref.where("displayName", isGreaterThanOrEqualTo: query).get();
//    setState(() {
//      recentSuggestions.add(searchResultsField);
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
//        List<UserResult> searchResults = [];
//        snapshot.data.documents.forEach((doc) {
//          User user = User.fromDocument(doc);
//          UserResult searchResult = UserResult(user);
//          searchResults.add(searchResult);
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
//          hintText: "Woof. Right here!",
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
//              "Find Pets",
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                  color: Colors.black,
//                  fontSize: 40.0,
//                  fontStyle: FontStyle.italic,
//                  fontFamily: "Kalam"),
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

User recentUser;
List<User> users = [];
List<UserResult> recentUserList = [];
bool colorSearch = false;

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var queryResultSet = [];
  var tempSearchStore = [];
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsField;
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
      colorSearch = false;
      searchResultsField = users;
    });
    buildSearchResults();
  }

  clearSearch() {
    setState(() {
      colorSearch = true;
    });
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
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          users.add(user);
          recentUser = user;
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
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
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: TextField(
        onChanged: (query) {
          initiateSearch(query);
        },
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: colorSearch == true ? Colors.black87 : Colors.grey,
            ),
            onPressed: clearSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10),
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
              showProfile(context, profileId: data['id']);

              UserResult searchResult = UserResult(recentUser);

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
              "Find Pets",
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
      body:
          searchResultsField == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              recentUser = user;
              UserResult searchResult = UserResult(recentUser);
              if (recentUserList.contains(searchResult)) {
                return null;
              } else {
                recentUserList.add(searchResult);
              }
              showProfile(context, profileId: user.id);
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
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
