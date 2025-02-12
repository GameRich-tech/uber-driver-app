import 'dart:io';

import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/widgets/profile_widgets/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/user.dart';
import '../../widgets/profile_widgets/profile_round_widget.dart';
import '../../widgets/profile_widgets/text_field_widget.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    _nameController =
        TextEditingController(text: userProvider.user?.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppConstants.lightPrimary,
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: AppConstants.lightPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: AppConstants.defaultTextSize,
              fontWeight: AppConstants.defaultWeight),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24),
            ProfileWidget(
              imagePath: _image?.path ?? "${userProvider.user?.photoURL}",
              isEdit: true,
              onClicked: _pickImage,
              isNetworkImage: _image == null,
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Full Name',
              text: _nameController.text,
              onChanged: (name) {
                _nameController.text = name;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Update the user details
                await userProvider.updateProfile(
                  displayName: _nameController.text,
                  photoFile: _image,
                );
                changeScreenReplacement(context, ProfileScreen());
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
