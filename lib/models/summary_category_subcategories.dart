import 'package:economy_app/models/category_summary.dart';

class SummaryCategorySubcategories {
  int id;
  String categoryName;
  double totalExpenses;
  double monthlyExpense;
  double yearlyExpense;
  String iconPath;
  String description;
  List<SummaryCategory> subcategories;

  SummaryCategorySubcategories({
    required this.id,
    required this.categoryName,
    required this.totalExpenses,
    required this.monthlyExpense,
    required this.yearlyExpense,
    required this.iconPath,
    required this.description,
    required this.subcategories,
  });

  factory SummaryCategorySubcategories.fromJson(Map<String, dynamic> json) {
    return SummaryCategorySubcategories(
      id: json['categoryId'],
      categoryName: json['categoryName'],
      totalExpenses:
          (json['totalExpense'] is int)
              ? (json['totalExpense'] as int).toDouble()
              : json['totalExpense'],
      monthlyExpense:
          (json['monthlyExpense'] is int)
              ? (json['monthlyExpense'] as int).toDouble()
              : json['monthlyExpense'],
      yearlyExpense:
          (json['yearlyExpense'] is int)
              ? (json['yearlyExpense'] as int).toDouble()
              : json['yearlyExpense'],
      iconPath: json['icon'] ?? 'assets/icons/default.png',
      description: json['description'],
      subcategories:
          (json['subcategories'] as List<dynamic>? ?? [])
              .map((subcategory) => SummaryCategory.fromJson(subcategory))
              .toList(),
    );
  }

  @override
  String toString() {
    return 'SummaryCategorySubcategories{id: $id, categoryName: $categoryName, totalExpenses: $totalExpenses, iconPath: $iconPath, description: $description, subcategories: $subcategories}';
  }
}
