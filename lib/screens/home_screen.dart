import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../constants/colors.dart';
import 'live_stream_screen.dart';

// HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final liveStreamIdController = TextEditingController();
  bool isBusy = false;

  @override
  Widget build(BuildContext context) {
    // Called when the user taps the start livestreaming button
    void onCreateButtonPressed() async {
      // Set the state to busy
      setState(() => isBusy = true);
      String? meetingId = liveStreamIdController.text;
      // Check if the meeting id is empty
      if (meetingId.isEmpty) {
        meetingId = await ApiService.getMeetingId();
      }
      // Check if the meeting id is null or empty
      if (meetingId?.isEmpty ?? true) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to get live streaming id"),
          ),
        );
        // Set the state to not busy
        setState(() => isBusy = false);
        return;
      }

      //  Set the state to not busy
      setState(() => isBusy = false);

      // Navigate to the live streaming screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveStreamScreen(meetingId: meetingId!),
        ),
      );
    }

    // Called when the user taps the join live streaming button
    void onJoinButtonPressed() async {
      // Check if the live streaming id is empty
      if (liveStreamIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a live streaming ID"),
        ));
        return;
      }

      // Set the state to busy
      setState(() => isBusy = true);

      // Get downstreamUrl
      String? downStreamUrl = await ApiService.getDownStreamUrl(
        liveStreamIdController.text,
      );

      // Check if the downstreamUrl is null or empty
      if (downStreamUrl?.isEmpty ?? true) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to get live streaming url"),
        ));
        // Set the state to not busy
        setState(() => isBusy = false);
        return;
      }

      // Set the state to not busy
      setState(() => isBusy = false);

      // Navigate to the live streaming screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveStreamScreen(
            meetingId: liveStreamIdController.text,
            downStreamUrl: downStreamUrl!,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  const Text(
                    "VideoSDK HLS Demo",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Live streaming text field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: liveStreamIdController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: "Enter LiveStream ID",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Start Live Streaming Button
                      ElevatedButton(
                        onPressed: isBusy ? null : onCreateButtonPressed,
                        child: const Text("Start LiveStreaming"),
                      ),

                      // Join Live Streaming Button
                      ElevatedButton(
                        onPressed: isBusy ? null : onJoinButtonPressed,
                        child: const Text("Join LiveStreaming"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Loading indicator
            if (isBusy)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Please Wait"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
