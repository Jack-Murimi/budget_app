class Category {
  final int id;
  final String name;
  final String icon;
  final String colorHex;
  final int? parentId;
  final bool isDefault;
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    this.parentId,
    this.isDefault = false,
    this.isArchived = false,
    this.sortOrder = 0,
    required this.createdAt,
  });
}
