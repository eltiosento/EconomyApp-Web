import 'dart:typed_data';

import 'package:dio/dio.dart';

class GenerateReportService {
  final Dio dio;
  GenerateReportService(this.dio);

  Future<Uint8List> generateReport({required int month, required int year}) async {
    try {
      final response = await dio.get<List<int>>(
        '/report/summary/month/$month/year/$year',
        options: Options(
          responseType: ResponseType.bytes, // Para recibir el reporte como bytes
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        // response.data vindrà com List<int>, convertim a Uint8List
        return Uint8List.fromList(response.data!);
      } else {
        throw Exception('Error al generar el reporte: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('El servidor no responde. Inténtalo más tarde.');
      } else if (e.response != null && e.response?.data != null) {
        throw Exception('Error del servidor: ${e.response!.data}');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Error de conexión: ${e.message}');
      } else {
        throw Exception('Error desconocido. Inténtalo más tarde.');
      }
    }
  }
}
