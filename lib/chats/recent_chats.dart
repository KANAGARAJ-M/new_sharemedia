import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_sharemedia/components/chat_item.dart';
import 'package:new_sharemedia/models/message.dart';
import 'package:new_sharemedia/utils/firebase.dart';
import 'package:new_sharemedia/view_models/user/user_view_model.dart';
import 'package:new_sharemedia/widgets/indicators.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserViewModel viewModel =
        Provider.of<UserViewModel>(context, listen: false);
    viewModel.setUser();
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.keyboard_backspace),
        ),
        title: Text("Chats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userChatsStream('${viewModel.user!.uid ?? ""}'),
        builder: (context, snapshot) {
          // Add error handling
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          // Check connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: circularProgress(context));
          }

          if (snapshot.hasData) {
            List chatList = snapshot.data!.docs;
            if (chatList.isEmpty) {
              return Center(child: Text('No Chats'));
            }

            return ListView.separated(
              itemCount: chatList.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot chatListSnapshot = chatList[index];
                return StreamBuilder<QuerySnapshot>(
                  stream: messageListStream(chatListSnapshot.id),
                  builder: (context, snapshot) {
                    // Add error handling for nested StreamBuilder
                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error loading chat'),
                        subtitle: Text('Please try again later'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                        leading: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      List messages = snapshot.data!.docs;
                      Message message = Message.fromJson(
                        messages.first.data(),
                      );
                      List users = chatListSnapshot.get('users');
                      users.remove('${viewModel.user!.uid ?? ""}');
                      String recipient = users[0];
                      
                      return ChatItem(
                        userId: recipient,
                        messageCount: messages.length,
                        msg: message.content!,
                        time: message.time!,
                        chatId: chatListSnapshot.id,
                        type: message.type!,
                        currentUserId: viewModel.user!.uid ?? "",
                      );
                    }
                    
                    return SizedBox();
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 0.5,
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Divider(),
                  ),
                );
              },
            );
          }
          
          return Center(child: circularProgress(context));
        },
      ),
    );
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return chatRef
        .where('users', arrayContains: '$uid')
        .orderBy('lastTextTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }
}
