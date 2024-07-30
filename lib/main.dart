import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_audio_call/firebase_options.dart';
import 'package:video_audio_call/model/user_model.dart';
import 'package:video_audio_call/view/FirebaseMessaging.dart';
import 'package:video_audio_call/view/Homescreen.dart';
import 'package:video_audio_call/view/login_screen.dart';

final storage = GetStorage();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseNotificationService.initializeService();
  runApp(const MyApp());
}

 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Video Call',
      onInit: (){
        if(storage.read("user") != null){
          userModel = UserModel.fromMap(storage.read("user"));
        }

      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: storage.read("user") != null ?  HomeScreen() :  SignInScreen(),
    );
  }
}

