import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_audio_call/main.dart';
import 'package:video_audio_call/model/user_model.dart';
import 'package:video_audio_call/service/auth_service.dart';
import 'package:video_audio_call/service/database.dart';
import 'package:video_audio_call/view/Homescreen.dart';
import 'package:video_audio_call/view/sign_up_screen.dart';

UserModel userModel = UserModel(name: '', email: '');

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.signInWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
                if (user != null) {
                  final DatabaseService databaseService = DatabaseService();
                  Stream<List<UserModel>> getUserDataStream = databaseService.getUsers();
                  getUserDataStream.listen((getUserData) {
                    for (var element in getUserData) {
                      if (element.email == _emailController.text) {
                        databaseService.updateUser(element.id ?? "", UserModel(email: _emailController.text, id: user.uid, name: element.name, token: storage.read("fcmToken")));
                        userModel = UserModel(email: _emailController.text, id: user.uid, name: element.name, token: storage.read("fcmToken"));
                        Get.to(() => HomeScreen());
                        break;
                      }
                    }
                  });

                }
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => RegisterScreen());
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
