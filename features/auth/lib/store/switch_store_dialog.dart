import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/store/store_option.dart';
import 'package:module_utils/module_utils.dart';

class SwitchStoreDialog extends StatelessWidget {
  const SwitchStoreDialog({
    super.key,
    required this.selectedId,
    required this.stores,
  });

  final String selectedId;
  final List<StoreOption> stores;

  static Future<String?> show({
    required String selectedId,
    required List<StoreOption> stores,
  }) {
    return Get.dialog<String>(
      SwitchStoreDialog(selectedId: selectedId, stores: stores),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '切换店铺',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  stores.isEmpty ? '暂无可切换的店铺' : '可切换多个店铺查看数据',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
                if (stores.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  for (final store in stores) ...[
                    _StoreOptionTile(
                      store: store,
                      selected: store.id == selectedId,
                      onTap: () => Get.back<String>(result: store.id),
                    ),
                    if (store != stores.last) SizedBox(height: 12.h),
                  ],
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.25),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 20.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreOptionTile extends StatelessWidget {
  const _StoreOptionTile({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final StoreOption store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1B82D2);
    const titleBlack = Color(0xFF1A1A1A);
    const borderGray = Color(0xFFE5E5E5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: selected ? primaryBlue : borderGray,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          store.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: selected ? primaryBlue : titleBlack,
          ),
        ),
      ),
    );
  }
}
