/// 首页待办卡模型与尺寸映射（ADR 0009：客户端由 type 推导尺寸）。
enum HomeTodoSize {
  small(1),
  medium(2),
  large(4);

  const HomeTodoSize(this.cells);
  final int cells;

  static HomeTodoSize fromType(String type) {
    switch (type) {
      case 'partner_pending':
        return HomeTodoSize.large;
      case 'follow_up_customer':
      case 'after_sales_appointment':
        return HomeTodoSize.medium;
      default:
        return HomeTodoSize.small;
    }
  }
}

class HomeTodoCard {
  const HomeTodoCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionRoute,
    required this.count,
    this.imageUrl,
  });

  final String type;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String actionRoute;
  final int count;
  final String? imageUrl;

  HomeTodoSize get size => HomeTodoSize.fromType(type);

  factory HomeTodoCard.fromJson(Map<String, dynamic> json) {
    return HomeTodoCard(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? '去查看',
      actionRoute: json['action_route']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString(),
    );
  }

  /// 兼容旧 mock 快捷卡字段。
  factory HomeTodoCard.fromLegacy({
    required String title,
    required String subtitle,
    required String actionLabel,
    String? imageUrl,
    String type = 'order_pending_review',
  }) {
    return HomeTodoCard(
      type: type,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      actionRoute: '',
      count: 1,
      imageUrl: imageUrl,
    );
  }
}

class HomeTodoJoinApplication {
  const HomeTodoJoinApplication({
    required this.applicationId,
    required this.storeId,
    required this.applicantUserId,
    required this.status,
  });

  final int applicationId;
  final int storeId;
  final String applicantUserId;
  final int status;

  factory HomeTodoJoinApplication.fromJson(Map<String, dynamic> json) {
    return HomeTodoJoinApplication(
      applicationId: (json['application_id'] as num?)?.toInt() ?? 0,
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      applicantUserId: json['applicant_user_id']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}
