import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// interceptor handler vol dir manipulador de peticions i respostes (manipulador d'intercepcions)
// Els interceptors de Dio ens permeten interceptar el flux de les peticions, per exemple,
// afegir headers o gestionar errors de forma centralitzada.
class AuthInterceptor extends Interceptor {
  // onRequest: És el mètode que s'executa ABANS DE CADA PETICIÓ.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Carreguem el token d'autenticació de SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        // Afegim el token als headers
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // En cas de problema, podem ometre el header
      // També pots registrar l'error si ho consideres necessari.
    }
    // Continuem amb la petició.
    return handler.next(options);
  }
}
