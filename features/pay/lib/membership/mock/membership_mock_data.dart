import 'package:flutter/material.dart';
import 'package:module_pay/membership/model/membership_models.dart';

abstract final class MembershipMockData {
  static const userProfile = MembershipUserProfile(
    displayName: '小趣友腻腻',
    levelBadge: 'V3',
    statusText: '您的会员身份已过期',
    avatarUrl: 'https://picsum.photos/seed/membership_child/120/120',
  );

  static const deductionAmount = 188.0;
  static const beanBalance = 88.88;
  static const promoCountdown = '2天 22:59:59';
  static const redPacketCountdown = '02:32:59';

  static const svipPlans = <MembershipPlan>[
    MembershipPlan(
      id: 'svip_12m',
      tier: MembershipTier.svip,
      title: '12个月',
      price: 380,
      originalPrice: 488,
      badge: '开学尝鲜价',
      showRedPacket: true,
    ),
    MembershipPlan(
      id: 'svip_24m',
      tier: MembershipTier.svip,
      title: '24个月',
      price: 488,
      originalPrice: 888,
      badge: '活动利益点',
      dailyHint: '每日仅需0.66元',
    ),
    MembershipPlan(
      id: 'svip_year_auto',
      tier: MembershipTier.svip,
      title: '连续包年',
      price: 288,
      originalPrice: 488,
      dailyHint: '每日仅需0.78元',
    ),
  ];

  static const aiSvipPlans = <MembershipPlan>[
    MembershipPlan(
      id: 'ai_12m',
      tier: MembershipTier.aiSvip,
      title: '12个月',
      price: 488,
      originalPrice: 688,
      badge: '开学尝鲜价',
      showRedPacket: true,
    ),
    MembershipPlan(
      id: 'ai_24m',
      tier: MembershipTier.aiSvip,
      title: '24个月',
      price: 688,
      originalPrice: 1288,
      badge: '活动利益点',
      dailyHint: '每日仅需0.94元',
    ),
    MembershipPlan(
      id: 'ai_year_auto',
      tier: MembershipTier.aiSvip,
      title: '连续包年',
      price: 398,
      originalPrice: 688,
      dailyHint: '每日仅需1.09元',
    ),
  ];

  static const svipPromo = MembershipPromoBanner(
    tier: MembershipTier.svip,
    title: '春日踏青礼',
    subtitle: '加赠限定勋章、装扮套装',
    countdownLabel: promoCountdown,
  );

  static const aiSvipPromo = MembershipPromoBanner(
    tier: MembershipTier.aiSvip,
    title: '寒假趣超车',
    subtitle: '赠新春礼包',
    countdownLabel: promoCountdown,
  );

  static const aiFeatures = <MembershipFeatureItem>[
    MembershipFeatureItem(
      title: '背单词',
      subtitle: '听音辨义 拼写无忧',
      gradient: [Color(0xFF7ED957), Color(0xFF52C41A)],
    ),
    MembershipFeatureItem(
      title: '读课文',
      subtitle: '智能打分 纠正发音',
      gradient: [Color(0xFFFFB347), Color(0xFFFF8A34)],
    ),
    MembershipFeatureItem(
      title: 'AI私教',
      subtitle: '告别死记 活学活用',
      gradient: [Color(0xFF6CB6FF), Color(0xFF3D8BFF)],
    ),
    MembershipFeatureItem(
      title: '刷真题',
      subtitle: '考点精粹 高效提分',
      gradient: [Color(0xFFFF7B7B), Color(0xFFFF4D4F)],
    ),
  ];

  static List<MembershipPlan> plansFor(MembershipTier tier) {
    return switch (tier) {
      MembershipTier.svip => svipPlans,
      MembershipTier.aiSvip => aiSvipPlans,
    };
  }

  static MembershipPromoBanner promoFor(MembershipTier tier) {
    return switch (tier) {
      MembershipTier.svip => svipPromo,
      MembershipTier.aiSvip => aiSvipPromo,
    };
  }
}
