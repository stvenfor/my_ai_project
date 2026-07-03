/// 全部服务页数据模型。
class AllServiceItem {
  const AllServiceItem({
    required this.label,
    required this.assetName,
    String? id,
  }) : id = id ?? assetName;

  final String id;
  final String label;
  final String assetName;

  AllServiceItem copyWith({
    String? label,
    String? assetName,
  }) {
    final nextAsset = assetName ?? this.assetName;
    return AllServiceItem(
      label: label ?? this.label,
      assetName: nextAsset,
      id: nextAsset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllServiceItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AllServiceSection {
  const AllServiceSection({
    required this.title,
    required this.items,
    this.subtitle,
    this.showEditButton = false,
  });

  final String title;
  final String? subtitle;
  final bool showEditButton;
  final List<AllServiceItem> items;
}

abstract final class AllServicesAssets {
  static const package = 'module_home';
  static const basePath = 'assets/all_services';

  static String path(String assetName) => '$basePath/$assetName';
}
