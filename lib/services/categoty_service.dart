import 'package:dio/dio.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/category_dto.dart';
import 'package:economy_app/models/new_category_dto.dart';

class CategotyService {
  final Dio dio;
  CategotyService(this.dio);

  Future<List<CategoryDto>> getAllCategories() async {
    try {
      final response = await dio.get('/categories');
      List<CategoryDto> categories =
          (response.data as List).map((json) => CategoryDto.fromJson(json)).toList();
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

  Future<List<CategoryDto>> getAllSavingCategories() async {
    try {
      final response = await dio.get('/saving_categories');
      List<CategoryDto> categories =
          (response.data as List).map((json) => CategoryDto.fromJson(json)).toList();
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

  Future<CategoryDto> createCategory(NewCategoryDto newCategory) async {
    try {
      final response = await dio.post('/category', data: newCategory.toJson());
      return CategoryDto.fromJson(response.data);
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

  Future<CategoryDto> updateCategory(int categoryId, NewCategoryDto newCategory) async {
    try {
      final response = await dio.put('/category/$categoryId', data: newCategory.toJson());
      return CategoryDto.fromJson(response.data);
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

  Future<void> deleteCategory(int categoryId) async {
    try {
      await dio.delete('/category/$categoryId');
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
