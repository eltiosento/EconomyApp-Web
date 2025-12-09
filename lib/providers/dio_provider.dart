import 'package:dio/dio.dart';
import 'package:economy_app/utils/auth_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.0.16:9090/api', //casa
      //baseUrl: '/api', //reverse proxy para hacer el funnel y poder usar la web desde Tailscale
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  // Afegim l'interceptor d'autenticació per a totes les peticions
  // que es qui s'ha encarregat de incloure el token d'autenticació als headers
  dio.interceptors.add(AuthInterceptor());

  return dio;
});
