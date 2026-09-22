import 'package:module_home/home/api/home_todo_api.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/model/home_todo_models.dart';

class HomeRepository {
  HomeRepository({HomeTodoApi? todoApi}) : _todoApi = todoApi ?? HomeTodoApi();

  final HomeTodoApi _todoApi;

  Future<HomeDashboardData> loadDashboard() async {
    final todoCards = await _loadTodoCards();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return HomeDashboardData(
      storeName: '[4S]北京沃德龙鼎吉利',
      features: const [
        HomeFeatureItem(label: 'H5 调试', imageUrl: 'https://picsum.photos/seed/sales/200/200'),
        HomeFeatureItem(label: '生活服务', imageUrl: 'https://picsum.photos/seed/life/200/200'),
        HomeFeatureItem(label: '二手车', imageUrl: 'https://picsum.photos/seed/usedcar/200/200'),
        HomeFeatureItem(label: '新车关注', imageUrl: 'https://picsum.photos/seed/newcar/200/200'),
        HomeFeatureItem(label: 'AI小石头', imageUrl: 'https://picsum.photos/seed/customer/200/200'),
        HomeFeatureItem(label: 'Club', imageUrl: 'https://picsum.photos/seed/order/200/200'),
        HomeFeatureItem(label: '数据分析', imageUrl: 'https://picsum.photos/seed/data/200/200'),
        HomeFeatureItem(label: '直播带货', imageUrl: 'https://picsum.photos/seed/live/200/200'),
        HomeFeatureItem(label: '营销活动', imageUrl: 'https://picsum.photos/seed/market/200/200'),
        HomeFeatureItem(label: '更多', imageUrl: 'https://picsum.photos/seed/more/200/200'),
      ],
      todoCards: todoCards,
      metricsToday: const [
        HomeMetric(value: '99', label: '意向客户'),
        HomeMetric(value: '2', label: '新车订单'),
        HomeMetric(value: '999.8', label: '成交额(万)'),
        HomeMetric(value: '15', label: '试驾预约'),
      ],
      metricsYesterday: const [
        HomeMetric(value: '86', label: '意向客户'),
        HomeMetric(value: '1', label: '新车订单'),
        HomeMetric(value: '520.0', label: '成交额(万)'),
        HomeMetric(value: '12', label: '试驾预约'),
      ],
      metricsMonth: const [
        HomeMetric(value: '1280', label: '意向客户'),
        HomeMetric(value: '45', label: '新车订单'),
        HomeMetric(value: '8600.5', label: '成交额(万)'),
        HomeMetric(value: '320', label: '试驾预约'),
      ],
      metricDetails: const [
        HomeMetricDetail(value: '8', label: '待交车', actionLabel: '详情 >'),
        HomeMetricDetail(value: '3', label: '待回访', actionLabel: '详情 >'),
        HomeMetricDetail(value: '12', label: '待跟进', actionLabel: '详情 >'),
      ],
      services: const [
        HomeServiceItem(label: '朋友圈', imageUrl: 'https://picsum.photos/seed/moment/200/200', badge: '热门'),
        HomeServiceItem(label: '视频号', imageUrl: 'https://picsum.photos/seed/video/200/200'),
        HomeServiceItem(label: '直播', imageUrl: 'https://picsum.photos/seed/broadcast/200/200', badge: '新品'),
        HomeServiceItem(label: '素材库', imageUrl: 'https://picsum.photos/seed/material/200/200'),
        HomeServiceItem(label: '话术库', imageUrl: 'https://picsum.photos/seed/script/200/200'),
        HomeServiceItem(label: '培训', imageUrl: 'https://picsum.photos/seed/training/200/200'),
        HomeServiceItem(label: '竞品分析', imageUrl: 'https://picsum.photos/seed/compete/200/200'),
        HomeServiceItem(label: '更多', imageUrl: 'https://picsum.photos/seed/extramore/200/200'),
      ],
      contacts: const [
        HomeContactItem(
          title: '销售顾问小王',
          subtitle: '在线 · 专属顾问',
          imageUrl: 'https://picsum.photos/seed/avatar1/200/200',
          isAvatar: true,
          trailingType: 'chat',
        ),
        HomeContactItem(
          title: '售后服务热线',
          subtitle: '400-800-8888',
          emoji: '📞',
          trailingType: 'phone',
        ),
      ],
      news: const [
        HomeNewsItem(
          title: '吉利银河 E8 获年度车型奖',
          source: '汽车之家',
          date: '09-20',
          imageUrl: 'https://picsum.photos/seed/news1/200/200',
        ),
      ],
    );
  }

  Future<List<HomeTodoCard>> _loadTodoCards() async {
    try {
      return await _todoApi.fetchTodoCards();
    } catch (_) {
      return const [];
    }
  }
}
