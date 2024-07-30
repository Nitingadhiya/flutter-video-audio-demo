class UserModel {
  String? id;
  String? uid;
  String name;
  String email;
  String? token;

  UserModel({this.id, required this.name, required this.email, this.token, this.uid});

  // Convert a UserModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'uid': uid,
    };
  }

  // Extract a UserModel from a Map
  UserModel.fromMap(Map<String, dynamic> map)
      : id =  map['id'],
        name = map['name'],
        email = map['email'],
        token = map['token'],
        uid = map['uid'];
}
