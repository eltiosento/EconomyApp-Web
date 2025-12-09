class NewIncomeDto {
  int userId;
  String description;
  double amount;
  DateTime incomeDate;

  NewIncomeDto({
    required this.userId,
    required this.description,
    required this.amount,
    required this.incomeDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'description': description,
      'amount': amount,
      'incomeDate':
          incomeDate
              .toIso8601String()
              .split('T')
              .first, // Format the date as 'YYYY-MM-DD'
    };
  }

  @override
  String toString() {
    return 'NewIncomeDto(userId: $userId, description: $description, amount: $amount, incomeDate: $incomeDate)';
  }
}
