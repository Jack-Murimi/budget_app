class HeaderSuggestion {
  final String header;
  final int? categoryId;
  final String? categoryName;
  final int? parentCategoryId;
  final String? parentCategoryName;

  const HeaderSuggestion({
    required this.header,
    this.categoryId,
    this.categoryName,
    this.parentCategoryId,
    this.parentCategoryName,
  });

  /// Displays category context:
  /// - If sub-category: "Parent > Sub"
  /// - If top-level: "Parent"
  /// - If no category: ""
  String get categoryDisplay {
    if (categoryName == null || categoryName!.isEmpty) return '';
    if (parentCategoryName != null && parentCategoryName!.isNotEmpty) {
      return '$parentCategoryName > $categoryName';
    }
    return categoryName!;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderSuggestion &&
          runtimeType == other.runtimeType &&
          header.toLowerCase() == other.header.toLowerCase() &&
          categoryId == other.categoryId;

  @override
  int get hashCode => header.toLowerCase().hashCode ^ (categoryId?.hashCode ?? 0);
}
