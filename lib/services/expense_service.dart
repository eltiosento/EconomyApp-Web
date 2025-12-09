import 'package:dio/dio.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/expense_dto.dart';
import 'package:economy_app/models/new_expense_dto.dart';
import 'package:economy_app/models/transfer_request_dto.dart';

class ExpenseService {
  final Dio dio;
  ExpenseService(this.dio);

  Future<List<ExpenseDto>> getAllExpensesBySubcategoryIdMontYear(
    int catId,
    int month,
    int year,
  ) async {
    try {
      final response = await dio.get(
        '/expenses/subcategory/$catId/month/$month/year/$year',
      );
      List<ExpenseDto> expenses =
          (response.data as List).map((json) => ExpenseDto.fromJson(json)).toList();
      return expenses;
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

  Future<void> transferSavingsToExpenses(TransferRequestDto transferRequest) async {
    try {
      await dio.post('/transfer/savings_to_expenses', data: transferRequest.toJson());
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

  Future<ExpenseDto> createExpense(NewExpenseDto newExpense) async {
    try {
      final response = await dio.post('/expense', data: newExpense.toJson());
      return ExpenseDto.fromJson(response.data);
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

  Future<ExpenseDto> updateExpense(int expenseId, NewExpenseDto newExpense) async {
    try {
      final response = await dio.put('/expense/$expenseId', data: newExpense.toJson());
      return ExpenseDto.fromJson(response.data);
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

  Future<void> deleteExpense(int expenseId) async {
    try {
      await dio.delete('/expense/$expenseId');
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
