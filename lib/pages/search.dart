import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_sharemedia/chats/conversation.dart';
import 'package:new_sharemedia/models/user.dart';
import 'package:new_sharemedia/pages/profile.dart';
import 'package:new_sharemedia/utils/constants.dart';
import 'package:new_sharemedia/utils/firebase.dart';
import 'package:new_sharemedia/widgets/indicators.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  User? user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;

  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  getUsers() async {
    QuerySnapshot snap = await usersRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    users = doc;
    filteredUsers = doc;
    setState(() {
      loading = false;
    });
  }

  search(String query) {
    if (query == "") {
      filteredUsers = users;
    } else {
      List userSearch = users.where((userSnap) {
        Map user = userSnap.data() as Map<String, dynamic>;
        String userName = user['username'];
        return userName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredUsers = userSearch as List<DocumentSnapshot<Object?>>;
      });
    }
  }

  removeFromList(index) {
    filteredUsers.removeAt(index);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: buildSearch(),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () => getUsers(),
        child: buildUsers(),
      ),
    );
  }

  Widget buildSearch() {
    return Container(
      height: 45.0,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextField(
        controller: searchController,
        textAlignVertical: TextAlignVertical.center,
        maxLength: 20,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    searchController.clear();
                    search("");
                  },
                  child: Icon(
                    Ionicons.close_circle,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          counterText: '',
          hintText: 'Search users...',
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onChanged: search,
      ),
    );
  }

  Widget buildUsers() {
    if (loading) {
      return Center(child: circularProgress(context));
    }

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              "No Users Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot doc = filteredUsers[index];
        UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

        if (doc.id == currentUserId()) {
          Timer(Duration(milliseconds: 500), () {
            setState(() => removeFromList(index));
          });
          return SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 0.5,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () => showProfile(context, profileId: user.id!),
            leading: Hero(
              tag: user.id!,
              child: user.photoUrl!.isEmpty
                  ? CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        '${user.username![0].toUpperCase()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundImage: CachedNetworkImageProvider(user.photoUrl!),
                    ),
            ),
            title: Text(
              user.username!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // subtitle: Text(
            //   user.email!,
            //   style: TextStyle(fontSize: 13),
            // ),
            trailing: ElevatedButton.icon(
              onPressed: () => navigateToChat(context, doc),
              icon: Icon(Icons.chat_bubble_outline, size: 18),
              label: Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateToChat(BuildContext context, DocumentSnapshot doc) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => StreamBuilder(
          stream: chatIdRef
              .where("users", isEqualTo: getUser(firebaseAuth.currentUser!.uid, doc.id))
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var docs = snapshot.data!.docs;
              return Conversation(
                userId: doc.id,
                chatId: docs.isEmpty ? 'newChat' : docs[0].get('chatId').toString(),
              );
            }
            return Conversation(userId: doc.id, chatId: 'newChat');
          },
        ),
      ),
    );
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }

  //get concatenated list of users
  //this will help us query the chat id reference in other
  // to get the correct user id

  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = "${list[0]}-${list[1]}";
    return chatId;
  }

  @override
  bool get wantKeepAlive => true;
}
