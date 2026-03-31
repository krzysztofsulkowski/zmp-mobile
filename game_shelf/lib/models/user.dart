class User {
  final String id;
  final String userName;
  final String email;
  final String role;
  final bool? isLocked;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    this.isLocked,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      role: json['role'],
      isLocked: json['isLocked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'role': role,
      'isLocked': isLocked,
    };
  }
}
