/// 商品详情（GET .../products/:product_id）。只含接口真实字段。
class MallProductDetail {
  const MallProductDetail({
    required this.productId,
    required this.title,
    required this.coverUrl,
    required this.coverAspect,
    required this.kind,
    required this.skus,
  });

  factory MallProductDetail.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? const {};
    final rawSkus = json['skus'] as List<dynamic>? ?? const [];
    return MallProductDetail(
      productId: product['product_id']?.toString() ?? '',
      title: product['title']?.toString() ?? '',
      coverUrl: product['cover_url']?.toString() ?? '',
      coverAspect: (product['cover_aspect'] as num?)?.toDouble() ?? 1,
      kind: (product['kind'] as num?)?.toInt() ?? 0,
      skus: [
        for (final item in rawSkus)
          if (item is Map<String, dynamic>) MallSkuOffer.fromJson(item),
      ],
    );
  }

  final String productId;
  final String title;
  final String coverUrl;
  final double coverAspect;
  final int kind;
  final List<MallSkuOffer> skus;

  bool get isVirtual => kind == 1;
}

class MallSkuOffer {
  const MallSkuOffer({
    required this.skuId,
    required this.title,
    required this.price,
    required this.stockQty,
    required this.specs,
    this.deliverType,
  });

  factory MallSkuOffer.fromJson(Map<String, dynamic> json) {
    final specs = json['specs'];
    return MallSkuOffer(
      skuId: (json['sku_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      stockQty: (json['stock_qty'] as num?)?.toInt() ?? 0,
      specs: specs is Map<String, dynamic> ? specs : const {},
      deliverType: (json['deliver_type'] as num?)?.toInt(),
    );
  }

  final int skuId;
  final String title;
  final String price;
  final int stockQty;
  final Map<String, dynamic> specs;
  final int? deliverType;

  String get label {
    if (specs.isEmpty) {
      return title.isEmpty ? '默认规格' : title;
    }
    return specs.entries.map((e) => '${e.key} ${e.value}').join(' / ');
  }
}
