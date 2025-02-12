import 'dart:io';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;
  final bool isNetworkImage;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
    required this.onClicked,
    this.isNetworkImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = isNetworkImage
        ? NetworkImage(imagePath)
        : FileImage(File(imagePath)) as ImageProvider;

    return Center(
      child: Stack(
        children: [
          buildYellowFrame(image),
          if (isEdit)
            Positioned(
              bottom: 0,
              right: 0,
              child: buildEditIcon(context),
            ),
        ],
      ),
    );
  }

  Widget buildYellowFrame(ImageProvider image) {
    return Container(
      padding: EdgeInsets.all(4), // Thickness of the yellow border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.yellow, width: 4),
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: image,
            fit: BoxFit.cover,
            width: 128,
            height: 128,
            child: InkWell(onTap: onClicked),
          ),
        ),
      ),
    );
  }

  Widget buildEditIcon(BuildContext context) {
    return buildCircle(
      color: Colors.white,
      all: 3,
      child: buildCircle(
        color: Theme.of(context).colorScheme.secondary,
        all: 8,
        child: Icon(
          isEdit ? Icons.add_a_photo : Icons.edit,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
  }
}
