import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<StatefulWidget> createState() {
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

  void _sendMessage() {
    final enteredMessages = _inputMessageController.text;

    if (enteredMessages.trim().isEmpty) {
      return;
    }

    // send the entered message to firebase database

    _inputMessageController.clear();
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
