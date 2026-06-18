import 'package:flutter/material.dart';

/// 信息行（label - value）。
class DealInvoiceInfoRow extends StatelessWidget {
  const DealInvoiceInfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueColor,
    this.trailing,
  });

  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: trailing ??
                Text(
                  value ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? const Color(0xFF666666),
                    height: 1.45,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class DealInvoiceStarRating extends StatelessWidget {
  const DealInvoiceStarRating({super.key, required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 22,
          color: filled ? const Color(0xFFFAAD14) : Colors.grey.shade300,
        );
      }),
    );
  }
}
