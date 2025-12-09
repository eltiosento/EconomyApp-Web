class RegisterRequest {
  String username;
  String password;
  String email;
  String? firtName;
  String? lastName;
  String? profileImage;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
    this.firtName,
    this.lastName,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'firstName': firtName,
      'lastName': lastName,
      'profileImage': profileImage,
    };
  }
}
