class CategoryDto {
  final int id;
  final String name;
  final String description;
  final bool isSaving;
  final int? parentCategoryId;
  final double? goal;
  final String? imageUrl;

  CategoryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.parentCategoryId,
    required this.imageUrl,
    required this.goal,
    required this.isSaving,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['icon'],
      goal: json['goal'],
      parentCategoryId: json['parentCategoryId'],
      isSaving: json['saving'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': imageUrl,
      'goal': goal,
      'parentCategoryId': parentCategoryId,
      'saving': isSaving,
    };
  }
}
