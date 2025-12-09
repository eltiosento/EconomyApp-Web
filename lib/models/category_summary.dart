class SummaryCategory {
  int id;
  String categoryName;
  double totalExpenses;
  double monthlyExpense;
  double yearlyExpense;
  String iconPath;
  double? goal;
  String description;
  bool isSaving;
  double goalTotalProgress;
  double goalMonthlyProgress;
  double goalYearlyProgress;

  SummaryCategory({
    required this.id,
    required this.categoryName,
    required this.totalExpenses,
    required this.monthlyExpense,
    required this.yearlyExpense,
    required this.iconPath,
    required this.description,
    required this.isSaving,
    required this.goal,
    required this.goalTotalProgress,
    required this.goalMonthlyProgress,
    required this.goalYearlyProgress,
  });

  factory SummaryCategory.fromJson(Map<String, dynamic> json) {
    return SummaryCategory(
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
      goal: (json['goal'] is int) ? (json['goal'] as int).toDouble() : json['goal'],
      goalTotalProgress:
          (json['goalTotalProgress'] is int)
              ? (json['goalTotalProgress'] as int).toDouble()
              : json['goalTotalProgress'],
      goalMonthlyProgress:
          (json['goalMonthlyProgress'] is int)
              ? (json['goalMonthlyProgress'] as int).toDouble()
              : json['goalMonthlyProgress'],
      goalYearlyProgress:
          (json['goalYearlyProgress'] is int)
              ? (json['goalYearlyProgress'] as int).toDouble()
              : json['goalYearlyProgress'],
      isSaving: json['saving'] ?? false,
    );
  }
}
