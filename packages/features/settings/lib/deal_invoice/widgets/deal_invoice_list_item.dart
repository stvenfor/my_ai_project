import 'package:flutter/material.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';

/// 发票列表卡片。
class DealInvoiceListItem extends StatelessWidget {
  const DealInvoiceListItem({
    super.key,
    required this.item,
    this.onTap,
    this.onProcess,
  });

  final DealInvoiceItem item;
  final VoidCallback? onTap;
  final VoidCallback? onProcess;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _Tag(label: '成交手机'),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.phone,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusLabel(status: item.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '提交时间: ${_formatTime(item.submittedAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (item.status == DealInvoiceStatus.rejected &&
                  item.rejectReason != null) ...[
                const SizedBox(height: 10),
                Text(
                  '未通过原因: ${item.rejectReason}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE53935),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onProcess,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B8CFF),
                    side: const BorderSide(color: Color(0xFF3B8CFF)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('处理', style: TextStyle(fontSize: 13)),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final y = time.year;
    final m = time.month.toString().padLeft(2, '0');
    final d = time.day.toString().padLeft(2, '0');
    final h = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final DealInvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DealInvoiceStatus.rated => const _RichStatus(
          parts: [
            _StatusPart('已评价 ', Color(0xFF666666)),
            _StatusPart('5星', Color(0xFFFAAD14)),
          ],
        ),
      DealInvoiceStatus.approvedPendingRating => const _RichStatus(
          parts: [
            _StatusPart('已审核 ', Color(0xFF52C41A)),
            _StatusPart('待评价', Color(0xFFFAAD14)),
          ],
        ),
      DealInvoiceStatus.pendingReview => const _RichStatus(
          parts: [
            _StatusPart('待审核', Color(0xFFFAAD14)),
          ],
        ),
      DealInvoiceStatus.rejected => const _RichStatus(
          parts: [
            _StatusPart('未通过', Color(0xFFE53935)),
          ],
        ),
    };
  }
}

class _StatusPart {
  const _StatusPart(this.text, this.color);
  final String text;
  final Color color;
}

class _RichStatus extends StatelessWidget {
  const _RichStatus({required this.parts});

  final List<_StatusPart> parts;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          for (final part in parts)
            TextSpan(
              text: part.text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: part.color,
              ),
            ),
        ],
      ),
    );
  }
}
