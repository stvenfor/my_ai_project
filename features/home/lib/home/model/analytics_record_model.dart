import 'package:module_http/grpc/generated/analytics/v1/analytics.pb.dart';

/// 数据分析列表/详情展示模型。
class AnalyticsRecordModel {
  const AnalyticsRecordModel({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.subCategory,
    required this.status,
    required this.priority,
    required this.region,
    required this.channel,
    required this.ownerName,
    required this.ownerTeam,
    required this.sourceSystem,
    required this.metricPv,
    required this.metricUv,
    required this.metricClick,
    required this.metricConvert,
    required this.metricRevenue,
    required this.metricCost,
    required this.metricRoi,
    required this.metricBounceRate,
    required this.metricAvgDurationSec,
    required this.scoreQuality,
    required this.scoreRisk,
    required this.tagPrimary,
    required this.tagSecondary,
    required this.flagFeatured,
    required this.flagAnomaly,
    required this.notes,
    required this.observedAt,
    required this.windowStart,
    required this.windowEnd,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String code;
  final String title;
  final String subtitle;
  final String category;
  final String subCategory;
  final String status;
  final int priority;
  final String region;
  final String channel;
  final String ownerName;
  final String ownerTeam;
  final String sourceSystem;
  final int metricPv;
  final int metricUv;
  final int metricClick;
  final int metricConvert;
  final double metricRevenue;
  final double metricCost;
  final double metricRoi;
  final double metricBounceRate;
  final int metricAvgDurationSec;
  final double scoreQuality;
  final double scoreRisk;
  final String tagPrimary;
  final String tagSecondary;
  final bool flagFeatured;
  final bool flagAnomaly;
  final String notes;
  final int observedAt;
  final int windowStart;
  final int windowEnd;
  final int publishedAt;
  final int createdAt;
  final int updatedAt;

  factory AnalyticsRecordModel.fromProto(AnalyticsRecord item) {
    return AnalyticsRecordModel(
      id: item.id.toInt(),
      code: item.code,
      title: item.title,
      subtitle: item.subtitle,
      category: item.category,
      subCategory: item.subCategory,
      status: item.status,
      priority: item.priority,
      region: item.region,
      channel: item.channel,
      ownerName: item.ownerName,
      ownerTeam: item.ownerTeam,
      sourceSystem: item.sourceSystem,
      metricPv: item.metricPv.toInt(),
      metricUv: item.metricUv.toInt(),
      metricClick: item.metricClick.toInt(),
      metricConvert: item.metricConvert.toInt(),
      metricRevenue: item.metricRevenue,
      metricCost: item.metricCost,
      metricRoi: item.metricRoi,
      metricBounceRate: item.metricBounceRate,
      metricAvgDurationSec: item.metricAvgDurationSec,
      scoreQuality: item.scoreQuality,
      scoreRisk: item.scoreRisk,
      tagPrimary: item.tagPrimary,
      tagSecondary: item.tagSecondary,
      flagFeatured: item.flagFeatured,
      flagAnomaly: item.flagAnomaly,
      notes: item.notes,
      observedAt: item.observedAt.toInt(),
      windowStart: item.windowStart.toInt(),
      windowEnd: item.windowEnd.toInt(),
      publishedAt: item.publishedAt.toInt(),
      createdAt: item.createdAt.toInt(),
      updatedAt: item.updatedAt.toInt(),
    );
  }
}

class AnalyticsPageResult {
  const AnalyticsPageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<AnalyticsRecordModel> items;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total;
}

String formatAnalyticsLoadError(Object error) {
  final text = error.toString();
  if (text.contains('Unauthenticated') || text.contains('401')) {
    return '登录已失效，请重新登录';
  }
  if (text.contains('Connection refused') ||
      text.contains('Failed host lookup') ||
      text.contains('SocketException')) {
    return '无法连接数据分析服务，请确认 Go BFF gRPC :9090 已启动';
  }
  return '加载失败：$text';
}

String formatUnixSeconds(int seconds) {
  if (seconds <= 0) return '-';
  final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
      .toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
      '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
}
