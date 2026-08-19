import 'package:flutter/material.dart';
import 'package:module_community/community/theme/community_theme.dart';

class PostSkeletonWidget extends StatelessWidget {
  const PostSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => DecoratedBox(
        decoration: CommunityTheme.groupedCardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bone(44, 44, circle: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bone(double.infinity, 14),
                        const SizedBox(height: 8),
                        _bone(120, 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _bone(double.infinity, 14),
              const SizedBox(height: 8),
              _bone(double.infinity, 14),
              const SizedBox(height: 8),
              _bone(200, 14),
              const SizedBox(height: 12),
              _bone(double.infinity, 160),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bone(double width, double height, {bool circle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CommunityTheme.fillSecondary,
        borderRadius: circle ? null : BorderRadius.circular(6),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
