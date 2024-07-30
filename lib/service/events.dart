import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:video_audio_call/main.dart';
import 'package:video_audio_call/model/push_notification_model.dart';
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
        Future.delayed(Duration(seconds: 1), () {
          try {
            Get.to(() => VideoCallScreen(
                  channelId: event.body["extra"]["channelName"],
                  token: event.body["extra"]["videoToken"],
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

          /// conect with cloud messaging and get server key from project settings here
          /// replace the points with your key  "key=...." and set it in [notificationKey]
          'Authorization': "Bearer ya29.c.c0ASRK0Gbp2r8B-ttUnV88F44jFd99rfw8s68eJ71hwDp1Jjw2klZVBVeKGpP0oGYHyiJUNQeiKNNEfMKCzf4D_IatwZjKY_j7MGGzjAKGK3QXnt-4QuB4OCeClZCKuO15DBkmT5VU0-UCBI3AzfHZ2vxQsOYmKbstj4s7uOJhtEACnAGxj7pl7CcZFeZePYLogeKo6ZLemajJDARnEZV9cjoTzYzAuJccQC5l6MDjDAo1aO32oFYuf1cvyeTHjyYzEyPtQhtBwfOaP6fFA5C0Dz_SjNDfLUtgJgm-Fe7gFQVC9rs2ABYKhUrX2tmOglz-le8iiScKfWHpW6o_M3qfst_JPxl25TpVwWLA698srY0NrZaaiOBhWLVxG385K_oyQwf_21idxgX1UR7-nQI6Ql3S_cOJXQcZnb-dJMz3V2Jktbw3sJV0O9a1iw7FQytbFaSBIhBMuM-4VFRlxyaprtYIoBzFmw4tFbVsjjduUdo1MgFhz0csqOOiu8x66t0X46ny6MZk7lQaWj5rfXgxZcRXk82Mno6OBszU4w9SbvqiROxzfrhZg8V54OjcgclxQUZ334VQg0V4nYYvy1IyMQyjYrMyj2y7WM-fU4Jvfc-zjkr5mg1i0r5ef37fXp1iJ1VbfWod5iwusx-BkO8h_r2W0bxZQtnbr1vwxauykFzjue1uzskZnu6B8j0Or-YjxyhuxiZasZ1wj6Y11hUyJJnxZ-vtUdB_fXsq1Q1JbdsUsazjSZv-Uw1bVRwMR7QMz9lpeojIrdRSkO6gfqQ8iQ4wVbitMh7fFb9gcoimc0S9Zh8_mjvld4S5yyyu-guU4s-w4SgQO-k8aOl9lJvvQSB_-irkhuO37w95F4dpqXdpudcRfJSasnYjUMbah3v4_lkot385_61smd14bF9fsXe199Xxt_J8zlx8RQ2xI-q7nJIFXORgcgV7S7mpOohfipY6aX23Ik7buYqQ3kSw13l7mbY4wnyrmu7w4ryXnBgWSZl_Ym9B8y0",
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

getVideoCall() async {
  String? channelName = storage.read("channelName");
  String? videoToken = storage.read("videoToken");
  if (channelName != null && videoToken != null) {
    Get.to(() => VideoCallScreen(
          channelId: channelName,
          token: videoToken,
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
