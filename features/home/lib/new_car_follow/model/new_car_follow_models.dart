/// 新车跟进档案模型与 Tab。
enum NewCarFollowTab {
  all,
  high,
  medium,
  low,
  overdue,
}

extension NewCarFollowTabX on NewCarFollowTab {
  String get label => switch (this) {
        NewCarFollowTab.all => '全部',
        NewCarFollowTab.high => '高意向',
        NewCarFollowTab.medium => '中意向',
        NewCarFollowTab.low => '低意向',
        NewCarFollowTab.overdue => '逾期',
      };

  Map<String, dynamic> get query => switch (this) {
        NewCarFollowTab.all => const {},
        NewCarFollowTab.high => const {'intent_band': '高'},
        NewCarFollowTab.medium => const {'intent_band': '中'},
        NewCarFollowTab.low => const {'intent_band': '低'},
        NewCarFollowTab.overdue => const {'overdue': '1'},
      };
}

class NewCarFollowStats {
  const NewCarFollowStats({
    required this.active,
    required this.overdue,
    required this.highIntent,
    required this.lost,
  });

  final int active;
  final int overdue;
  final int highIntent;
  final int lost;

  factory NewCarFollowStats.fromJson(Map<String, dynamic> json) {
    return NewCarFollowStats(
      active: _int(json['active']),
      overdue: _int(json['overdue']),
      highIntent: _int(json['high_intent']),
      lost: _int(json['lost']),
    );
  }
}

class NewCarFollowSummary {
  const NewCarFollowSummary({
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
  final NewCarFollowStats stats;

  factory NewCarFollowSummary.fromJson(Map<String, dynamic> json) {
    return NewCarFollowSummary(
      displayName: (json['display_name'] as String?) ?? '',
      avatarUrl: (json['avatar_url'] as String?) ?? '',
      positionLabel: (json['position_label'] as String?) ?? '',
      storeName: (json['store_name'] as String?) ?? '',
      stats: NewCarFollowStats.fromJson(
        (json['stats'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class NewCarFollowFile {
  const NewCarFollowFile({
    required this.fileId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.followLevel,
    required this.intentBand,
    required this.stage,
    required this.vehicleInterest,
    this.nextFollowUpAt,
  });

  final String fileId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String followLevel;
  final String intentBand;
  final String stage;
  final String vehicleInterest;
  final String? nextFollowUpAt;

  factory NewCarFollowFile.fromJson(Map<String, dynamic> json) {
    return NewCarFollowFile(
      fileId: '${json['file_id'] ?? ''}',
      customerId: '${json['customer_id'] ?? ''}',
      customerName: (json['customer_name'] as String?) ?? '',
      customerPhone: (json['customer_phone'] as String?) ?? '',
      followLevel: (json['follow_level'] as String?) ?? '',
      intentBand: (json['intent_band'] as String?) ?? '',
      stage: (json['stage'] as String?) ?? '',
      vehicleInterest: (json['vehicle_interest'] as String?) ?? '',
      nextFollowUpAt: json['next_follow_up_at'] as String?,
    );
  }
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}
