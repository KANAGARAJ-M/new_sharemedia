import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_sharemedia/models/post.dart';
import 'package:new_sharemedia/utils/firebase.dart';
import 'package:new_sharemedia/widgets/indicators.dart';
import 'package:new_sharemedia/widgets/userpost.dart';

class ListPosts extends StatefulWidget {
  final userId;

  final username;

  const ListPosts({Key? key, required this.userId, required this.username})
      : super(key: key);

  @override
  State<ListPosts> createState() => _ListPostsState();
}

class _ListPostsState extends State<ListPosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Ionicons.chevron_back, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.username.toUpperCase(),
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'Posts',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: FutureBuilder(
          future: postRef
              .where('ownerId', isEqualTo: widget.userId)
              .orderBy('timestamp', descending: true)
              .get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var snap = snapshot.data;
              List docs = snap!.docs;
              return docs.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      PostModel posts = PostModel.fromJson(docs[index].data());
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        child: UserPost(post: posts),
                      );
                    },
                  );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            } else {
              return _buildEmptyState();
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.documents_outline,
            size: 60,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          SizedBox(height: 10),
          Text(
            'No Posts Yet',
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Posts will appear here',
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
