class ExpenseDto {
  int id;
  int userId;
  String userName;
  int categoryId;
  String categoryName;
  String description;
  double amount;
  DateTime expenseDate;
  DateTime createdAt;
  DateTime updatedAt;

  ExpenseDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.amount,
    required this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> json) {
    return ExpenseDto(
      id: json['id'],
      userId: json['userId'],
      userName: json['userUsername'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      description: json['description'],
      amount: json['amount'] is int ? (json['amount'] as int).toDouble() : json['amount'],
      expenseDate: DateTime.parse(json['expenseDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get formattedDate {
    return '${expenseDate.day}/${expenseDate.month}/${expenseDate.year}';
  }

  String get formattedCreatedAt {
    return '${createdAt.day}-${createdAt.month}-${createdAt.year} a las ${createdAt.hour}:${createdAt.minute}:${createdAt.second}';
  }

  String get formattedUpdatedAt {
    return '${updatedAt.day}-${updatedAt.month}-${updatedAt.year} a las ${updatedAt.hour}:${updatedAt.minute}:${updatedAt.second}';
  }
}
