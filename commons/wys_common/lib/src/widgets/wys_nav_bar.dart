import 'package:flutter/material.dart';

/// 通用顶栏：左返回 / 中标题或自定义 / 右操作。
///
/// 左右两侧固定等宽占位，保证中间 [title] 或 [center] 始终水平居中，
/// 避免 Stack 叠放时标题与返回按钮挤在一起。
class WysNavBar extends StatelessWidget {
  const WysNavBar({
    super.key,
    this.title,
    this.center,
    this.trailing,
    this.leading,
    this.showBackButton = true,
    this.onBack,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.toolbarHeight = 44,
    this.leadingWidth = 48,
    this.trailingWidth = 48,
    this.titleStyle,
    this.includeTopSafeArea = true,
    this.showBottomDivider = false,
  }) : assert(
         title == null || center == null,
         'Provide either title or center, not both.',
       );

  /// 居中标题文案；与 [center] 二选一。
  final String? title;

  /// 居中自定义组件；与 [title] 二选一。
  final Widget? center;

  /// 右侧自定义组件。
  final Widget? trailing;

  /// 左侧自定义组件；若提供则覆盖 [showBackButton] 默认返回按钮。
  final Widget? leading;

  /// 是否显示左侧返回按钮；[leading] 非空时忽略。
  final bool showBackButton;

  /// 返回按钮回调；默认 [Navigator.maybePop]。
  final VoidCallback? onBack;

  final Color backgroundColor;
  final Color foregroundColor;
  final double toolbarHeight;
  final double leadingWidth;
  final double trailingWidth;
  final TextStyle? titleStyle;

  /// 是否包含状态栏高度（用于 [Column] 内自定义顶栏）。
  final bool includeTopSafeArea;

  final bool showBottomDivider;

  /// 含状态栏在内的总高度，便于外层 [Column] 计算布局。
  static double totalHeight(
    BuildContext context, {
    double toolbarHeight = 44,
    bool includeTopSafeArea = true,
  }) {
    final top = includeTopSafeArea ? MediaQuery.paddingOf(context).top : 0.0;
    return top + toolbarHeight;
  }

  TextStyle _resolveTitleStyle(BuildContext context) {
    return titleStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ) ??
        TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showBackButton) return null;
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new, size: 20, color: foregroundColor),
      onPressed: onBack ?? () => Navigator.maybePop(context),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildCenter(BuildContext context) {
    if (center != null) return center!;
    if (title != null) {
      return Text(
        title!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: _resolveTitleStyle(context),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final topInset =
        includeTopSafeArea ? MediaQuery.paddingOf(context).top : 0.0;
    final leadingWidget = _buildLeading(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBottomDivider
            ? Border(
                bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: toolbarHeight,
          child: Row(
            children: [
              SizedBox(
                width: leadingWidth,
                child: leadingWidget == null
                    ? null
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: leadingWidget,
                      ),
              ),
              Expanded(child: Center(child: _buildCenter(context))),
              SizedBox(
                width: trailingWidth,
                child: trailing == null
                    ? null
                    : Align(
                        alignment: Alignment.centerRight,
                        child: trailing!,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
