// FutureProvider que carga la lista de categorías de ahorro
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
final savingCategoriesProvider = FutureProvider<List<CategoryDto>>((ref) {
  return ref.watch(categoriesServiceProvider).getAllSavingCategories();
});
*/
final savingCategoriesProvider = FutureProvider<List<SummaryCategory>>((ref) {
  return ref.watch(summaryCategoriesServiceProvider).getAllSavingsCategories();
});
