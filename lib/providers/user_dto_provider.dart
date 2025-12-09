import 'dart:io';

import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/auth_response.dart';
import 'package:economy_app/models/change_password_dto.dart';
import 'package:economy_app/models/user_dto.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/services/user_dto_service.dart';
import 'package:economy_app/utils/token_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

final userDtoServiceProvider = Provider<UserDtoService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserDtoService(dio);
});

final userProvider = AsyncNotifierProvider<UserDtoNotifier, UserDto?>(
  UserDtoNotifier.new,
);

class UserDtoNotifier extends AsyncNotifier<UserDto?> {
  // build() és com el constructor dels Notifier, i definim el seu estat inicial dins d'aquest mètode.
  @override
  Future<UserDto?> build() async {
    // Observem l'estat d'autenticació per obtenir el token.
    // El provider d'autenticació és un AsyncNotifierProvider, així que podem obtenir el seu valor amb ref.watch()
    // Per tant amb .value si es un AuthResponse, o null.
    final authState = ref.watch(authProvider);
    final AuthResponse? authResponse = authState.value;

    // Si es null, vol dir que no hi ha cap usuari loguejat, així que retornem null. authState També s'encarrega de saber si el token està caducat o no.
    if (authResponse == null) {
      return null;
    }
    // 2) Si hi ha token, extraiem l'ID
    final userId = TokenUtils.getUserId(authResponse.token);

    // Demanem el servei directament sense emmagatzemar-lo com a camp
    final service = ref.watch(userDtoServiceProvider);

    // Cridem el servei per obtenir el UserDto
    // i actualitzem l'estat del provider amb el resultat.
    // Si hi ha un error, el provider (service) es posarà en estat d'error automàticament.
    return await service.getUserById(userId);
  }
  /*
  Future<void> uploadProfileImage(File imageFile) async {
    final userLogged = state.value;
    if (userLogged == null) {
      throw ApiError(message: 'No hay usuario logueado');
    }

    state = const AsyncLoading();
    try {
      final updated = await ref
          .watch(userDtoServiceProvider)
          .uploadProfileImage(userLogged.id, imageFile);
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncError(e is ApiError ? e : ApiError(message: e.toString()), st);
      rethrow;
    }
  }
*/

  Future<void> uploadProfileImage({
    File? imageFile,
    Uint8List? bytes,
    required String fileName,
  }) async {
    final userLogged = state.value;
    if (userLogged == null) {
      throw ApiError(message: 'No hay usuario logueado');
    }

    // Validaciones según plataforma
    if (kIsWeb && bytes == null) {
      throw ApiError(message: 'Debe proporcionar bytes en Web');
    }
    if (!kIsWeb && imageFile == null) {
      throw ApiError(message: 'Debe proporcionar File en móvil');
    }

    state = const AsyncLoading();

    try {
      final updated = await ref
          .watch(userDtoServiceProvider)
          .uploadProfileImage(
            userLogged.id,
            imageFile: imageFile,
            bytes: bytes,
            fileName: fileName,
          );

      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncError(e is ApiError ? e : ApiError(message: e.toString()), st);
      rethrow;
    }
  }

  /// Actualitza les dades de l'usuari loguejat.
  Future<void> updateUser({
    required String username,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    final userLogged = state.value;
    if (userLogged == null) {
      throw ApiError(message: 'No hay usuario logueado');
    }
    final userDto = UserDto(
      id: userLogged.id,
      username: userLogged.username,
      email: email,
      firtName: firstName,
      lastName: lastName,
      role: userLogged.role,
    );

    state = const AsyncLoading();
    try {
      final updated = await ref
          .watch(userDtoServiceProvider)
          .updateUser(userLogged.id, userDto);
      state = AsyncData(updated);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }

  /// Actualitza les dades de l'usuari loguejat.
  Future<void> updateUserName({required String username}) async {
    final userLogged = state.value;
    if (userLogged == null) {
      throw ApiError(message: 'No hay usuario logueado');
    }
    final userDto = UserDto(
      id: userLogged.id,
      username: username,
      email: userLogged.email,
      firtName: userLogged.firtName,
      lastName: userLogged.lastName,
      role: userLogged.role,
    );

    state = const AsyncLoading();
    try {
      final updated = await ref
          .watch(userDtoServiceProvider)
          .updateUser(userLogged.id, userDto);
      state = AsyncData(updated);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }

  Future<void> updateUserPassword({
    required String password1,
    required String password2,
  }) async {
    final userLogged = state.value;
    if (userLogged == null) {
      throw ApiError(message: 'No hay usuario logueado');
    }
    final ChangePasswordDto changePasswordDto = ChangePasswordDto(
      password1: password2,
      password2: password2,
    );

    state = const AsyncLoading();
    try {
      await ref
          .watch(userDtoServiceProvider)
          .updatePassword(userLogged.id, changePasswordDto);
      state = const AsyncData(
        null,
      ); // Actualitzem l'estat a null per indicar que s'ha completat l'operació
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }
}
