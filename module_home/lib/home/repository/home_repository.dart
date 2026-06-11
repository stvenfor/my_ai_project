import 'package:module_home/home/api/home_api.dart';
import 'package:module_home/home/model/banner_model.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';

class HomeRepository {
  HomeRepository({HomeApi? api}) : _api = api ?? HomeApi();

  final HomeApi _api;

  Future<List<BannerModel>> loadBanners() => _api.fetchBanners();

  Future<HomeDashboardData> loadDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const HomeDashboardData(
      storeName: '[4S]北京沃德龙鼎吉利',
      features: [
        HomeFeatureItem(label: '销售顾问', emoji: '🚗'),
        HomeFeatureItem(label: '生活服务', emoji: '🛎️'),
        HomeFeatureItem(label: '二手车', emoji: '🔄'),
        HomeFeatureItem(label: '新车关注', emoji: '⭐'),
        HomeFeatureItem(label: '客户管理', emoji: '👥'),
        HomeFeatureItem(label: '订单中心', emoji: '📋'),
        HomeFeatureItem(label: '数据分析', emoji: '📊'),
        HomeFeatureItem(label: '直播带货', emoji: '📹'),
        HomeFeatureItem(label: '营销活动', emoji: '🎯'),
        HomeFeatureItem(label: '更多', emoji: '⋯'),
      ],
      quickActions: [
        HomeQuickAction(
          title: '新伙伴待确认',
          subtitle: '3 位新成员等待审核',
          actionLabel: '去处理',
          emoji: '👤',
        ),
        HomeQuickAction(
          title: '待跟进客户',
          subtitle: '今日 5 位意向客户',
          actionLabel: '去查看',
          emoji: '📞',
        ),
        HomeQuickAction(
          title: '订单待审核',
          subtitle: '2 笔新车订单',
          actionLabel: '去处理',
          emoji: '📝',
        ),
        HomeQuickAction(
          title: '售后预约',
          subtitle: '4 位客户今日到店',
          actionLabel: '去查看',
          emoji: '🔧',
        ),
      ],
      metricsToday: [
        HomeMetric(value: '99', label: '意向客户'),
        HomeMetric(value: '2', label: '新车订单'),
        HomeMetric(value: '999.8', label: '成交额(万)'),
        HomeMetric(value: '15', label: '试驾预约'),
      ],
      metricsYesterday: [
        HomeMetric(value: '86', label: '意向客户'),
        HomeMetric(value: '1', label: '新车订单'),
        HomeMetric(value: '520.0', label: '成交额(万)'),
        HomeMetric(value: '12', label: '试驾预约'),
      ],
      metricsMonth: [
        HomeMetric(value: '1280', label: '意向客户'),
        HomeMetric(value: '45', label: '新车订单'),
        HomeMetric(value: '8600.5', label: '成交额(万)'),
        HomeMetric(value: '320', label: '试驾预约'),
      ],
      metricDetails: [
        HomeMetricDetail(value: '8', label: '待交车', actionLabel: '详情 >'),
        HomeMetricDetail(value: '3', label: '待回访', actionLabel: '详情 >'),
        HomeMetricDetail(value: '12', label: '待跟进', actionLabel: '详情 >'),
      ],
      services: [
        HomeServiceItem(label: '朋友圈', emoji: '💬', badge: '热门'),
        HomeServiceItem(label: '视频号', emoji: '🎬'),
        HomeServiceItem(label: '直播', emoji: '📺', badge: '新品'),
        HomeServiceItem(label: '素材库', emoji: '📁'),
        HomeServiceItem(label: '话术库', emoji: '💡'),
        HomeServiceItem(label: '培训', emoji: '📚'),
        HomeServiceItem(label: '竞品分析', emoji: '🔍'),
        HomeServiceItem(label: '更多', emoji: '⋯'),
      ],
      contacts: [
        HomeContactItem(
          title: '李大仁',
          subtitle: '专属客户顾问 · 金牌销售',
          emoji: '👨‍💼',
          isAvatar: true,
        ),
        HomeContactItem(
          title: 'AI在线咨询',
          subtitle: '7×24 小时智能客服',
          emoji: '🤖',
          trailingType: 'chat',
        ),
        HomeContactItem(
          title: '400 售后热线',
          subtitle: '工作日 9:00-18:00',
          emoji: '📞',
          trailingType: 'phone',
        ),
      ],
      news: [
        HomeNewsItem(
          title: '2024年新能源汽车市场趋势分析报告发布',
          source: '汽车之家行业频道',
          date: '2024.05.11',
        ),
        HomeNewsItem(
          title: '吉利星越L新款上市，配置全面升级',
          source: '汽车之家',
          date: '2024.05.10',
        ),
        HomeNewsItem(
          title: '经销商数字化转型白皮书：从流量到留量',
          source: 'i车商资讯',
          date: '2024.05.09',
        ),
      ],
    );
  }
}

