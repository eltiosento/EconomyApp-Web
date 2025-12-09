import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/new_category_dto.dart';
import 'package:economy_app/models/summary_category_subcategories.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:economy_app/services/categoty_service.dart';
import 'package:economy_app/services/summary_categories_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// El summaryCategoriesServiceProvider ja el tenim creat en el fitxer
// summary_categories_provider.dart, així que no cal crear-lo de nou.

final summaryCategorySubcategoriesProvider = AsyncNotifierProvider.family<
  SummaryCategorySubcategoriesNotifier,
  SummaryCategorySubcategories,
  (int, int, int)
>(SummaryCategorySubcategoriesNotifier.new);

class SummaryCategorySubcategoriesNotifier
    extends FamilyAsyncNotifier<SummaryCategorySubcategories, (int, int, int)> {
  late SummaryCategoriesService _summarySvc;
  late CategotyService _categorySvc;
  late int _parentCategoryId;
  late int _month;
  late int _year;

  @override
  Future<SummaryCategorySubcategories> build(
    (int parentCategoryId, int month, int year) params,
  ) async {
    // 1) Recupera el servei
    _summarySvc = ref.watch(summaryCategoriesServiceProvider);

    // 2) El parametres són un tuple (parentCategoryId, month, year). Ens els passaran des de la UI al observar el provider.
    // Com que el provider que farà us d'aquesta clase és un familyProvider, serà aquest qui ens passi els paràmetres.
    // Els desarem a la classe per poder fer servir en el CRUD
    final (parentCatId, m, y) = params;
    _parentCategoryId = parentCatId;
    _month = m;
    _year = y;

    // 3) Crida inicial a l'API
    return _summarySvc.getAllSubcategoriesByCategoryIdPerMounth(
      _parentCategoryId,
      _month,
      _year,
    );
  }

  Future<void> addCategory({
    required String name,
    required String description,
    String? urlImage,
    double? goal,
    required int parentCategoryId,
    required bool isSaving,
  }) async {
    _categorySvc = ref.watch(categoriesServiceProvider);

    final newCategory = NewCategoryDto(
      name: name,
      description: description,
      icon: urlImage,
      goal: goal,
      parentCategoryId: parentCategoryId,
      isSaving: isSaving,
    );
    state = const AsyncLoading();
    try {
      // 1) Crida a l'API
      await _categorySvc.createCategory(newCategory);

      final updatedList = await _summarySvc.getAllSubcategoriesByCategoryIdPerMounth(
        _parentCategoryId,
        _month,
        _year,
      );
      state = AsyncData(updatedList);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    String? urlImage,
    double? goal,
    required int parentCategoryId,
    required bool isSaving,
  }) async {
    _categorySvc = ref.watch(categoriesServiceProvider);

    final newCategory = NewCategoryDto(
      name: name,
      description: description,
      icon: urlImage,
      goal: goal,
      parentCategoryId: parentCategoryId,
      isSaving: isSaving,
    );
    state = const AsyncLoading();
    try {
      // 1) Crida a l'API
      await _categorySvc.updateCategory(categoryId, newCategory);
      // 2) Torna a carregar tota la llista després del POST per actualitzar l'estat
      final updatedList = await _summarySvc.getAllSubcategoriesByCategoryIdPerMounth(
        _parentCategoryId,
        _month,
        _year,
      );
      state = AsyncData(updatedList);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncLoading();
    try {
      await _categorySvc.deleteCategory(categoryId);
      final updatedList = await _summarySvc.getAllSubcategoriesByCategoryIdPerMounth(
        _parentCategoryId,
        _month,
        _year,
      );
      state = AsyncData(updatedList);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }
}
