class NewCategoryDto {
  String name;
  String description;
  String? icon;
  double? goal;
  int? parentCategoryId;
  bool isSaving;

  NewCategoryDto({
    required this.name,
    required this.description,
    this.icon,
    this.goal,
    this.parentCategoryId,
    this.isSaving = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'goal': goal,
      'parentCategoryId': parentCategoryId,
      'saving': isSaving,
    };
  }
}
