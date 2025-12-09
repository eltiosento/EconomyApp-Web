class ApiError {
  final String message;
  final String? httpStatusSpring;
  final int? statusCode;

  // Constructor que accepta un missatge d'error.
  ApiError({required this.message, this.statusCode, this.httpStatusSpring});

  // Amb aquesta funció es crea un objecte ApiError a partir d'un JSON.
  // Aquesta funció és útil per a convertir la resposta d'error del servidor en un objecte ApiError.
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(message: json['message'], httpStatusSpring: json['code']);
  }
}
