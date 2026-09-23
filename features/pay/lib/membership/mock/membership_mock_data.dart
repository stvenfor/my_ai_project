import 'package:module_pay/membership/model/membership_models.dart';

abstract final class MembershipMockData {
  static const userProfile = MembershipUserProfile(
    displayName: '小趣友腻腻',
    levelBadge: 'V3',
    statusText: '您的会员身份已过期',
    avatarUrl: 'https://picsum.photos/seed/membership_child/120/120',
  );

  static const deductionAmount = 0.0;
  static const beanBalance = 0.0;
  static const promoCountdown = '2天 22:59:59';
  static const redPacketCountdown = '02:32:59';

  /// 与 Go `entity.MembershipCatalog` 占位价对齐（元）。
  static const svipPlans = <MembershipPlan>[
    MembershipPlan(
      id: 'svip_1m',
      tier: MembershipTier.svip,
      title: '1个月',
      price: 30,
      originalPrice: 48,
      months: 1,
      huaweiProductId: 'wys_svip_1m',
      appleProductId: 'wys_svip_1m',
      badge: '开通尝鲜',
    ),
    MembershipPlan(
      id: 'svip_6m',
      tier: MembershipTier.svip,
      title: '6个月',
      price: 150,
      originalPrice: 288,
      months: 6,
      huaweiProductId: 'wys_svip_6m',
      appleProductId: 'wys_svip_6m',
      dailyHint: '每日仅需0.83元',
    ),
    MembershipPlan(
      id: 'svip_12m',
      tier: MembershipTier.svip,
      title: '1年',
      price: 280,
      originalPrice: 488,
      months: 12,
      huaweiProductId: 'wys_svip_12m',
      appleProductId: 'wys_svip_12m',
      badge: '最划算',
      showRedPacket: true,
    ),
  ];

  static const aiSvipPlans = <MembershipPlan>[
    MembershipPlan(
      id: 'ai_svip_1m',
      tier: MembershipTier.aiSvip,
      title: '1个月',
      price: 48,
      originalPrice: 68,
      months: 1,
      huaweiProductId: 'wys_ai_svip_1m',
      appleProductId: 'wys_ai_svip_1m',
      badge: '开通尝鲜',
    ),
    MembershipPlan(
      id: 'ai_svip_6m',
      tier: MembershipTier.aiSvip,
      title: '6个月',
      price: 240,
      originalPrice: 408,
      months: 6,
      huaweiProductId: 'wys_ai_svip_6m',
      appleProductId: 'wys_ai_svip_6m',
      dailyHint: '每日仅需1.33元',
    ),
    MembershipPlan(
      id: 'ai_svip_12m',
      tier: MembershipTier.aiSvip,
      title: '1年',
      price: 398,
      originalPrice: 688,
      months: 12,
      huaweiProductId: 'wys_ai_svip_12m',
      appleProductId: 'wys_ai_svip_12m',
      badge: '最划算',
      showRedPacket: true,
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
    title: 'AI 创作季',
    subtitle: '加赠 AI 音色试用包',
    countdownLabel: promoCountdown,
  );

  static List<MembershipPlan> plansFor(MembershipTier tier) =>
      tier == MembershipTier.svip ? svipPlans : aiSvipPlans;

  static MembershipPromoBanner promoFor(MembershipTier tier) =>
      tier == MembershipTier.svip ? svipPromo : aiSvipPromo;
}
