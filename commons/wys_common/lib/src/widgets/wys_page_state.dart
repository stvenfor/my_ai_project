import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 全页/区块加载中。
///
/// 优先用宿主/本地 Lottie（默认 `assets/lotties/`）；资源缺失时回退 Progress。
class WysLoadingView extends StatelessWidget {
  const WysLoadingView({
    super.key,
    this.message,
    this.size = 160,
    this.animationSize = 100,
    this.backgroundColor = const Color(0xCC000000),
    this.lottieAsset = 'assets/lotties/loading.json',
    this.lottiePackage,
  });

  final String? message;
  final double size;
  final double animationSize;
  final Color backgroundColor;

  /// 本地已有 Lottie 路径（根工程 `assets/lotties/`）；勿再引用迁入品牌资源。
  final String lottieAsset;

  /// 非空时从指定 package 加载 [lottieAsset]。
  final String? lottiePackage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              lottieAsset,
              package: lottiePackage,
              width: animationSize,
              height: animationSize,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, __, ___) => SizedBox(
                width: animationSize.clamp(24.0, 48.0),
                height: animationSize.clamp(24.0, 48.0),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  message!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 浮层加载中，适合 Stack 中覆盖当前内容。
class WysLoadingOverlay extends StatelessWidget {
  const WysLoadingOverlay({
    super.key,
    this.message,
    this.barrierColor = const Color(0x33000000),
  });

  final String? message;
  final Color barrierColor;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: barrierColor,
        child: WysLoadingView(message: message),
      ),
    );
  }
}

/// 空数据。
class WysEmptyView extends StatelessWidget {
  const WysEmptyView({
    super.key,
    this.message = '暂无数据',
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载失败 + 重试。
class WysErrorRetryView extends StatelessWidget {
  const WysErrorRetryView({super.key, this.message = '加载失败', this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
