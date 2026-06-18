import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';

/// 成交发票列表示例 Mock（分页）。
class DealInvoiceMockRepository {
  DealInvoiceMockRepository._();

  static const pageSize = 10;
  static const maxPages = 5;

  static final _seedItems = [
    DealInvoiceItem(
      id: 'seed_1',
      phone: '13612345678',
      customerName: '小张女士',
      status: DealInvoiceStatus.rated,
      submittedAt: DateTime(2021, 3, 18, 12, 59, 59),
      ratingStars: 4,
    ),
    DealInvoiceItem(
      id: 'seed_2',
      phone: '13612345678',
      customerName: '小张女士',
      status: DealInvoiceStatus.approvedPendingRating,
      submittedAt: DateTime(2021, 3, 18, 12, 59, 59),
    ),
    DealInvoiceItem(
      id: 'seed_3',
      phone: '13612345678',
      customerName: '小张女士',
      status: DealInvoiceStatus.pendingReview,
      submittedAt: DateTime(2021, 3, 18, 12, 59, 59),
    ),
    DealInvoiceItem(
      id: 'seed_4',
      phone: '13612345678',
      customerName: '小张女士',
      status: DealInvoiceStatus.pendingReview,
      submittedAt: DateTime(2021, 3, 18, 12, 59, 59),
    ),
    DealInvoiceItem(
      id: 'seed_5',
      phone: '13612345678',
      customerName: '小张女士',
      status: DealInvoiceStatus.rejected,
      submittedAt: DateTime(2021, 3, 18, 12, 59, 59),
      rejectReason: '重复上传发票，请核对后重新提交',
    ),
  ];

  static const _statusCycle = [
    DealInvoiceStatus.rated,
    DealInvoiceStatus.approvedPendingRating,
    DealInvoiceStatus.pendingReview,
    DealInvoiceStatus.rejected,
  ];

  static Future<List<DealInvoiceItem>> fetch({
    required DealInvoiceTab tab,
    required int page,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (page >= maxPages) return [];

    final all = page == 0
        ? List<DealInvoiceItem>.from(_seedItems)
        : _generatePage(page);

    return all.where((item) => item.matchesTab(tab)).toList();
  }

  static List<DealInvoiceItem> _generatePage(int page) {
    return List.generate(pageSize, (index) {
      final seq = page * pageSize + index;
      final status = _statusCycle[seq % _statusCycle.length];
      return DealInvoiceItem(
        id: 'page_${page}_$index',
        phone: '138${(10000000 + seq).toString().substring(1)}',
        status: status,
        submittedAt: DateTime(2021, 3, 18, 12, 59, 59).add(Duration(hours: seq)),
        rejectReason: status == DealInvoiceStatus.rejected
            ? '发票信息不清晰，请重新拍摄上传'
            : null,
      );
    });
  }
}
