import 'package:chat_app/widgets/message_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users-chat')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages found...'));
          }
          if (chatSnapshot.hasError) {
            return const Center(child: Text('Something went wrong...'));
          }
          final loadedMessages = chatSnapshot.data!.docs;

          return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(left: 13, right: 13, bottom: 40),
              itemCount: loadedMessages.length,
              itemBuilder: (context, index) {
                final chatMessages = loadedMessages[index].data();
                final nextChatMessage = (index + 1) < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
                final currentMessageUserId = chatMessages['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;
                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;
                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessages['userText'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessages['userImage'],
                      username: chatMessages['username'],
                      message: chatMessages['userText'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
              });
        });
  }
}
