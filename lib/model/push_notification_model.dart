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
  String userCallingId;
  bool isThatGroupChat;
  PushNotification({
    required this.body,
    required this.title,
    required this.deviceToken,
    required this.loginUserDeviceToken,
    this.userCallingId = '',
    required this.routeParameterId,
    this.videoToken,
    this.channelName,
    this.type,
    required this.notificationRoute,
    this.isThatGroupChat = false,
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
            'userCallingId': userCallingId,
          },
          "token": deviceToken,
        }
      };
}
