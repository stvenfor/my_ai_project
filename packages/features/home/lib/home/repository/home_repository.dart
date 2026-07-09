import 'package:module_home/home/model/home_dashboard_model.dart';

class HomeRepository {
  HomeRepository();

  Future<HomeDashboardData> loadDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const HomeDashboardData(
      storeName: '[4S]北京沃德龙鼎吉利',
      features: [
        HomeFeatureItem(label: '销售顾问', imageUrl: 'https://picsum.photos/seed/sales/200/200'),
        HomeFeatureItem(label: '生活服务', imageUrl: 'https://picsum.photos/seed/life/200/200'),
        HomeFeatureItem(label: '二手车', imageUrl: 'https://picsum.photos/seed/usedcar/200/200'),
        HomeFeatureItem(label: '新车关注', imageUrl: 'https://picsum.photos/seed/newcar/200/200'),
        HomeFeatureItem(label: '客户管理', imageUrl: 'https://picsum.photos/seed/customer/200/200'),
        HomeFeatureItem(label: '订单中心', imageUrl: 'https://picsum.photos/seed/order/200/200'),
        HomeFeatureItem(label: '数据分析', imageUrl: 'https://picsum.photos/seed/data/200/200'),
        HomeFeatureItem(label: '直播带货', imageUrl: 'https://picsum.photos/seed/live/200/200'),
        HomeFeatureItem(label: '营销活动', imageUrl: 'https://picsum.photos/seed/market/200/200'),
        HomeFeatureItem(label: '更多', imageUrl: 'https://picsum.photos/seed/more/200/200'),
      ],
      quickActions: [
        HomeQuickAction(
          title: '新伙伴待确认',
          subtitle: '3 位新成员等待审核',
          actionLabel: '去处理',
          imageUrl: 'https://picsum.photos/seed/partner/200/200',
        ),
        HomeQuickAction(
          title: '待跟进客户',
          subtitle: '今日 5 位意向客户',
          actionLabel: '去查看',
          imageUrl: 'https://picsum.photos/seed/follow/200/200',
        ),
        HomeQuickAction(
          title: '订单待审核',
          subtitle: '2 笔新车订单',
          actionLabel: '去处理',
          imageUrl: 'https://picsum.photos/seed/review/200/200',
        ),
        HomeQuickAction(
          title: '售后预约',
          subtitle: '4 位客户今日到店',
          actionLabel: '去查看',
          imageUrl: 'https://picsum.photos/seed/service/200/200',
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
        HomeServiceItem(label: '朋友圈', imageUrl: 'https://picsum.photos/seed/moment/200/200', badge: '热门'),
        HomeServiceItem(label: '视频号', imageUrl: 'https://picsum.photos/seed/video/200/200'),
        HomeServiceItem(label: '直播', imageUrl: 'https://picsum.photos/seed/broadcast/200/200', badge: '新品'),
        HomeServiceItem(label: '素材库', imageUrl: 'https://picsum.photos/seed/material/200/200'),
        HomeServiceItem(label: '话术库', imageUrl: 'https://picsum.photos/seed/script/200/200'),
        HomeServiceItem(label: '培训', imageUrl: 'https://picsum.photos/seed/training/200/200'),
        HomeServiceItem(label: '竞品分析', imageUrl: 'https://picsum.photos/seed/compete/200/200'),
        HomeServiceItem(label: '更多', imageUrl: 'https://picsum.photos/seed/extramore/200/200'),
      ],
      contacts: [
        HomeContactItem(
          title: '李大仁',
          subtitle: '专属客户顾问 · 金牌销售',
          imageUrl: 'https://picsum.photos/seed/advisor/200/200',
          isAvatar: true,
        ),
        HomeContactItem(
          title: 'AI在线咨询',
          subtitle: '7×24 小时智能客服',
          imageUrl: 'https://picsum.photos/seed/aibot/200/200',
          trailingType: 'chat',
        ),
        HomeContactItem(
          title: '400 售后热线',
          subtitle: '工作日 9:00-18:00',
          imageUrl: 'https://picsum.photos/seed/hotline/200/200',
          trailingType: 'phone',
        ),
      ],
      news: [
        HomeNewsItem(
          title: '2024年新能源汽车市场趋势分析报告发布',
          source: '汽车之家行业频道',
          date: '2024.05.11',
          imageUrl: 'https://picsum.photos/seed/news1/400/200',
        ),
        HomeNewsItem(
          title: '吉利星越L新款上市，配置全面升级',
          source: '汽车之家',
          date: '2024.05.10',
          imageUrl: 'https://picsum.photos/seed/news2/400/200',
        ),
        HomeNewsItem(
          title: '经销商数字化转型白皮书：从流量到留量',
          source: 'i车商资讯',
          date: '2024.05.09',
          imageUrl: 'https://picsum.photos/seed/news3/400/200',
        ),
      ],
    );
  }
}
