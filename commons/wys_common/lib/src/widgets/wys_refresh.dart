import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

/// 列表下拉刷新 / 上拉加载封装（基于 easy_refresh）。
class WysRefresh extends StatelessWidget {
  const WysRefresh({
    super.key,
    required this.child,
    this.onRefresh,
    this.onLoad,
    this.controller,
  });

  final Widget child;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoad;
  final EasyRefreshController? controller;



  @override
  Widget build(BuildContext context) {
    EasyRefresh.defaultHeaderBuilder = () => const ClassicHeader(
      dragText: '下拉可以刷新',
      armedText: '释放立即刷新',
      readyText: '正在刷新...',
      processingText: "刷新中",
      processedText: '刷新完成',
      noMoreText: '已经全部加载完毕',
      failedText: '刷新失败',
      messageText: '上次更新 %T',
      clamping: true,
    );
    EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
      dragText: '上拉可以加载',
      armedText: '释放立即加载',
      readyText: '正在加载...',
      processingText: '正在加载...',
      processedText: '加载完成',
      noMoreText: '已经全部加载完毕',
      failedText: '加载失败',
      messageText: '上次更新 %T',
    );
    return EasyRefresh(
      controller: controller,
      onRefresh: onRefresh,
      onLoad: onLoad,
      child: child,
    );
  }
}