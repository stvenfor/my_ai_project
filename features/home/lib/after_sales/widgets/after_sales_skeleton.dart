import 'package:flutter/material.dart';
import 'package:module_home/after_sales/theme/after_sales_theme.dart';

/// 售后专区骨架屏（共享脉冲控制器）。
class AfterSalesListSkeleton extends StatefulWidget {
  const AfterSalesListSkeleton({super.key});

  @override
  State<AfterSalesListSkeleton> createState() => _AfterSalesListSkeletonState();
}

class _AfterSalesListSkeletonState extends State<AfterSalesListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = 0.42 + 0.38 * _pulse.value;
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _bone(t, height: 132, radius: 16),
            const SizedBox(height: 16),
            _bone(t, width: 96, height: 16),
            const SizedBox(height: 12),
            for (var i = 0; i < 4; i++) ...[
              _RecordBone(opacity: t),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

/// 详情页骨架。
class AfterSalesDetailSkeleton extends StatefulWidget {
  const AfterSalesDetailSkeleton({super.key});

  @override
  State<AfterSalesDetailSkeleton> createState() => _AfterSalesDetailSkeletonState();
}

class _AfterSalesDetailSkeletonState extends State<AfterSalesDetailSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = 0.42 + 0.38 * _pulse.value;
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _bone(t, height: 110, radius: 16),
            const SizedBox(height: 12),
            _bone(t, height: 120, radius: 14),
            const SizedBox(height: 12),
            _bone(t, height: 100, radius: 14),
          ],
        );
      },
    );
  }
}

class _RecordBone extends StatelessWidget {
  const _RecordBone({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AfterSalesTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bone(opacity, width: 48, height: 22, radius: 8),
              const Spacer(),
              _bone(opacity, width: 72, height: 12, radius: 6),
            ],
          ),
          const SizedBox(height: 12),
          _bone(opacity, width: double.infinity, height: 16, radius: 6),
          const SizedBox(height: 10),
          _bone(opacity, width: 180, height: 12, radius: 6),
        ],
      ),
    );
  }
}

Widget _bone(
  double opacity, {
  double? width,
  required double height,
  double radius = 8,
}) {
  return Opacity(
    opacity: opacity,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF1),
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

/// 列表项交错淡入上滑。
class AfterSalesFadeSlideIn extends StatelessWidget {
  const AfterSalesFadeSlideIn({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delayMs = (index.clamp(0, 8) * 45);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
