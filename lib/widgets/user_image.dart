import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  const UserImage({super.key, required this.onSelectedImage});

  final void Function(File pickedImage) onSelectedImage;

  @override
  State<UserImage> createState() {
    return _UserImageState();
  }
}

class _UserImageState extends State<UserImage> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (pickedFile == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedFile.path);
    });

    widget.onSelectedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text('Add Image',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.primary))),
      ],
    );
  }
}
