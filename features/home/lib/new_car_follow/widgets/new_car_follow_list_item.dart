import 'package:flutter/material.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';

/// 跟进档案列表卡片。
class NewCarFollowListItem extends StatelessWidget {
  const NewCarFollowListItem({
    super.key,
    required this.item,
    this.onTap,
  });

  final NewCarFollowFile item;
  final VoidCallback? onTap;

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
                        _Tag(label: '客户'),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.customerName.isNotEmpty
                                ? item.customerName
                                : '—',
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
                  _IntentBadge(band: item.intentBand, level: item.followLevel),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.customerPhone.isNotEmpty
                    ? item.customerPhone
                    : '未填手机号',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              if (item.vehicleInterest.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '意向车型: ${item.vehicleInterest}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '阶段 ${NewCarFollowLabels.stage(item.stage)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (item.nextFollowUpAt != null &&
                      item.nextFollowUpAt!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        '下次跟进 ${_shortTime(item.nextFollowUpAt!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (item.ownerDisplayName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '销售 ${item.ownerDisplayName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _shortTime(String raw) {
    if (raw.length >= 16) return raw.substring(0, 16).replaceFirst('T', ' ');
    return raw;
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

class _IntentBadge extends StatelessWidget {
  const _IntentBadge({required this.band, required this.level});

  final String band;
  final String level;

  @override
  Widget build(BuildContext context) {
    final color = switch (band) {
      '高' => const Color(0xFFE53935),
      '中' => const Color(0xFFFAAD14),
      '低' => const Color(0xFF8C8C8C),
      _ => const Color(0xFF3B8CFF),
    };
    final text = level.isNotEmpty ? '$level · $band' : band;
    return Text(
      text.isEmpty ? '—' : text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
