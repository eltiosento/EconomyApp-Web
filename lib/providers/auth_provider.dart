import 'dart:async';

import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/auth_response.dart';
import 'package:economy_app/models/login_request.dart';
import 'package:economy_app/models/register_request.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/services/auth_service.dart';
import 'package:economy_app/utils/token_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Creem un proveedor de tipus Provider per gestionar el servei d'autenticació.
// Provider es un tipus de proveedor que es ideal per accedir a dependencies que no canvien com un servei o una classe utilitària.
// Això ens permetrà gestionar l'estat de l'autenticació a la nostra aplicació de manera eficient.
// Com que AuthService depèn de Dio, també hem de proporcionar-lo ací.
final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

// Creem un proveïdor d'estat per gestionar l'autenticació de l'usuari.
// AsyncNotifierProvider és un tipus de proveïdor que ens permet gestionar l'estat asíncronament.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthResponse?>(AuthNotifier.new);

// Creem una clase encarregada de gestionar l'estat de l'autenticació.
// i li diem que ha de gestionar un AuthResponse? (que pot ser null o un objecte AuthResponse).
class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  // Necessitem un objete AuthService com a resposta de les paticions a la API.
  // Aquest objecte no l'obtindrem fins que no ens suscrivim al proveïdor d'authServiceProvider.
  // per això el marquem com a late. Ja que és el tipus de resposta que ens dona el servici d'autenticació, el AuthService.
  late final AuthService _authService;

  // build() és com el constructor dels Notifier, i definim el seu estat inicial dins d'aquest mètode.
  // build() s'executa una vegada quan el provider s’inicialitza, i serveix per inicialitzar l'estat o configurar coses com dependències, tokens, etc.
  // En aquest cas, el mètode build() s'utilitza per inicialitzar el servei d'autenticació.
  // Quan el provider es crea, el mètode build() s'executa automàticament i inicialitza el servei d'autenticació.(_authService).
  @override
  Future<AuthResponse?> build() async {
    // Ens suscrivim al servei d'autenticació, amb el watch() per observar els canvis.
    _authService = ref.watch(authServiceProvider);

    // Carreguem el token de SharedPreferences.
    final token = await _loadToken();
    if (token != null) {
      if (TokenUtils.isExpired(token)) {
        // Si el token ha caducat, eliminem-lo de SharedPreferences i retornem null.
        await logout();
        return null;
      }
      // Si el token no és null i no ha caducat, retornem un AuthResponse amb el token.
      return AuthResponse(token: token);
    }
    // Retorna null si no hi ha token, en el cas de que no hi haja cap usuari loguejat.
    return null;
  }

  // Mètode per a realitzar la petició de login.
  // No retorna res, ja que l'estat es gestiona amb el provider.
  // Recorda: aquest provider és de tipus AsyncNotifier<AuthResponse?>, així que pot tenir com a estat:
  // AsyncLoading → quan s’està processant el login
  // AsyncData(AuthResponse) → quan ha anat bé
  // AsyncData(null) → quan no hi ha cap usuari loguejat
  // AsyncError → si ha fallat
  Future<void> login(LoginRequest request) async {
    state = const AsyncLoading();
    try {
      // Realitzem la petició de login al servei d'autenticació.
      // Fem us del proveedor per accedir als seus mètodes. Com que es de la classe Provider podem accedir directament a la seva instància.
      // Guardem la resposta en una variable authResponse.
      final AuthResponse authResponse = await _authService.login(request);

      // Guarda el token a SharedPreferences
      await _saveToken(authResponse.token);

      // Li xutem al estat el valor de la resposta d'autenticació.
      state = AsyncData(authResponse);
      // En cas d'errors:
    } catch (e, st) {
      if (e is ApiError) {
        // Si l'error (e) és un ApiError, al estat li xutem un AsyncError amb el missatge d'error (ApiError.message) que serà el (e) i l'stack trace (st).
        state = AsyncError(e, st);
      } else {
        // Si no és un ApiError, el convertim en un AsyncError genèric
        state = AsyncError(ApiError(message: 'Error desconocido.'), st);
      }
    }
  }

  Future<void> register(RegisterRequest registeRequest) async {
    state = const AsyncLoading();
    try {
      // Realitzem la petició de registre al servei d'autenticació.
      final AuthResponse authResponse = await _authService.register(registeRequest);

      // Guarda el token a SharedPreferences
      await _saveToken(authResponse.token);

      // Li xutem al estat el valor de la resposta d'autenticació.
      state = AsyncData(authResponse);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
      } else {
        state = AsyncError(ApiError(message: 'Error desconocido.'), st);
      }
    }
  }

  Future<void> logout() async {
    await _clearToken();
    state = const AsyncData(null);
  }

  // Mètodedes per gestionar el token amb SharedPreferences:
  // SharePreferences és una manera de guardar dades petites a l'emmagatzematge local del dispositiu.
  // En aquest cas, s'utilitza per guardar el token d'autenticació de l'usuari.
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Mètode per a iniciar sessió
}
