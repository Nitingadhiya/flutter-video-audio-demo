import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:video_audio_call/main.dart';
import 'package:video_audio_call/model/push_notification_model.dart';
import 'package:video_audio_call/service/config.dart';
import 'package:video_audio_call/view/video_call_new_screen.dart';
import 'package:http/http.dart' as http;

callEvent() {
  FlutterCallkitIncoming.activeCalls();
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    print("---vvvvvvvvvvvvvvvvv--${event!.event}");
    switch (event.event) {
      case Event.actionCallIncoming:
        // TODO: received an incoming call
        break;
      case Event.actionCallStart:
        // TODO: started an outgoing call
        // TODO: show screen calling in Flutter
        break;
      case Event.actionCallAccept:
        print("00------------${event.body["extra"]["channelName"]}");
        print("00------------${event.body["extra"]["videoToken"]}");
        print("00------------${event.body["extra"]["isAudio"]}");
        Future.delayed(Duration(seconds: 1), () {
          try {
            Get.to(() => VideoCallScreen(
                  channelId: event.body["extra"]["channelName"],
                  token: event.body["extra"]["videoToken"],
                  isAudio: event.body["extra"]["isAudio"],
                ));
            // Navigator.push(
            //   Get.context!,
            //   MaterialPageRoute(
            //       builder: (context) => VideoCallScreen(
            //         channelId: event.body["extra"]["channelName"],
            //         token: event.body["extra"]["videoToken"],
            //       )),
            // );
          } catch (e) {
            print("--------error-----${e}");
          }
        });
        await storage.write("channelName", event.body["extra"]["channelName"]);
        await storage.write("videoToken", event.body["extra"]["videoToken"]);
        await storage.write("isAudio", event.body["extra"]["isAudio"]);

        // await Go(context).push(
        //     page: VideoCallScreen(
        //       channelId: event.body["extra"]["channelName"],
        //       token: event.body["extra"]["videoToken"],
        //     ));
        break;
      case Event.actionCallDecline:
        sendPopupNotification(
            pushNotification:
                PushNotification(body: '', title: '', deviceToken: event.body["extra"]["sendUserToken"], loginUserDeviceToken: '', routeParameterId: '', notificationRoute: '', type: "decline"));
        // leaveCall(event.body["extra"]["videoToken"],event.body["extra"]["channelName"]);
        break;
      case Event.actionCallEnded:
        sendPopupNotification(
            pushNotification:
                PushNotification(body: '', title: '', deviceToken: event.body["extra"]["sendUserToken"], loginUserDeviceToken: '', routeParameterId: '', notificationRoute: '', type: "CallEnded"));
        break;
      case Event.actionCallTimeout:
        sendPopupNotification(
            pushNotification: PushNotification(
                body: '', title: '', deviceToken: event.body["extra"]["sendUserToken"], loginUserDeviceToken: '', routeParameterId: '', notificationRoute: '', type: "actionCallTimeout"));
        // TODO: missed an incoming call
        break;
      case Event.actionCallCallback:
        print("---------->>>>>${event}");
        break;
      case Event.actionCallToggleHold:
        // TODO: only iOS
        break;
      case Event.actionCallToggleMute:
        // TODO: only iOS
        break;
      case Event.actionCallToggleDmtf:
        // TODO: only iOS
        break;
      case Event.actionCallToggleGroup:
        // TODO: only iOS
        break;
      case Event.actionCallToggleAudioSession:
        // TODO: only iOS
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
        // TODO: only iOS
        break;
      case Event.actionCallCustom:
        // TODO: for custom action
        break;
    }
  });
}

Future<void> sendPopupNotification({required PushNotification pushNotification}) async {
  try {
    try {
  var data =    await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/video-audio-call-faf0f/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer $notificationAccessToken",
        },
        body: jsonEncode(pushNotification.toMap()),
      );
  if(data.statusCode != 200){
    print("----${data.body}");
  }
    } catch (e, s) {
      if (kDebugMode) print(s);
    }
  } catch (e) {
    return Future.error("Error with push notification");
  }
}

getVideoCall()  {
  String? channelName = storage.read("channelName");
  String? videoToken = storage.read("videoToken");
  String? isAudio = storage.read("isAudio");
  if (channelName != null && videoToken != null) {
    Get.to(() => VideoCallScreen(
          channelId: channelName,
          token: videoToken,
          isAudio: isAudio ?? "false",
        ));
  }
}

Future<String> getVideoCallToken({required String channelId}) async {
  try {
    try {
      http.Response response = await http.post(
        Uri.parse('https://agora-token-generator-demo.vercel.app/api/main?type=rtc'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"appId": videoAppId, "certificate": certificateId, "channel": channelId, "uid": "", "role": "publisher", "expire": 0}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["rtcToken"];
      }
      return "";
    } catch (e, s) {
      if (kDebugMode) print(s);
      return "";
    }
  } catch (e) {
    return Future.error("Error with push notification");
  }
}
