class ChangePasswordDto {
  String password1;
  String password2;

  ChangePasswordDto({required this.password1, required this.password2});

  Map<String, dynamic> toJson() {
    return {'newPassword': password1, 'newPassword2': password2};
  }
}
