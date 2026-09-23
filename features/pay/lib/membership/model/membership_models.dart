import 'package:flutter/material.dart';

enum MembershipTier { svip, aiSvip }

enum PaymentMethodType { wechat, alipay, balance, huawei, apple }

class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.tier,
    required this.title,
    required this.price,
    required this.originalPrice,
    this.months = 1,
    this.huaweiProductId = '',
    this.appleProductId = '',
    this.badge,
    this.dailyHint,
    this.showRedPacket = false,
    this.autoRenew = false,
  });

  final String id;
  final MembershipTier tier;
  final String title;
  final double price;
  final double originalPrice;
  final int months;
  final String huaweiProductId;
  final String appleProductId;
  final String? badge;
  final String? dailyHint;
  final bool showRedPacket;
  final bool autoRenew;

  factory MembershipPlan.fromCatalogJson(Map<String, dynamic> json) {
    final tierRaw = '${json['tier'] ?? ''}';
    final tier =
        tierRaw == 'ai_svip' ? MembershipTier.aiSvip : MembershipTier.svip;
    final fen = (json['price_fen'] as num?)?.toInt() ?? 0;
    final priceStr = '${json['price'] ?? ''}';
    final price = double.tryParse(priceStr) ?? (fen / 100.0);
    return MembershipPlan(
      id: '${json['plan_id'] ?? ''}',
      tier: tier,
      title: '${json['title'] ?? ''}',
      price: price,
      originalPrice: price,
      months: (json['months'] as num?)?.toInt() ?? 1,
      huaweiProductId: '${json['huawei_product_id'] ?? ''}',
      appleProductId: '${json['apple_product_id'] ?? ''}',
      autoRenew: json['auto_renew_eligible'] == true,
    );
  }
}

class MembershipPromoBanner {
  const MembershipPromoBanner({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.countdownLabel,
  });

  final MembershipTier tier;
  final String title;
  final String subtitle;
  final String countdownLabel;
}

class MembershipFeatureItem {
  const MembershipFeatureItem({
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
}

class MembershipUserProfile {
  const MembershipUserProfile({
    required this.displayName,
    required this.levelBadge,
    required this.statusText,
    required this.avatarUrl,
  });

  final String displayName;
  final String levelBadge;
  final String statusText;
  final String avatarUrl;
}

class MembershipEntitlementView {
  const MembershipEntitlementView({
    required this.tier,
    required this.active,
    required this.cta,
    this.expiresAt = '',
    this.sourceChannel = '',
  });

  final MembershipTier tier;
  final bool active;
  final String cta;
  final String expiresAt;
  final String sourceChannel;
}
