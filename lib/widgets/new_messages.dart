import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() {
    return _NewMessages();
  }
}

class _NewMessages extends State<NewMessages> {
  final _inputMessageController = TextEditingController();

  @override
  void dispose() {
    _inputMessageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final enteredMessages = _inputMessageController.text;

    if (enteredMessages.trim().isEmpty) {
      return;
    }

    _inputMessageController.clear();
    FocusScope.of(context).unfocus();

    // send the entered message to firebase database
    final userInfo = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userInfo.uid)
        .get();
    await FirebaseFirestore.instance.collection('users-chat').add({
      'userId': userInfo.uid,
      'timeStamp': Timestamp.now(),
      'userText': enteredMessages,
      'userImage': userData.data()!['image'],
      'username': userData.data()!['username'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1),
      child: Row(children: [
        Expanded(
            child: TextField(
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          enableSuggestions: true,
          controller: _inputMessageController,
          decoration: const InputDecoration(
            labelText: 'Send a message...',
          ),
        )),
        IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary),
      ]),
    );
  }
}
