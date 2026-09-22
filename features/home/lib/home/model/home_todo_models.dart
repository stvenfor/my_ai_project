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
    required this.applicantName,
    required this.status,
    this.createdAt,
  });

  final int applicationId;
  final int storeId;
  final String applicantUserId;
  final String applicantName;
  final int status;
  final DateTime? createdAt;

  String get displayName =>
      applicantName.trim().isNotEmpty ? applicantName.trim() : applicantUserId;

  factory HomeTodoJoinApplication.fromJson(Map<String, dynamic> json) {
    return HomeTodoJoinApplication(
      applicationId: (json['application_id'] as num?)?.toInt() ?? 0,
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      applicantUserId: json['applicant_user_id']?.toString() ?? '',
      applicantName: json['applicant_name']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

class HomeTodoFollowUpCustomer {
  const HomeTodoFollowUpCustomer({
    required this.customerId,
    required this.displayName,
    this.nextFollowUpAt,
  });

  final int customerId;
  final String displayName;
  final DateTime? nextFollowUpAt;

  factory HomeTodoFollowUpCustomer.fromJson(Map<String, dynamic> json) {
    return HomeTodoFollowUpCustomer(
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      displayName: json['display_name']?.toString() ?? '客户',
      nextFollowUpAt: _parseDateTime(json['next_follow_up_at']),
    );
  }
}

class HomeTodoAppointment {
  const HomeTodoAppointment({
    required this.appointmentId,
    required this.customerName,
    this.appointmentDate,
    required this.status,
  });

  final int appointmentId;
  final String customerName;
  final DateTime? appointmentDate;
  final int status;

  factory HomeTodoAppointment.fromJson(Map<String, dynamic> json) {
    return HomeTodoAppointment(
      appointmentId: (json['appointment_id'] as num?)?.toInt() ?? 0,
      customerName: json['customer_name']?.toString() ?? '预约客户',
      appointmentDate: _parseDateTime(json['appointment_date']),
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}

class HomeTodoReviewOrder {
  const HomeTodoReviewOrder({
    required this.orderId,
    required this.title,
    required this.status,
    this.createdAt,
  });

  final int orderId;
  final String title;
  final int status;
  final DateTime? createdAt;

  factory HomeTodoReviewOrder.fromJson(Map<String, dynamic> json) {
    return HomeTodoReviewOrder(
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '审核单',
      status: (json['status'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

DateTime? _parseDateTime(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}

String formatTodoDateTime(DateTime? dt, {String fallback = '-'}) {
  if (dt == null) return fallback;
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  if (local.hour == 0 && local.minute == 0 && local.second == 0) {
    return '$y-$m-$d';
  }
  return '$y-$m-$d $hh:$mm';
}

String formatTodoDate(DateTime? dt, {String fallback = '-'}) {
  if (dt == null) return fallback;
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
