import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/rtc.dart';

import '../constants/colors.dart';
import '../widgets/live_stream_player_widget.dart';
import '../widgets/live_stream_widget.dart';

class LiveStreamScreen extends StatefulWidget {
  final String meetingId;
  final String downStreamUrl;
  const LiveStreamScreen({
    Key? key,
    required this.meetingId,
    this.downStreamUrl = "",
  }) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  Meeting? meeting;

  bool micEnabled = true;
  bool webcamEnabled = true;
  bool isViewerMode = false;

  @override
  void initState() {
    super.initState();

    // Set orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Check viewer mode
    setState(() {
      isViewerMode = widget.downStreamUrl.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        // Check viewer mode
        child: isViewerMode
            // Live Stream Player
            ? LiveStreamPlayerWidget(
                downStreamUrl: widget.downStreamUrl,
                onJoinButtonPressed: changeToHostMode,
              )
            // Live Stream
            : LiveStreamWidget(
                meetingId: widget.meetingId,
              ),
      ),
    );
  }

  @override
  void dispose() {
    // Set orientation to auto
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void changeToHostMode() {
    // Change to host mode
    setState(() => isViewerMode = false);
  }
}
