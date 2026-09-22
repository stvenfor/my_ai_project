/// 瀑布流商品卡片（对接 Go BFF 扁平行 + 参考图展示字段）。
class MallProductCardModel {
  const MallProductCardModel({
    required this.id,
    required this.skuId,
    required this.title,
    required this.price,
    required this.coverUrl,
    required this.imageAspectRatio,
    required this.kind,
    this.subtitle,
    this.points,
    this.soldLabel,
    this.badges = const [],
  });

  factory MallProductCardModel.fromJson(Map<String, dynamic> json) {
    final productId = json['product_id'] ?? json['id'];
    final idStr = productId?.toString() ?? '';
    final aspect = (json['cover_aspect'] as num?)?.toDouble() ?? 1.0;
    final price = json['price']?.toString() ?? '0.00';
    final kind = (json['kind'] as num?)?.toInt() ?? 0;
    final points = (json['price_points'] as num?)?.toInt() ?? 0;
    final seed = idStr.hashCode.abs();

    final soldRaw = 20 + (seed % 9990);
    final soldLabel = soldRaw >= 10000
        ? '已兑${(soldRaw / 10000).toStringAsFixed(1)}万'
        : '已兑$soldRaw';

    final badges = <String>[];
    if (kind == 1) {
      badges.add('虚拟发放');
    }
    if (points > 0 && (double.tryParse(price) ?? 0) > 0) {
      badges.add('积分+现金');
    } else if (points > 0) {
      badges.add('积分兑换');
    }

    return MallProductCardModel(
      id: idStr,
      skuId: (json['sku_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      price: price,
      coverUrl: json['cover_url']?.toString() ?? '',
      imageAspectRatio: aspect < 0.5 ? 1.0 : aspect,
      kind: kind,
      subtitle: json['subtitle']?.toString(),
      points: points > 0 ? points : null,
      soldLabel: soldLabel,
      badges: badges,
    );
  }

  final String id;
  final int skuId;
  final String title;
  final String price;
  final String coverUrl;
  final double imageAspectRatio;
  final int kind;
  final String? subtitle;
  final int? points;
  final String? soldLabel;
  final List<String> badges;

  bool get isVirtual => kind == 1;

  /// 价格文案：积分 / 积分+元 / 纯元。
  String get priceLabel {
    final p = points;
    final cny = double.tryParse(price) ?? 0;
    if (p != null && p > 0 && cny > 0) {
      return '$p积分+$price元';
    }
    if (p != null && p > 0) {
      return '$p积分';
    }
    return '$price元';
  }
}
