import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_pay/membership/controller/membership_renew_controller.dart';
import 'package:module_pay/membership/mock/membership_mock_data.dart';
import 'package:module_pay/membership/model/membership_models.dart';
import 'package:module_pay/membership/theme/membership_theme.dart';
import 'package:module_pay/membership/membership_assets.dart';

class MembershipFeatureSection extends StatelessWidget {
  const MembershipFeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<MembershipRenewController>(
      builder: (controller) {
        final tier = controller.selectedTier.value;
        final palette = MembershipPalette.of(tier);

        if (tier == MembershipTier.aiSvip) {
          return _AiFeatureSection(palette: palette);
        }
        return _SvipFeatureSection(palette: palette);
      },
    );
  }
}

class _SvipFeatureSection extends StatelessWidget {
  const _SvipFeatureSection({required this.palette});

  final MembershipPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '畅享6W+会员内容 系统进阶',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MembershipPalette.titleBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '精选全球IP 孩子主动要学',
            style: TextStyle(
              fontSize: 14,
              color: MembershipPalette.textGray,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              MembershipAssets.illustrationSvip,
              package: MembershipAssets.package,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiFeatureSection extends StatelessWidget {
  const _AiFeatureSection({required this.palette});

  final MembershipPalette palette;

  @override
  Widget build(BuildContext context) {
    final items = MembershipMockData.aiFeatures;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'AI同步练 校内好提分',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: MembershipPalette.titleBlack,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI SVIP 专享',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palette.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
