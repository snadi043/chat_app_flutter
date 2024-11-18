import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
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
              itemBuilder: (context, index) =>
                  Text(loadedMessages[index].data()['userText']));
        });
  }
}
