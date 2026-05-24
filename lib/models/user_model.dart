class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}