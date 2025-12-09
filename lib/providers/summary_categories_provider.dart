import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/models/new_category_dto.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/services/categoty_service.dart';
import 'package:economy_app/services/summary_categories_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final summaryCategoriesServiceProvider = Provider<SummaryCategoriesService>((ref) {
  final dio = ref.watch(dioProvider);
  return SummaryCategoriesService(dio);
});

final categoriesServiceProvider = Provider<CategotyService>((ref) {
  final dio = ref.watch(dioProvider);
  return CategotyService(dio);
});

// Creem un provider per a la classe SummaryCategoriesNotifier, que és un FamilyAsyncNotifier
// que ens permetrà poder accedir als metodes de la classe i a les seves variables
// i a més a més, ens permetrà fer un CRUD de les categories.
final summaryCategoriesProvider = AsyncNotifierProvider.family<
  SummaryCategoriesNotifier,
  List<SummaryCategory>,
  (int, int)
>(SummaryCategoriesNotifier.new);

class SummaryCategoriesNotifier
    extends FamilyAsyncNotifier<List<SummaryCategory>, (int, int)> {
  late SummaryCategoriesService _summarySvc;
  late CategotyService _categorySvc;
  late int _month;
  late int _year;

  @override
  Future<List<SummaryCategory>> build((int month, int year) params) async {
    // Comprovem que l'usuari estigui autenticat
    // i que el token no sigui null
    final authResponse = ref.watch(authProvider).value;
    if (authResponse == null) return [];
    // 1) Recupera el servei
    _summarySvc = ref.watch(summaryCategoriesServiceProvider);
    // 2) El parametres són un tuple (month, year). Ens els passaran des de la UI al observar el provider.
    // Com que el provider que farà us d'aquesta clase és un familyProvider, serà aquest qui ens passi els paràmetres.
    // Els desarem a la classe per poder fer servir en el CRUD
    final (m, y) = params;
    _month = m;
    _year = y;
    // 3) Crida inicial a l'API
    return _summarySvc.getAllExpensesPerMonth(_month, _year);
  }

  Future<void> addCategory({
    required String name,
    required String description,
    String? urlImage,
    double? goal,
    required bool isSaving,
  }) async {
    _categorySvc = ref.watch(categoriesServiceProvider);

    final newCategory = NewCategoryDto(
      name: name,
      description: description,
      icon: urlImage,
      goal: goal,
      isSaving: isSaving,
    );
    state = const AsyncLoading();
    try {
      // 1) Crida a l'API
      await _categorySvc.createCategory(newCategory);

      final updatedList = await _summarySvc.getAllExpensesPerMonth(_month, _year);

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
    required bool isSaving,
  }) async {
    _categorySvc = ref.watch(categoriesServiceProvider);

    final newCategory = NewCategoryDto(
      name: name,
      description: description,
      icon: urlImage,
      goal: goal,
      isSaving: isSaving,
    );
    state = const AsyncLoading();
    try {
      // 1) Crida a l'API
      await _categorySvc.updateCategory(categoryId, newCategory);
      // 2) Torna a carregar tota la llista després del POST per actualitzar l'estat
      final updatedList = await _summarySvc.getAllExpensesPerMonth(_month, _year);
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
      final updatedList = await _summarySvc.getAllExpensesPerMonth(_month, _year);
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
