class User {
  String name;
  String password;

  User({required this.name, required this.password });

  User.fromMap(Map<String, dynamic> map): name = map["name"], password = map["password"];

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "password": password,
    };
  }
}