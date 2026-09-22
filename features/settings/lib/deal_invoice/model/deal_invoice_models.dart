import 'package:flutter/material.dart';

/// 成交发票审核状态。
enum DealInvoiceStatus {
  pendingReview,
  approvedPendingRating,
  rated,
  rejected;

  String get auditLabel => switch (this) {
        DealInvoiceStatus.pendingReview => '待审核',
        DealInvoiceStatus.approvedPendingRating => '已通过',
        DealInvoiceStatus.rated => '已通过',
        DealInvoiceStatus.rejected => '未通过',
      };

  Color get auditColor => switch (this) {
        DealInvoiceStatus.pendingReview => const Color(0xFFFAAD14),
        DealInvoiceStatus.approvedPendingRating => const Color(0xFF52C41A),
        DealInvoiceStatus.rated => const Color(0xFF52C41A),
        DealInvoiceStatus.rejected => const Color(0xFFE53935),
      };

  static DealInvoiceStatus fromApi(String? raw) {
    return switch (raw) {
      'approved_pending_rating' => DealInvoiceStatus.approvedPendingRating,
      'rated' => DealInvoiceStatus.rated,
      'rejected' => DealInvoiceStatus.rejected,
      _ => DealInvoiceStatus.pendingReview,
    };
  }
}

/// 购车客户。
class DealInvoiceCustomer {
  const DealInvoiceCustomer({
    required this.id,
    required this.phone,
    required this.name,
  });

  final int id;
  final String phone;
  final String name;

  String get display => '$phone $name';

  factory DealInvoiceCustomer.fromJson(Map<String, dynamic> json) {
    return DealInvoiceCustomer(
      id: _intOf(json['customer_id'] ?? json['id']),
      phone: '${json['phone'] ?? ''}',
      name: '${json['display_name'] ?? json['name'] ?? ''}',
    );
  }

  static int _intOf(dynamic v) {
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }
}

/// 上传页场景。
enum DealInvoiceUploadScene {
  create,
  detail,
  reupload,
}

/// 上传页路由参数。
class DealInvoiceUploadArgs {
  const DealInvoiceUploadArgs({
    this.scene = DealInvoiceUploadScene.create,
    this.item,
  });

  final DealInvoiceUploadScene scene;
  final DealInvoiceItem? item;
}

/// 上传页 UI 阶段。
enum DealInvoiceUploadPhase {
  editing,
  uploading,
  detail,
}

/// Tab 筛选类型。
enum DealInvoiceTab {
  all('全部发票', 'all'),
  pendingReview('待审核', 'pending_review'),
  approved('已通过', 'approved'),
  rejected('未通过', 'rejected');

  const DealInvoiceTab(this.label, this.apiStatus);
  final String label;
  final String apiStatus;
}

/// 顶部统计。
class DealInvoiceStats {
  const DealInvoiceStats({
    required this.uploaded,
    required this.pendingReview,
    required this.approved,
    required this.rejected,
  });

  final int uploaded;
  final int pendingReview;
  final int approved;
  final int rejected;

  factory DealInvoiceStats.fromJson(Map<String, dynamic> json) {
    return DealInvoiceStats(
      uploaded: _intOf(json['uploaded']),
      pendingReview: _intOf(json['pending_review']),
      approved: _intOf(json['approved']),
      rejected: _intOf(json['rejected']),
    );
  }

  static int _intOf(dynamic v) {
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }
}

/// 列表顶栏摘要。
class DealInvoiceSummary {
  const DealInvoiceSummary({
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
  final DealInvoiceStats stats;

  factory DealInvoiceSummary.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    return DealInvoiceSummary(
      displayName: '${json['display_name'] ?? ''}',
      avatarUrl: '${json['avatar_url'] ?? ''}',
      positionLabel: '${json['position_label'] ?? ''}',
      storeName: '${json['store_name'] ?? ''}',
      stats: statsRaw is Map<String, dynamic>
          ? DealInvoiceStats.fromJson(statsRaw)
          : const DealInvoiceStats(
              uploaded: 0,
              pendingReview: 0,
              approved: 0,
              rejected: 0,
            ),
    );
  }

  DealInvoiceSummary copyWith({
    String? displayName,
    String? avatarUrl,
    String? positionLabel,
    String? storeName,
    DealInvoiceStats? stats,
  }) {
    return DealInvoiceSummary(
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      positionLabel: positionLabel ?? this.positionLabel,
      storeName: storeName ?? this.storeName,
      stats: stats ?? this.stats,
    );
  }
}

/// 列表项。
class DealInvoiceItem {
  const DealInvoiceItem({
    required this.id,
    required this.phone,
    required this.status,
    required this.submittedAt,
    this.customerName,
    this.rejectReason,
    this.ratingStars,
    this.imageUrl,
  });

  final String id;
  final String phone;
  final String? customerName;
  final DealInvoiceStatus status;
  final DateTime submittedAt;
  final String? rejectReason;
  final int? ratingStars;
  final String? imageUrl;

  String get customerDisplay {
    if (customerName != null && customerName!.isNotEmpty) {
      return '$phone $customerName';
    }
    return phone;
  }

  factory DealInvoiceItem.fromJson(Map<String, dynamic> json) {
    return DealInvoiceItem(
      id: '${json['invoice_id'] ?? json['id'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      customerName: json['customer_name']?.toString(),
      status: DealInvoiceStatus.fromApi(json['status']?.toString()),
      submittedAt: DateTime.tryParse('${json['submitted_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      rejectReason: json['reject_reason']?.toString(),
      ratingStars: json['rating_stars'] is int
          ? json['rating_stars'] as int
          : int.tryParse('${json['rating_stars'] ?? ''}'),
      imageUrl: json['image_url']?.toString(),
    );
  }

  bool matchesTab(DealInvoiceTab tab) {
    return switch (tab) {
      DealInvoiceTab.all => true,
      DealInvoiceTab.pendingReview => status == DealInvoiceStatus.pendingReview,
      DealInvoiceTab.approved =>
        status == DealInvoiceStatus.approvedPendingRating ||
            status == DealInvoiceStatus.rated,
      DealInvoiceTab.rejected => status == DealInvoiceStatus.rejected,
    };
  }
}
