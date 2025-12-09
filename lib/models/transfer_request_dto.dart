class TransferRequestDto {
  int userId;
  int fromCategoryId;
  int toCategoryId;
  String description;
  double amount;
  DateTime date;

  TransferRequestDto({
    required this.userId,
    required this.fromCategoryId,
    required this.toCategoryId,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fromCategoryId': fromCategoryId,
      'toCategoryId': toCategoryId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String().split('T').first, // Format the date as 'YYYY-MM-DD'
    };
  }
}
