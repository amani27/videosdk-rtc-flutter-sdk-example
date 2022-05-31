import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'constants/colors.dart';

void main() {
  runApp(const VideoSDKApp());
}

// VideoSDK App
class VideoSDKApp extends StatelessWidget {
  const VideoSDKApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material App
    return MaterialApp(
      // App Title
      title: 'VideoSDK HLS Demo',
      // App Theme
      theme: ThemeData.dark().copyWith(
        primaryColor: primaryColor,
        backgroundColor: secondaryColor,
      ),
      // Home Page
      home: const HomeScreen(),
    );
  }
}
