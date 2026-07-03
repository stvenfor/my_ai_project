import 'package:flutter/material.dart';
import 'package:module_home/home/model/all_services_model.dart';
import 'package:module_home/home/theme/all_services_theme.dart';
import 'package:module_utils/module_utils.dart';

class AllServicesSectionWidget extends StatelessWidget {
  const AllServicesSectionWidget({
    super.key,
    required this.section,
    this.isEditing = false,
    this.isFavoriteSection = false,
    this.favoriteIds = const {},
    this.canRemoveFavorite = true,
    this.canAddFavorite = true,
    this.onEditTap,
    this.onRemoveFavorite,
    this.onAddFavorite,
    this.onItemTap,
  });

  final AllServiceSection section;
  final bool isEditing;
  final bool isFavoriteSection;
  final Set<String> favoriteIds;
  final bool canRemoveFavorite;
  final bool canAddFavorite;
  final VoidCallback? onEditTap;
  final ValueChanged<AllServiceItem>? onRemoveFavorite;
  final ValueChanged<AllServiceItem>? onAddFavorite;
  final ValueChanged<AllServiceItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 0,
              childAspectRatio: 0.72,
            ),
            itemCount: section.items.length,
            itemBuilder: (context, index) {
              final item = section.items[index];
              return _ServiceGridCell(
                item: item,
                isEditing: isEditing,
                isFavoriteSection: isFavoriteSection,
                isInFavorites: favoriteIds.contains(item.id),
                canRemoveFavorite: canRemoveFavorite,
                canAddFavorite: canAddFavorite,
                onTap: () => onItemTap?.call(item),
                onRemove: () => onRemoveFavorite?.call(item),
                onAdd: () => onAddFavorite?.call(item),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (section.showEditButton) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AllServicesTheme.titleBlack,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              section.subtitle ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: AllServicesTheme.subtitleGray,
              ),
            ),
          ),
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: AllServicesTheme.editBorderBlue),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                isEditing ? '完成' : '编辑',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AllServicesTheme.editBorderBlue,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      section.title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AllServicesTheme.titleBlack,
      ),
    );
  }
}

class _ServiceGridCell extends StatelessWidget {
  const _ServiceGridCell({
    required this.item,
    required this.isEditing,
    required this.isFavoriteSection,
    required this.isInFavorites,
    this.canRemoveFavorite = true,
    this.canAddFavorite = true,
    this.onTap,
    this.onRemove,
    this.onAdd,
  });

  final AllServiceItem item;
  final bool isEditing;
  final bool isFavoriteSection;
  final bool isInFavorites;
  final bool canRemoveFavorite;
  final bool canAddFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final showRemove = isEditing && isFavoriteSection && canRemoveFavorite;
    final showAdd =
        isEditing && !isFavoriteSection && !isInFavorites && canAddFavorite;
    final dimmed = isEditing && !isFavoriteSection && isInFavorites;

    return GestureDetector(
      onTap: isEditing ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: dimmed ? 0.4 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48.w,
              height: 48.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      AllServicesAssets.path(item.assetName),
                      package: AllServicesAssets.package,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  if (showRemove)
                    Positioned(
                      top: -4.h,
                      right: -4.w,
                      child: _ActionBadge(
                        icon: Icons.close,
                        iconSize: 10.sp,
                        iconColor: AllServicesTheme.labelGray,
                        backgroundColor: Colors.white,
                        borderColor: const Color(0xFFE0E0E0),
                        onTap: onRemove,
                      ),
                    ),
                  if (showAdd)
                    Positioned(
                      top: -4.h,
                      right: -4.w,
                      child: _ActionBadge(
                        icon: Icons.add,
                        iconSize: 12.sp,
                        iconColor: Colors.white,
                        backgroundColor: AllServicesTheme.editBorderBlue,
                        borderColor: AllServicesTheme.editBorderBlue,
                        onTap: onAdd,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: AllServicesTheme.labelGray,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
