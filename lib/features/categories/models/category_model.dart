class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final String colorHex;
  final int? parentId;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    this.parentId,
    this.isDefault = false,
    required this.createdAt,
  });
}
