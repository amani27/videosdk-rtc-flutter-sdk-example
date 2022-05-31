import 'dart:developer';

import 'package:dio/dio.dart';

class ApiService {
  // EndPoint
  static const String endPointUrl = "https://api.videosdk.live";

  // Auth Token
  static const String authToken = "#YOUR_AUTH_TOKEN";

  // Dio Client
  static final dio = Dio();

  // Method to get meeting id
  static Future<String?> getMeetingId() async {
    try {
      final jsonRes = await dio.post(
        "$endPointUrl/v1/meetings",
        options: Options(
          headers: {
            "Authorization": authToken,
          },
        ),
      );

      // Check response
      if (jsonRes.statusCode == 200) {
        final meetingId = jsonRes.data["meetingId"];
        return meetingId;
      } else {
        log("Failed to get meetingId: ${jsonRes.data}");
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // Method to get down stream url
  static Future<String?> getDownStreamUrl(String meetingId) async {
    try {
      final jsonRes = await dio.get(
        "$endPointUrl/v2/hls/$meetingId/active",
        options: Options(
          headers: {
            "Authorization": authToken,
          },
        ),
      );

      // Check response
      if (jsonRes.statusCode == 200) {
        final downStreamUrl = jsonRes.data["data"]!["downstreamUrl"];
        log(downStreamUrl);
        return downStreamUrl;
      } else {
        log("Failed to get downstreamUrl: ${jsonRes.data}");
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // Method to start HLS stream
  static Future<String?> startHls(String meetingId) async {
    try {
      final jsonRes = await dio.post(
        "$endPointUrl/v2/hls/start",
        data: <String, dynamic>{
          "roomId": meetingId,
          "config": <String, dynamic>{
            "layout": <String, dynamic>{
              "type": "GRID",
              "priority": "SPEAKER",
              "gridSize": 2,
            },
          },
        },
        options: Options(
          headers: {
            "Authorization": authToken,
          },
        ),
      );

      // Check response
      if (jsonRes.statusCode == 200) {
        final downstreamUrl = jsonRes.data["downstreamUrl"];
        return downstreamUrl;
      } else {
        log("Failed to get downstreamUrl: ${jsonRes.data}");
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // Method to stop HLS stream
  static Future<bool> stopHls(String meetingId) async {
    try {
      final jsonRes = await dio.post("$endPointUrl/v2/hls/end",
          options: Options(
            headers: {
              "Authorization": authToken,
            },
          ),
          data: {
            "roomId": meetingId,
          });

      // Check response
      if (jsonRes.statusCode == 200) {
        return true;
      } else {
        log("Failed to get downstreamUrl: ${jsonRes.data}");
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
