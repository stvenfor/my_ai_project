/// 签到 / 积分 API 读模型（对齐 Go BFF snake_case）。
class PointsStatus {
  const PointsStatus({
    required this.balance,
    required this.checkedInToday,
    required this.streak,
    required this.todayReward,
    required this.calendar,
  });

  factory PointsStatus.fromJson(Map<String, dynamic> json) {
    final raw = json['calendar'] as List<dynamic>? ?? const [];
    return PointsStatus(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      checkedInToday: json['checked_in_today'] == true,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      todayReward: (json['today_reward'] as num?)?.toInt() ?? 5,
      calendar: [
        for (final item in raw)
          if (item is Map<String, dynamic>) CheckInDayView.fromJson(item),
      ],
    );
  }

  final int balance;
  final bool checkedInToday;
  final int streak;
  final int todayReward;
  final List<CheckInDayView> calendar;
}

class CheckInDayView {
  const CheckInDayView({
    required this.day,
    required this.signed,
    required this.reward,
    required this.isToday,
  });

  factory CheckInDayView.fromJson(Map<String, dynamic> json) {
    return CheckInDayView(
      day: json['day']?.toString() ?? '',
      signed: json['signed'] == true,
      reward: (json['reward'] as num?)?.toInt() ?? 5,
      isToday: json['is_today'] == true,
    );
  }

  final String day;
  final bool signed;
  final int reward;
  final bool isToday;
}

class CheckInResult {
  const CheckInResult({
    required this.points,
    required this.balance,
    required this.streak,
    required this.day,
  });

  factory CheckInResult.fromJson(Map<String, dynamic> json) {
    return CheckInResult(
      points: (json['points'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      day: json['day']?.toString() ?? '',
    );
  }

  final int points;
  final int balance;
  final int streak;
  final String day;
}

enum TaskProgress { incomplete, claimable, claimed }

class GrowthTask {
  const GrowthTask({
    required this.code,
    required this.title,
    required this.reward,
    required this.progress,
  });

  factory GrowthTask.fromJson(Map<String, dynamic> json) {
    return GrowthTask(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      reward: (json['reward'] as num?)?.toInt() ?? 0,
      progress: TaskProgressX.parse(json['progress']?.toString()),
    );
  }

  final String code;
  final String title;
  final int reward;
  final TaskProgress progress;
}

extension TaskProgressX on TaskProgress {
  static TaskProgress parse(String? raw) {
    switch (raw) {
      case 'claimable':
        return TaskProgress.claimable;
      case 'claimed':
        return TaskProgress.claimed;
      default:
        return TaskProgress.incomplete;
    }
  }
}

class ClaimTaskResult {
  const ClaimTaskResult({
    required this.points,
    required this.balance,
    required this.day,
  });

  factory ClaimTaskResult.fromJson(Map<String, dynamic> json) {
    return ClaimTaskResult(
      points: (json['points'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      day: json['day']?.toString() ?? '',
    );
  }

  final int points;
  final int balance;
  final String day;
}

/// 签到页货架轻量卡片（仅解析积分货架所需字段）。
class PointsGiftItem {
  const PointsGiftItem({
    required this.productId,
    required this.skuId,
    required this.title,
    required this.coverUrl,
    required this.price,
    required this.pricePoints,
  });

  factory PointsGiftItem.fromJson(Map<String, dynamic> json) {
    return PointsGiftItem(
      productId: (json['product_id'] ?? json['id'])?.toString() ?? '',
      skuId: (json['sku_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      pricePoints: (json['price_points'] as num?)?.toInt() ?? 0,
    );
  }

  final String productId;
  final int skuId;
  final String title;
  final String coverUrl;
  final String price;
  final int pricePoints;

  String get priceLabel {
    if (pricePoints > 0) {
      final cny = double.tryParse(price) ?? 0;
      if (cny > 0) return '$pricePoints积分+$price元';
      return '$pricePoints积分';
    }
    return '$price元';
  }
}
