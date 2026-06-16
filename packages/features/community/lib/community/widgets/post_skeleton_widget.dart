import 'package:flutter/material.dart';

class PostSkeletonWidget extends StatelessWidget {
  const PostSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _bone(context, 44, 44, circle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(context, double.infinity, 14),
                      const SizedBox(height: 8),
                      _bone(context, 120, 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _bone(context, double.infinity, 14),
            const SizedBox(height: 8),
            _bone(context, double.infinity, 14),
            const SizedBox(height: 8),
            _bone(context, 200, 14),
            const SizedBox(height: 12),
            _bone(context, double.infinity, 180),
          ],
        ),
      ),
    );
  }

  Widget _bone(
    BuildContext context,
    double width,
    double height, {
    bool circle = false,
  }) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: circle ? null : BorderRadius.circular(4),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
