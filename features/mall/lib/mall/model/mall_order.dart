/// 买家订单列表行 / 详情（snake_case 对齐 Go BFF）。
class MallOrderItem {
  const MallOrderItem({
    required this.itemId,
    required this.orderId,
    required this.productTitle,
    required this.qty,
    required this.lineAmount,
    required this.kind,
    this.coverUrl = '',
    this.contentUrl = '',
  });

  factory MallOrderItem.fromJson(Map<String, dynamic> json) {
    return MallOrderItem(
      itemId: (json['item_id'] as num?)?.toInt() ?? 0,
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      productTitle: json['product_title']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      lineAmount: json['line_amount']?.toString() ?? '0.00',
      kind: (json['kind'] as num?)?.toInt() ?? 0,
      contentUrl: json['content_url']?.toString() ?? '',
    );
  }

  final int itemId;
  final int orderId;
  final String productTitle;
  final String coverUrl;
  final int qty;
  final String lineAmount;
  final int kind;
  final String contentUrl;

  bool get isVirtual => kind == 1;
}

class MallOrderListRow {
  const MallOrderListRow({
    required this.orderId,
    required this.orderNo,
    required this.storeId,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.items,
    this.payDeadlineAt = '',
  });

  factory MallOrderListRow.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <MallOrderItem>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map<String, dynamic>) {
          items.add(MallOrderItem.fromJson(e));
        } else if (e is Map) {
          items.add(MallOrderItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return MallOrderListRow(
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      orderNo: json['order_no']?.toString() ?? '',
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      createdAt: json['created_at']?.toString() ?? '',
      payDeadlineAt: json['pay_deadline_at']?.toString() ?? '',
      items: items,
    );
  }

  final int orderId;
  final String orderNo;
  final int storeId;
  final int status;
  final String amount;
  final String createdAt;
  final String payDeadlineAt;
  final List<MallOrderItem> items;

  String get statusLabel => mallOrderStatusLabel(status);

  bool get isUnpaid => status == 0;

  String get primaryTitle =>
      items.isEmpty ? '订单 $orderNo' : items.first.productTitle;

  String get primaryCover => items.isEmpty ? '' : items.first.coverUrl;

  int get totalQty => items.fold(0, (s, e) => s + e.qty);

  DateTime? get payDeadline => parseMallTime(payDeadlineAt);
}

class MallOrderDetail {
  const MallOrderDetail({
    required this.orderId,
    required this.orderNo,
    required this.storeId,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.items,
    this.receiverName = '',
    this.receiverPhone = '',
    this.receiverAddress = '',
    this.paymentChannel,
    this.paidAt = '',
    this.payDeadlineAt = '',
    this.totalPoints = 0,
  });

  factory MallOrderDetail.fromJson(Map<String, dynamic> json) {
    final order = json['order'];
    final orderMap = order is Map<String, dynamic>
        ? order
        : order is Map
            ? Map<String, dynamic>.from(order)
            : <String, dynamic>{};
    final rawItems = json['items'];
    final items = <MallOrderItem>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map<String, dynamic>) {
          items.add(MallOrderItem.fromJson(e));
        } else if (e is Map) {
          items.add(MallOrderItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return MallOrderDetail(
      orderId: (orderMap['order_id'] as num?)?.toInt() ?? 0,
      orderNo: orderMap['order_no']?.toString() ?? '',
      storeId: (orderMap['store_id'] as num?)?.toInt() ?? 0,
      status: (orderMap['status'] as num?)?.toInt() ?? 0,
      amount: orderMap['amount']?.toString() ?? '0.00',
      createdAt: orderMap['created_at']?.toString() ?? '',
      receiverName: orderMap['receiver_name']?.toString() ?? '',
      receiverPhone: orderMap['receiver_phone']?.toString() ?? '',
      receiverAddress: orderMap['receiver_address']?.toString() ?? '',
      paymentChannel: (orderMap['payment_channel'] as num?)?.toInt(),
      paidAt: orderMap['paid_at']?.toString() ?? '',
      payDeadlineAt: json['pay_deadline_at']?.toString() ?? '',
      totalPoints: (orderMap['total_points'] as num?)?.toInt() ?? 0,
      items: items,
    );
  }

  final int orderId;
  final String orderNo;
  final int storeId;
  final int status;
  final String amount;
  final String createdAt;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final int? paymentChannel;
  final String paidAt;
  final String payDeadlineAt;
  final int totalPoints;
  final List<MallOrderItem> items;

  String get statusLabel => mallOrderStatusLabel(status);

  bool get isUnpaid => status == 0;

  DateTime? get payDeadline => parseMallTime(payDeadlineAt);

  bool get hasReceiver =>
      receiverName.trim().isNotEmpty ||
      receiverPhone.trim().isNotEmpty ||
      receiverAddress.trim().isNotEmpty;
}

String mallOrderStatusLabel(int status) {
  switch (status) {
    case 0:
      return '待支付';
    case 1:
      return '已支付';
    case 2:
      return '已履约';
    case 3:
      return '已取消';
    case 4:
      return '已关闭';
    default:
      return '未知';
  }
}

DateTime? parseMallTime(String raw) {
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}

/// 剩余支付时间，格式 `HH:MM:SS`（不足 1 小时也补零小时）。
String formatPayCountdown(Duration remaining) {
  var d = remaining;
  if (d.isNegative) d = Duration.zero;
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
