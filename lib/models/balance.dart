class Balance {
  double saldo;
  double patrimony;
  double savings;
  double income;
  double expenses;

  Balance({
    required this.saldo,
    required this.patrimony,
    required this.savings,
    required this.income,
    required this.expenses,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      saldo: json['saldo'] is int ? (json['saldo'] as int).toDouble() : json['saldo'],
      patrimony:
          json['patrimony'] is int
              ? (json['patrimony'] as int).toDouble()
              : json['patrimony'],
      savings:
          json['totalSavings'] is int
              ? (json['totalSavings'] as int).toDouble()
              : json['totalSavings'],
      income:
          json['totalIncome'] is int
              ? (json['totalIncome'] as int).toDouble()
              : json['totalIncome'],
      expenses:
          json['totalExpense'] is int
              ? (json['totalExpense'] as int).toDouble()
              : json['totalExpense'],
    );
  }
}
