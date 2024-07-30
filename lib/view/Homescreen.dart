import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_audio_call/model/push_notification_model.dart';
import 'package:video_audio_call/model/user_model.dart';
import 'package:video_audio_call/service/database.dart';
import 'package:video_audio_call/service/events.dart';
import 'package:video_audio_call/view/FirebaseMessaging.dart';
import 'package:video_audio_call/view/login_screen.dart';
import 'package:video_audio_call/view/video_call_new_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    FirebaseNotificationService.getNotification();
    callEvent();
    getVideoCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _databaseService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index];
              if(userData.email != userModel.email){
                return ListTile(
                  onTap: () async {
                    String token = await getVideoCallToken(channelId: "${userModel.id}${userData.id}");
                    sendPopupNotification(
                        pushNotification: PushNotification(
                          title: userModel.name,
                          body: "Calling you",
                          deviceToken: userData.token ?? "",
                          videoToken: token,
                          channelName: "${userModel.id}${userData.id}",
                          loginUserDeviceToken: userModel.token ?? "",
                          notificationRoute: "call",
                          userCallingId: userModel.id ?? "",
                          routeParameterId: "${userModel.id}${userData.id}",
                        ));
                    Get.to(() => VideoCallScreen(
                      channelId: "${userModel.id}${userData.id}",
                      token: token,
                    ));
                  },
                  title: Text(userData.name),
                  subtitle: Text(userData.email),
                );
              }else{
                return SizedBox();
              }

            },
          );
        },
      ),
    );
  }
}
