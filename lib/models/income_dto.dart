class IncomeDto {
  int id;
  int userId;
  String userName;
  String description;
  double amount;
  DateTime incomeDate;
  DateTime createdAt;
  DateTime updatedAt;

  IncomeDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.description,
    required this.amount,
    required this.incomeDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeDto.fromJson(Map<String, dynamic> json) {
    return IncomeDto(
      id: json['id'],
      userId: json['userId'],
      userName: json['userUsername'],
      description: json['description'],
      amount: json['amount'] is int ? (json['amount'] as int).toDouble() : json['amount'],
      incomeDate: DateTime.parse(json['incomeDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get formattedDate {
    return '${incomeDate.day}/${incomeDate.month}/${incomeDate.year}';
  }

  String get formattedCreatedAt {
    return '${createdAt.day}-${createdAt.month}-${createdAt.year} a las ${createdAt.hour}:${createdAt.minute}:${createdAt.second}';
  }

  String get formattedUpdatedAt {
    return '${updatedAt.day}-${updatedAt.month}-${updatedAt.year} a las ${updatedAt.hour}:${updatedAt.minute}:${updatedAt.second}';
  }
}
