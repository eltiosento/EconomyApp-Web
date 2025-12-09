import 'package:dio/dio.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/balance.dart';

class BalanceService {
  final Dio dio;

  BalanceService(this.dio);

  Future<Balance> getSummaryGlobalBalance() async {
    try {
      final response = await dio.get('/summary/balance/global');
      final balance = Balance.fromJson(response.data);
      return balance;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(message: 'El servidor no responde. Intentalo más tarde.');
      } else if (e.response != null && e.response?.data != null) {
        final springError = ApiError.fromJson(e.response!.data);
        throw ApiError(message: springError.message);
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiError(message: '${e.message}');
      } else {
        throw ApiError(message: 'Error desconocido. Intentalo más tarde.');
      }
    }
  }

  Future<Balance> getSummaryMonthlyBalance(int month, int year) async {
    try {
      final response = await dio.get('/summary/balance/monthly/month/$month/year/$year');
      final balance = Balance.fromJson(response.data);
      return balance;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiError(message: 'El servidor no responde. Intentalo más tarde.');
      } else if (e.response != null && e.response?.data != null) {
        final springError = ApiError.fromJson(e.response!.data);
        throw ApiError(message: springError.message);
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiError(message: '${e.message}');
      } else {
        throw ApiError(message: 'Error desconocido. Intentalo más tarde.');
      }
    }
  }
}
