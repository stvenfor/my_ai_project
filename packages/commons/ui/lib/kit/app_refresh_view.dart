import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 下拉刷新 / 上拉加载门面（唯一依赖 flutter_easyrefresh 的文件）。
class AppRefreshView extends StatelessWidget {
  const AppRefreshView({
    super.key,
    required this.onRefresh,
    required this.child,
    this.onLoad,
    this.enableLoad = false,
  });

  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoad;
  final bool enableLoad;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: MaterialHeader(),
      footer: enableLoad ? MaterialFooter() : null,
      onRefresh: onRefresh,
      onLoad: enableLoad ? onLoad : null,
      child: child,
    );
  }
}
