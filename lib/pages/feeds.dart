import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:ionicons/ionicons.dart';
import 'package:new_sharemedia/chats/recent_chats.dart';
import 'package:new_sharemedia/models/post.dart';
import 'package:new_sharemedia/utils/constants.dart';
import 'package:new_sharemedia/utils/firebase.dart';
import 'package:new_sharemedia/widgets/indicators.dart';
import 'package:new_sharemedia/widgets/story_widget.dart';
import 'package:new_sharemedia/widgets/userpost.dart';

class Feeds extends StatefulWidget {
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int page = 5;
  bool loadingMore = false;
  bool showStory = true;
  ScrollController mainScrollController = ScrollController();
  ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    mainScrollController.addListener(() {
      // Check scroll direction and update story visibility
      if (mainScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (showStory) {
          setState(() {
            showStory = false;
          });
        }
      }
      if (mainScrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!showStory) {
          setState(() {
            showStory = true;
          });
        }
      }
    });

    listScrollController.addListener(() {
      // Pagination logic
      if (listScrollController.position.pixels == listScrollController.position.maxScrollExtent) {
        setState(() {
          page = page + 5;
          loadingMore = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    mainScrollController.dispose();
    listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Ionicons.chatbubble_ellipses,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => Chats(),
                ),
              );
            },
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () =>
            postRef.orderBy('timestamp', descending: true).limit(page).get(),
        child: SingleChildScrollView(
          controller: mainScrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AnimatedContainer(
              //   duration: Duration(milliseconds: 200),
              //   height: showStory ? null : 0,
              //   child: showStory ? StoryWidget() : Container(),
              // ),
              Container(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: postRef
                      .orderBy('timestamp', descending: true)
                      .limit(page)
                      .get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      var snap = snapshot.data;
                      List docs = snap!.docs;
                      return ListView.builder(
                        controller: listScrollController,
                        itemCount: docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          PostModel posts =
                              PostModel.fromJson(docs[index].data());
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: UserPost(post: posts),
                          );
                        },
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return circularProgress(context);
                    } else
                      return Center(
                        child: Text(
                          'No Feeds',
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
