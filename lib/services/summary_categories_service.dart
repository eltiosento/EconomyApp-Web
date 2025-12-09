import 'package:dio/dio.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/models/summary_category_subcategories.dart';

class SummaryCategoriesService {
  final Dio dio;

  SummaryCategoriesService(this.dio);

  Future<List<SummaryCategory>> getAllExpensesPerMonth(int mounth, int year) async {
    try {
      final response = await dio.get(
        '/summary/categories/subcategories/month/$mounth/year/$year',
      );
      List<SummaryCategory> categories =
          (response.data as List).map((json) => SummaryCategory.fromJson(json)).toList();
      return categories;
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

  Future<List<SummaryCategory>> getAllSavingsCategories() async {
    try {
      final response = await dio.get('/summary/savings/subcategories');

      List<SummaryCategory> categories =
          (response.data as List).map((json) => SummaryCategory.fromJson(json)).toList();

      return categories;
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

  Future<SummaryCategorySubcategories> getAllSubcategoriesByCategoryIdPerMounth(
    int parentCategoryId,
    int mounth,
    int year,
  ) async {
    try {
      final response = await dio.get(
        '/summary/category/$parentCategoryId/subcategories/monthly/month/$mounth/year/$year',
      );
      return SummaryCategorySubcategories.fromJson(response.data);
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
