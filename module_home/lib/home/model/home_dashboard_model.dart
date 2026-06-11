class HomeFeatureItem {
  const HomeFeatureItem({required this.label, required this.emoji});

  final String label;
  final String emoji;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.emoji,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final String emoji;
}

class HomeMetric {
  const HomeMetric({required this.value, required this.label});

  final String value;
  final String label;
}

class HomeMetricDetail {
  const HomeMetricDetail({
    required this.value,
    required this.label,
    required this.actionLabel,
  });

  final String value;
  final String label;
  final String actionLabel;
}

class HomeServiceItem {
  const HomeServiceItem({
    required this.label,
    required this.emoji,
    this.badge,
  });

  final String label;
  final String emoji;
  final String? badge;
}

class HomeContactItem {
  const HomeContactItem({
    required this.title,
    required this.subtitle,
    this.emoji,
    this.isAvatar = false,
    this.trailingType,
  });

  final String title;
  final String subtitle;
  final String? emoji;
  final bool isAvatar;
  /// chat | phone | chevron
  final String? trailingType;
}

class HomeNewsItem {
  const HomeNewsItem({
    required this.title,
    required this.source,
    required this.date,
    this.imageUrl,
  });

  final String title;
  final String source;
  final String date;
  final String? imageUrl;
}

class HomeDashboardData {
  const HomeDashboardData({
    required this.features,
    required this.quickActions,
    required this.metricsToday,
    required this.metricsYesterday,
    required this.metricsMonth,
    required this.metricDetails,
    required this.services,
    required this.contacts,
    required this.news,
    required this.storeName,
  });

  final List<HomeFeatureItem> features;
  final List<HomeQuickAction> quickActions;
  final List<HomeMetric> metricsToday;
  final List<HomeMetric> metricsYesterday;
  final List<HomeMetric> metricsMonth;
  final List<HomeMetricDetail> metricDetails;
  final List<HomeServiceItem> services;
  final List<HomeContactItem> contacts;
  final List<HomeNewsItem> news;
  final String storeName;
}
