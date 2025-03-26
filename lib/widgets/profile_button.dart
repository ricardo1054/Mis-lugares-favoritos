import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileButton extends StatefulWidget {
  const ProfileButton({super.key});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: _profileImage != null
          ? CircleAvatar(
              backgroundImage: FileImage(_profileImage!),
              radius: 16,
            )
          : const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person),
            ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0,
          child: Text('Cambiar foto de perfil'),
        ),
        if (_profileImage != null)
          const PopupMenuItem(
            value: 1,
            child: Text('Eliminar foto'),
          ),
      ],
      onSelected: (value) {
        if (value == 0) {
          _selectImage();
        } else if (value == 1) {
          setState(() {
            _profileImage = null;
          });
        }
      },
    );
  }
}
