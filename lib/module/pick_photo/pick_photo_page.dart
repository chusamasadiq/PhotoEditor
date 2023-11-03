import 'package:flutter/material.dart';
import 'package:photo_editor/module/edit_photo/presentation/edit_photo_screen.dart';

class PickPhotoPage extends StatefulWidget {
  const PickPhotoPage({Key? key}) : super(key: key);

  @override
  State<PickPhotoPage> createState() => _PickPhotoPageState();
}

class _PickPhotoPageState extends State<PickPhotoPage> {
  String selectedImage = "assets/images/pexels.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Editor'),
      ),
      body: Column(
        children: [
          Image.asset(selectedImage),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Edit Image'),
            onPressed: () => pickImage(),
          ),
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPhotoScreen(
          image: AssetImage(selectedImage),
        ),
      ),
    );
  }
}
