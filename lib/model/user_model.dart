class UserModel {
  String? id;
  String name;
  String email;
  String? token;

  UserModel({this.id, required this.name, required this.email, this.token});

  // Convert a UserModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'token': token,
    };
  }

  // Extract a UserModel from a Map
  UserModel.fromMap(String id, Map<String, dynamic> map)
      : id = id,
        name = map['name'],
        email = map['email'],
        token = map['token'];
}
