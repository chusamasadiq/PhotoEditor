import 'package:flutter/material.dart';
import 'package:photo_editor/module/pick_photo/pick_photo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      title: "Photo Editor App",
      themeMode: ThemeMode.system,
      home: const PickPhotoPage(),
    );
  }
}
