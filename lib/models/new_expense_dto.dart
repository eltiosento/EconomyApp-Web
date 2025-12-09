class NewExpenseDto {
  int userId;
  int subcategoryId;
  String description;
  double amount;
  DateTime expenseDate;

  NewExpenseDto({
    required this.userId,
    required this.subcategoryId,
    required this.description,
    required this.amount,
    required this.expenseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'categoryId': subcategoryId,
      'description': description,
      'amount': amount,
      'expenseDate':
          expenseDate
              .toIso8601String()
              .split('T')
              .first, // Format the date as 'YYYY-MM-DD'
    };
  }

  @override
  String toString() {
    return 'NewExpenseDto(userId: $userId, subcategoryId: $subcategoryId, description: $description, amount: $amount, incomeDate: $expenseDate)';
  }
}
