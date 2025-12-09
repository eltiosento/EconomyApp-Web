import 'package:jwt_decoder/jwt_decoder.dart';

class TokenUtils {
  /// Decodifica el token i retorna un Map amb les dades extretes.
  static Map<String, dynamic> decode(String token) {
    return JwtDecoder.decode(token);
  }

  /// Obté el rol del token, si existeix.
  static String getRole(String token) {
    final decoded = decode(token);
    // Suposant que al JWT, el camp del rol es diu "role"
    return decoded['role'] as String;
  }

  static String getEmail(String token) {
    final decoded = decode(token);
    // Suposant que al JWT, el camp del rol es diu "email"
    return decoded['email'] as String;
  }

  static String getUsername(String token) {
    final decoded = decode(token);
    // Suposant que al JWT, el camp del rol es diu "username"
    return decoded['sub'] as String;
  }

  static int getUserId(String token) {
    final decoded = decode(token);
    // Suposant que al JWT, el camp del rol es diu "userId"
    return decoded['userId'] as int;
  }

  /// Comprova si el token ha caducat.
  static bool isExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
}
