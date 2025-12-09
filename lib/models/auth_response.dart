class AuthResponse {
  String token;

  // Construtor
  AuthResponse({required this.token});

  // Amb factoria es crea un objecte AuthResposne a partir d'un JSON.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(token: json['token']);
  }
}
