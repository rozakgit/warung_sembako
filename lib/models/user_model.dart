class UserModel {
  final String uid;
  final String name;
  final String username; // Tambahan baru
  final String phone;    // Tambahan baru
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.phone,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'cashier',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }
}