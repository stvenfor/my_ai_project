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
    this.ownerUserId = '',
    this.ownerDisplayName = '',
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
  final String ownerUserId;
  final String ownerDisplayName;

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
      ownerUserId: (json['owner_user_id'] as String?) ?? '',
      ownerDisplayName: (json['owner_display_name'] as String?) ?? '',
    );
  }
}

class NewCarFollowLog {
  const NewCarFollowLog({
    required this.logId,
    required this.fileId,
    required this.authorUserId,
    required this.body,
    required this.createdAt,
    this.authorDisplayName = '',
    this.followLevel = '',
    this.intentBand = '',
    this.nextFollowUpAt,
  });

  final String logId;
  final String fileId;
  final String authorUserId;
  final String authorDisplayName;
  final String body;
  final String followLevel;
  final String intentBand;
  final String? nextFollowUpAt;
  final String createdAt;

  factory NewCarFollowLog.fromJson(Map<String, dynamic> json) {
    return NewCarFollowLog(
      logId: '${json['log_id'] ?? ''}',
      fileId: '${json['file_id'] ?? ''}',
      authorUserId: (json['author_user_id'] as String?) ?? '',
      authorDisplayName: (json['author_display_name'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      followLevel: (json['follow_level'] as String?) ?? '',
      intentBand: (json['intent_band'] as String?) ?? '',
      nextFollowUpAt: json['next_follow_up_at'] as String?,
      createdAt: '${json['created_at'] ?? ''}',
    );
  }
}

/// UI 文案（阶段 / 级别）。
abstract final class NewCarFollowLabels {
  static String stage(String raw) => switch (raw) {
        'new' => '新建',
        'following' => '跟进中',
        'test_drive' => '试驾',
        'quoted' => '已报价',
        'won' => '成交',
        'lost' => '战败',
        _ => raw.isEmpty ? '—' : raw,
      };

  static String level(String lv) => switch (lv) {
        'H' => 'H · 高意向（急）',
        'A' => 'A · 高意向',
        'B' => 'B · 中意向',
        'E' => 'E · 低意向',
        _ => lv,
      };

  static const levelChoices = <(String, String)>[
    ('H', 'H · 高意向（急）'),
    ('A', 'A · 高意向'),
    ('B', 'B · 中意向'),
    ('E', 'E · 低意向'),
  ];
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}
