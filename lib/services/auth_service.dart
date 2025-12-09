import 'package:dio/dio.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/auth_response.dart';
import 'package:economy_app/models/login_request.dart';
import 'package:economy_app/models/register_request.dart';
import 'package:flutter/rendering.dart';

class AuthService {
  final Dio dio;

  // Cpnstructor
  AuthService(this.dio);

  // Mètode per a iniciar sessió

  Future<AuthResponse> login(LoginRequest loginRequest) async {
    try {
      final response = await dio.post('/auth/login', data: loginRequest.toJson());

      final statusCode = response.statusCode;
      debugPrint('Código HTTP de la respuesta: $statusCode');
      // Si tot va bé, retornem la resposta de l'API convertida a un objecte AuthResposne.
      return AuthResponse.fromJson(response.data);

      // Si hi ha un error, el capturarem i llançarem un missatge d'error adequat.
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(message: 'El servidor no responde. Intentalo más tarde.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiError(message: 'Error de conexión. Verifica tu conexión a Internet.');
      } else if (e.response != null && e.response?.data != null) {
        // Es quan la api ens torna un tipus d'error, com puga ser de validació o de credencials.

        // Fem us del constructor de Apierror amb el mètode fromJson per a convertir la resposta d'error en un objecte ApiError
        final springError = ApiError.fromJson(e.response!.data);

        // Extraem el codi d'estat de la resposta per a poder gestionar errors
        // En aquest cas la nostra API sols ens tornarà un 400 per a Bad Credentials
        final statusCode = e.response?.statusCode;

        debugPrint(
          "Error desde la API amb el missatge: ${springError.message} i el httpStatus ${springError.httpStatusSpring} amb el codi destat: $statusCode",
        );
        // Finalment llancem l'error amb el missatge de credencials incorretes ja que en aqueest cas sols tenim un tipus d'error.
        throw ApiError(
          message: 'Credenciales incorrectas. Verifica tu usuario y contraseña.',
        );
      } else {
        throw ApiError(message: 'Error desconocido. Intentalo más tarde.');
      }
    }
  }

  Future<AuthResponse> register(RegisterRequest registerRequest) async {
    try {
      final response = await dio.post('/auth/register', data: registerRequest.toJson());
      // Si tot va bé, retornem la resposta de l'API convertida a un objecte AuthResposne.
      return AuthResponse.fromJson(response.data);

      // Si hi ha un error, el capturarem i llançarem un missatge d'error adequat.
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(message: 'El servidor no responde. Intentalo más tarde.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiError(message: 'Error de conexión. Verifica tu conexión a Internet.');
      } else if (e.response != null && e.response?.data != null) {
        // Fem us del constructor de Apierror amb el mètode fromJson per a convertir la resposta d'error en un objecte ApiError
        final springError = ApiError.fromJson(e.response!.data);

        if (springError.message.contains('username')) {
          throw ApiError(message: 'El nombre de usuario ya existe.');
        } else if (springError.message.contains('email')) {
          throw ApiError(message: 'El correo electrónico ya está en uso.');
        } else {
          throw ApiError(message: springError.message);
        }
      } else {
        throw ApiError(message: 'Error desconocido. Intentalo más tarde.');
      }
    }
  }
}
