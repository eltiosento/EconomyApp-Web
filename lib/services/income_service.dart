import 'package:dio/dio.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/income_dto.dart';
import 'package:economy_app/models/new_income_dto.dart';

class IncomeService {
  final Dio dio;

  IncomeService(this.dio);

  Future<List<IncomeDto>> getAllIncomesByUserId(int userId) async {
    try {
      final response = await dio.get('/incomes/user/$userId');
      List<IncomeDto> incomes =
          (response.data as List).map((json) => IncomeDto.fromJson(json)).toList();
      return incomes;
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

  Future<List<IncomeDto>> getAllIncomes() async {
    try {
      final response = await dio.get('/incomes');
      List<IncomeDto> incomes =
          (response.data as List).map((json) => IncomeDto.fromJson(json)).toList();
      return incomes;
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

  Future<IncomeDto> createIncome(NewIncomeDto newIncome) async {
    try {
      final response = await dio.post('/income', data: newIncome.toJson());
      return IncomeDto.fromJson(response.data);
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

  Future<IncomeDto> updateIncome(int incomeId, NewIncomeDto newIncome) async {
    try {
      final response = await dio.put('/income/$incomeId', data: newIncome.toJson());
      return IncomeDto.fromJson(response.data);
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

  Future<void> deleteIncome(int incomeId) async {
    try {
      await dio.delete('/income/$incomeId');
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
