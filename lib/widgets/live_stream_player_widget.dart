import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Live Stream Player Widget
class LiveStreamPlayerWidget extends StatefulWidget {
  final String downStreamUrl;
  final void Function() onJoinButtonPressed;
  const LiveStreamPlayerWidget({
    Key? key,
    required this.downStreamUrl,
    required this.onJoinButtonPressed,
  }) : super(key: key);

  @override
  State<LiveStreamPlayerWidget> createState() => _LiveStreamPlayerWidgetState();
}

class _LiveStreamPlayerWidgetState extends State<LiveStreamPlayerWidget> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    // Initialize Chewie Controller
    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(
        widget.downStreamUrl,
      ),
      autoPlay: true,
      showControls: false,
      aspectRatio: 16 / 9,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Chewie(controller: _chewieController),
        Positioned(
          bottom: 2,
          left: 2,
          right: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Join Button
              ElevatedButton(
                onPressed: widget.onJoinButtonPressed,
                child: const Text("Join"),
              ),

              // Leave Button
              ElevatedButton(
                onPressed: () {
                  try {
                    _chewieController.dispose();
                    Navigator.of(context).pop();
                  } catch (e) {
                    log(e.toString());
                  }
                },
                child: const Text("Leave"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    try {
      _chewieController.dispose();
    } catch (err) {
      log(err.toString());
    }
    super.dispose();
  }
}
