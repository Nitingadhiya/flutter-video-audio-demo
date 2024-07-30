class PushNotification {
  String body;
  String title;
  String deviceToken;
  String loginUserDeviceToken;
  String routeParameterId;
  String notificationRoute;
  String? channelName;
  String? type;
  String? videoToken;
  String isAudio;
  PushNotification({
    required this.body,
    required this.title,
    required this.deviceToken,
    required this.loginUserDeviceToken,
    required this.routeParameterId,
    this.videoToken,
    this.channelName,
    this.type,
    required this.notificationRoute,
    this.isAudio = "false",
  });

  Map<String, dynamic> toMap() =>
      {
        "message": {
          'notification': <String, dynamic>{'body': body, 'title': title},
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'route': notificationRoute,
            'channelName': channelName,
            'type': type,
            'loginUserDeviceToken': loginUserDeviceToken,
            'videoToken': videoToken,
            'routeParameterId': routeParameterId,
            'isAudio': isAudio,
          },
          "token": deviceToken,
        }
      };
}
