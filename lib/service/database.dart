import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_audio_call/main.dart';

import 'package:video_audio_call/model/user_model.dart';
import 'package:video_audio_call/view/login_screen.dart';

class DatabaseService {
  final CollectionReference fireStore = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(UserModel user) async {
    await fireStore.add(user.toMap()).then((value) {
      user.id = value.id;
      if (user.id != null) {
        updateUser(user.id ?? "", user);
        userModel = UserModel(email: user.email, id: user.id, name: user.name, token: storage.read("fcmToken"));
      }
    });
  }

  Future<void> updateUser(String id, UserModel user) async {
    await fireStore.doc(id).update(user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await fireStore.doc(id).delete();
  }

  Stream<List<UserModel>> getUsers() {
    return fireStore.snapshots().map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
