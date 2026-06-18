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
}

/// 购车客户。
class DealInvoiceCustomer {
  const DealInvoiceCustomer({
    required this.phone,
    required this.name,
  });

  final String phone;
  final String name;

  String get display => '$phone $name';

  static const mockList = [
    DealInvoiceCustomer(phone: '13812345678', name: '小张女士'),
    DealInvoiceCustomer(phone: '13612345678', name: '王先生'),
    DealInvoiceCustomer(phone: '13987654321', name: '李女士'),
  ];
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
  all('全部发票'),
  pendingReview('待审核'),
  approved('已通过'),
  rejected('未通过');

  const DealInvoiceTab(this.label);
  final String label;
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

  static const demo = DealInvoiceStats(
    uploaded: 5,
    pendingReview: 2,
    approved: 2,
    rejected: 1,
  );
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
  });

  final String id;
  final String phone;
  final String? customerName;
  final DealInvoiceStatus status;
  final DateTime submittedAt;
  final String? rejectReason;
  final int? ratingStars;

  String get customerDisplay {
    if (customerName != null && customerName!.isNotEmpty) {
      return '$phone $customerName';
    }
    return phone;
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
