import 'dart:io';

import 'package:dio/dio.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/change_password_dto.dart';
import 'package:economy_app/models/user_dto.dart';
import 'package:path/path.dart';

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class UserDtoService {
  final Dio dio;

  // Constructor
  UserDtoService(this.dio);

  Future<UserDto> getUserById(int id) async {
    try {
      final response = await dio.get('/user/$id');
      final user = UserDto.fromJson(response.data);

      // si no passa per ací tenim un error amb el model, comprova que tot estaga ben mapejat
      //debugPrint('UserDtoService: User loaded: $user');
      return user;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(message: 'El servidor no responde. Intentalo más tarde.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiError(message: '${e.message}');
      } else if (e.response != null && e.response?.data != null) {
        final springError = ApiError.fromJson(e.response!.data);
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          throw ApiError(message: 'El usuario no existe.');
        } else if (statusCode == 403) {
          throw ApiError(message: 'No tienes permiso para acceder a este recurso.');
        } else {
          throw ApiError(message: springError.message);
        }
      } else {
        throw ApiError(message: 'Error desconocido. Intentalo más tarde.');
      }
    }
  }

  Future<UserDto> updateUser(int userId, UserDto user) async {
    try {
      final response = await dio.put('/user/$userId', data: user.toJson());
      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final springError = ApiError.fromJson(e.response!.data);
        throw ApiError(message: springError.message);
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(
          message: 'No se puede conectar con el servidor. Inténtalo más tarde.',
        );
      } else {
        throw ApiError(message: 'Error desconocido.');
      }
    }
  }
  /*
  Future<UserDto> uploadProfileImage(int userId, File imageFile) async {
    try {
      final fileName = basename(imageFile.path);
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await dio.post('/media/upload-profile/user/$userId', data: form);

      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      // Repetir lògica d'errors que ja tens al getUserById()
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(message: 'El servidor no responde. Intentalo más tarde.');
      } else if (e.response != null && e.response?.data != null) {
        final springError = ApiError.fromJson(e.response!.data);
        throw ApiError(message: springError.message);
      } else {
        throw ApiError(message: 'Error desconocido. Inténtalo más tarde.');
      }
    }
  }
*/

  Future<UserDto> uploadProfileImage(
    int userId, {
    File? imageFile,
    Uint8List? bytes,
    required String fileName,
  }) async {
    try {
      MultipartFile multipart;

      if (kIsWeb) {
        // 🔥 WEB → usamos bytes (no hay File)
        multipart = MultipartFile.fromBytes(bytes!, filename: fileName);
      } else {
        // 🔥 MOVIL → usamos File
        multipart = await MultipartFile.fromFile(
          imageFile!.path,
          filename: basename(imageFile.path),
        );
      }

      final form = FormData.fromMap({'file': multipart});

      final response = await dio.post('/media/upload-profile/user/$userId', data: form);

      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      // ⬇️ Mantengo EXACTAMENTE tu gestión de errores
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(message: 'El servidor no responde. Intentalo más tarde.');
      } else if (e.response != null && e.response?.data != null) {
        final springError = ApiError.fromJson(e.response!.data);
        throw ApiError(message: springError.message);
      } else {
        throw ApiError(message: 'Error desconocido. Inténtalo más tarde.');
      }
    }
  }

  Future<void> updatePassword(int userId, ChangePasswordDto changePasword) async {
    try {
      final response = await dio.put(
        '/user/$userId/password',
        data: {
          'newPassword': changePasword.password1,
          'newPassword2': changePasword.password2,
        },
      );

      if (response.statusCode != 200) {
        throw ApiError(message: 'Error al actualizar la contraseña.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final springError = ApiError.fromJson(e.response!.data);
        throw ApiError(message: springError.message);
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(
          message: 'No se puede conectar con el servidor. Inténtalo más tarde.',
        );
      } else {
        throw ApiError(message: 'Error desconocido.');
      }
    }
  }
}
