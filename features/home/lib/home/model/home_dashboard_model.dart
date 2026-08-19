class HomeFeatureItem {
  const HomeFeatureItem({required this.label, this.emoji, this.imageUrl});

  final String label;
  final String? emoji;
  final String? imageUrl;
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.emoji,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final String? emoji;
  final String? imageUrl;
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
    this.emoji,
    this.imageUrl,
    this.badge,
  });

  final String label;
  final String? emoji;
  final String? imageUrl;
  final String? badge;
}

class HomeContactItem {
  const HomeContactItem({
    required this.title,
    required this.subtitle,
    this.emoji,
    this.imageUrl,
    this.isAvatar = false,
    this.trailingType,
  });

  final String title;
  final String subtitle;
  final String? emoji;
  final String? imageUrl;
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
