class UserDto {
  int id;
  String username;
  String email;
  String role;
  String? firtName;
  String? lastName;
  String? profileImage;

  // Constructor
  UserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.firtName,
    this.lastName,
    this.profileImage,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['roleName'],
      firtName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'firstName': firtName,
      'lastName': lastName,
      'profileImage': profileImage,
    };
  }

  @override
  String toString() {
    return 'UserDto{id: $id, username: $username, email: $email, role: $role, firstName: $firtName, lastName: $lastName, profileImage: $profileImage}';
  }
}
