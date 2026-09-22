import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_mall/mall/model/mall_product_model.dart';
import 'package:module_mall/mall/theme/mall_theme.dart';

class MallProductCard extends StatelessWidget {
  const MallProductCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MallProductCardModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MallTheme.radiusMd),
        child: Ink(
          decoration: MallTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(MallTheme.radiusMd),
                ),
                child: AspectRatio(
                  aspectRatio: 1 / item.imageAspectRatio.clamp(0.7, 1.45),
                  child: ColoredBox(
                    color: MallTheme.background,
                    child: Image.network(
                      item.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: MallTheme.labelTertiary,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: MallTheme.cardTitle,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            item.priceLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MallTheme.priceText,
                          ),
                        ),
                        if (item.soldLabel != null)
                          Text(item.soldLabel!, style: MallTheme.caption),
                      ],
                    ),
                    if (item.badges.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: item.badges
                            .take(2)
                            .map(_badge)
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text) {
    final gold = text.contains('钻铂');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: gold ? MallTheme.badgeGoldBg : MallTheme.badgeRed,
        borderRadius: BorderRadius.circular(4.r),
        border: gold ? Border.all(color: MallTheme.warning.withValues(alpha: 0.35)) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: VercelTypography.fontFamily,
          color: gold ? MallTheme.badgeGoldText : Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
