import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:uuid/uuid.dart';
import 'package:video_audio_call/main.dart';
import 'package:video_audio_call/view/video_call_new_screen.dart';


class FirebaseNotificationService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static int item = 1;

  static initializeService() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    item = 1;
    try {
      firebaseMessaging.requestPermission(sound: true, badge: true, alert: true, provisional: true);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }


    firebaseMessaging.getToken().then((String? token) async {
      assert(token != null);
      if (kDebugMode) {
        print("FCM-TOKEN $token");
      }
      storage.write("fcmToken", token);
    });
  }

  static getNotification() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("--------notifaction ------------ ");
      String? type = message.data["type"];
      showCallkitIncoming(message);
      if (type?.isEmpty ?? true) {

      } else {
        leaveCall();
      }

      // showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("--onMessageOpenedApp------notifaction ------------ ");
      showCallkitIncoming(message);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> showCallkitIncoming(RemoteMessage message) async {
    print("-------${message.data}");
    Uuid _uuid = Uuid();
    final params = CallKitParams(
      id: _uuid.v4(),
      nameCaller: 'Hien Nguyen',
      appName: 'Callkit',
      avatar: 'https://i.pravatar.cc/100',
      handle: '0123456789',
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{'channelName':message.data["channelName"],'videoToken' : message.data["videoToken"]},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("--firebaseMessagingBackgroundHandler------notifaction ------------${message.data} ");
    if (message.data.isNotEmpty) {
      showCallkitIncoming(message);
    }
  }
}
