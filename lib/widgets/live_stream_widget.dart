import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:videosdk/rtc.dart';

import '../services/api_service.dart';

class LiveStreamWidget extends StatefulWidget {
  final String meetingId;
  const LiveStreamWidget({Key? key, required this.meetingId}) : super(key: key);

  @override
  State<LiveStreamWidget> createState() => _LiveStreamWidgetState();
}

class _LiveStreamWidgetState extends State<LiveStreamWidget> {
  Meeting? meeting;
  bool micEnabled = true;
  bool webcamEnabled = true;
  bool isStreamingStarted = false;
  bool isBusy = false;
  Map<String, Stream> videoStreams = {};

  @override
  Widget build(BuildContext context) {
    return MeetingBuilder(
      meetingId: widget.meetingId,
      token: ApiService.authToken,
      displayName: "Yash Chudasama",
      maxResolution: "hd",
      micEnabled: micEnabled,
      webcamEnabled: webcamEnabled,
      notification: const NotificationInfo(
        title: "Video SDK",
        message: "Video SDK is sharing screen in the meeting",
        icon: "notification_share", // drawable icon name
      ),
      builder: (_meeting) {
        _meeting.on(Events.meetingJoined, () {
          log("Meeting joined");

          // Assign meeting object
          setState(() => meeting = _meeting);

          // Set stream event listeners for local participant
          setStreamEvents(meeting!.localParticipant);

          // Set stream event listeners for remote participants
          meeting!.on(
            Events.participantJoined,
            (participant) => setStreamEvents(participant),
          );

          // Remove stream when participant leaves
          meeting!.on(Events.participantLeft, (String participantId) {
            log("Participant left");
            if (videoStreams.containsKey(participantId)) {
              setState(() => videoStreams.remove(participantId));
            }
          });
        });

        // If meeting is not joined yet, show loading indicator
        if (meeting == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text("Starting LiveStreaming"),
              ],
            ),
          );
        }

        return Stack(
          children: [
            videoStreams.isEmpty
                ? Container()
                : GridView.count(
                    // Set crossAxisCount to 1 when there is only one participant
                    crossAxisCount: videoStreams.length == 1 ? 1 : 2,
                    // Set AspectRatio to 16:9 when there is only one participant
                    childAspectRatio: videoStreams.length == 1 ? 16 / 9 : 1,
                    children: videoStreams.values
                        .map(
                          (stream) => RTCVideoView(
                            stream.renderer!,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          ),
                        )
                        .toList(),
                  ),
            // Live Stream Control Buttons
            Positioned(
              bottom: 2,
              left: 2,
              right: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Media Control Buttons
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(micEnabled ? Icons.mic : Icons.mic_off),
                          onPressed: onMicButtonPressed,
                        ),
                        IconButton(
                          icon: Icon(webcamEnabled
                              ? Icons.videocam
                              : Icons.videocam_off),
                          onPressed: onWebcamButtonPressed,
                        ),
                        IconButton(
                          icon: const Icon(Icons.cameraswitch),
                          onPressed: onChangeWebcamButtonPressed,
                        ),
                      ],
                    ),
                    // Stream Control Buttons
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : isStreamingStarted
                                  ? stopHls
                                  : startHls,
                          child: Text(
                            "${isStreamingStarted ? "Stop" : "Start"} LiveStreaming",
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isBusy ? null : leaveLiveStreaming,
                          child: const Text(
                            "Leave",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // Set stream event listeners for participant
  void setStreamEvents(Participant participant) {
    participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == "video") {
        setState(() => videoStreams[participant.id] = stream);
      }
    });

    participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == "video") {
        try {
          setState(() => videoStreams.remove(participant.id));
        } catch (e) {
          log("Stream not found");
        }
      }
    });
  }

  // Start HLS stream
  void startHls() async {
    setState(() => isBusy = true);
    final streamUrl = await ApiService.startHls(widget.meetingId);
    if (streamUrl == null) {
      setState(() => isBusy = false);
      return;
    }
    setState(() {
      isStreamingStarted = true;
      isBusy = false;
    });
  }

  // Stop HLS stream
  void stopHls() async {
    setState(() => isBusy = true);
    bool isEnded = await ApiService.stopHls(widget.meetingId);
    if (!isEnded) {
      setState(() => isBusy = false);
      return;
    }

    setState(() {
      isStreamingStarted = false;
      isBusy = false;
    });
  }

  // Called when user presses the "Mic" button
  void onMicButtonPressed() {
    setState(() {
      if (micEnabled) {
        meeting!.muteMic();
      } else {
        meeting!.unmuteMic();
      }
      micEnabled = !micEnabled;
    });
  }

  // Called when user presses the "Webcam" button
  void onWebcamButtonPressed() {
    setState(() {
      if (webcamEnabled) {
        meeting!.disableWebcam();
      } else {
        meeting!.enableWebcam();
      }
      webcamEnabled = !webcamEnabled;
    });
  }

  // Called when user presses the "Change Webcam" button
  void onChangeWebcamButtonPressed() {
    String deviceToChange = meeting!
        .getWebcams()
        .firstWhere((device) => device.deviceId != meeting!.selectedWebcamId)
        .deviceId;
    meeting!.changeWebcam(deviceToChange);
  }

  // Called when user presses the "Leave" button
  void leaveLiveStreaming() {
    meeting?.leave();
    Navigator.pop(context);
  }
}
