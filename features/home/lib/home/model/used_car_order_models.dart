/// 二手车业务单模型（对齐 Go `/api/v1/used-car-orders`）。
class UsedCarOrderSummary {
  const UsedCarOrderSummary({
    required this.displayName,
    required this.avatarUrl,
    required this.positionLabel,
    required this.storeName,
    required this.stats,
  });

  final String displayName;
  final String avatarUrl;
  final String positionLabel;
  final String storeName;
  final UsedCarOrderStats stats;

  factory UsedCarOrderSummary.fromJson(Map<String, dynamic> json) {
    final statsMap = json['stats'] as Map<String, dynamic>? ?? const {};
    return UsedCarOrderSummary(
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      positionLabel: json['position_label'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      stats: UsedCarOrderStats.fromJson(statsMap),
    );
  }
}

class UsedCarOrderStats {
  const UsedCarOrderStats({
    required this.submitted,
    required this.pendingReview,
    required this.approved,
    required this.rejected,
  });

  final int submitted;
  final int pendingReview;
  final int approved;
  final int rejected;

  factory UsedCarOrderStats.fromJson(Map<String, dynamic> json) {
    return UsedCarOrderStats(
      submitted: (json['submitted'] as num?)?.toInt() ?? 0,
      pendingReview: (json['pending_review'] as num?)?.toInt() ?? 0,
      approved: (json['approved'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
    );
  }
}

enum UsedCarStatusTab { all, pendingReview, approved, rejected }

extension UsedCarStatusTabX on UsedCarStatusTab {
  String get label => switch (this) {
        UsedCarStatusTab.all => '全部',
        UsedCarStatusTab.pendingReview => '待审核',
        UsedCarStatusTab.approved => '已通过',
        UsedCarStatusTab.rejected => '未通过',
      };

  String get apiStatus => switch (this) {
        UsedCarStatusTab.all => 'all',
        UsedCarStatusTab.pendingReview => 'pending_review',
        UsedCarStatusTab.approved => 'approved',
        UsedCarStatusTab.rejected => 'rejected',
      };
}

enum UsedCarKindFilter { all, tradeIn, consign, purchase }

extension UsedCarKindFilterX on UsedCarKindFilter {
  String get label => switch (this) {
        UsedCarKindFilter.all => '全部类型',
        UsedCarKindFilter.tradeIn => '置换',
        UsedCarKindFilter.consign => '专卖',
        UsedCarKindFilter.purchase => '收车',
      };

  String? get apiKind => switch (this) {
        UsedCarKindFilter.all => null,
        UsedCarKindFilter.tradeIn => 'trade_in',
        UsedCarKindFilter.consign => 'consign',
        UsedCarKindFilter.purchase => 'purchase',
      };
}

class UsedCarOrderItem {
  const UsedCarOrderItem({
    required this.orderId,
    required this.kind,
    required this.kindLabel,
    required this.amountLabel,
    required this.customerName,
    required this.phone,
    required this.vehicleModel,
    required this.plateNo,
    required this.vin,
    required this.mileageKm,
    required this.modelYear,
    required this.amount,
    required this.status,
    required this.submittedAt,
    this.rejectReason,
    this.ratingStars,
    this.imageUrl,
  });

  final String orderId;
  final String kind;
  final String kindLabel;
  final String amountLabel;
  final String customerName;
  final String phone;
  final String vehicleModel;
  final String plateNo;
  final String vin;
  final int mileageKm;
  final int modelYear;
  final double amount;
  final String status;
  final DateTime submittedAt;
  final String? rejectReason;
  final int? ratingStars;
  final String? imageUrl;

  String get statusLabel => switch (status) {
        'pending_review' => '待审核',
        'approved_pending_rating' => '已通过待评价',
        'rated' => '已通过已评价',
        'rejected' => '未通过',
        _ => status,
      };

  factory UsedCarOrderItem.fromJson(Map<String, dynamic> json) {
    return UsedCarOrderItem(
      orderId: '${json['order_id'] ?? ''}',
      kind: json['kind'] as String? ?? '',
      kindLabel: json['kind_label'] as String? ?? '',
      amountLabel: json['amount_label'] as String? ?? '业务金额',
      customerName: json['customer_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      vehicleModel: json['vehicle_model'] as String? ?? '',
      plateNo: json['plate_no'] as String? ?? '',
      vin: json['vin'] as String? ?? '',
      mileageKm: (json['mileage_km'] as num?)?.toInt() ?? 0,
      modelYear: (json['model_year'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      rejectReason: json['reject_reason'] as String?,
      ratingStars: (json['rating_stars'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
    );
  }
}

class UsedCarCustomer {
  const UsedCarCustomer({
    required this.customerId,
    required this.displayName,
    required this.phone,
  });

  final int customerId;
  final String displayName;
  final String phone;

  factory UsedCarCustomer.fromJson(Map<String, dynamic> json) {
    return UsedCarCustomer(
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      displayName: json['display_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}
