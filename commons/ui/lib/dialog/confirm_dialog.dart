import 'package:flutter/material.dart';
import 'package:module_common_ui/theme/vercel_tokens.dart';
import 'package:module_utils/utils/screen_util_utils.dart';

/// 双按钮确认弹框。
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.onConfirm,
    this.onCancel,
    this.showCloseButton = true,
    this.maxContentHeight = 300,
  });

  final String title;
  final Widget content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCloseButton;
  final double maxContentHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: maxContentHeight + 180.h),
            decoration: BoxDecoration(
              color: tokens.canvas,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: tokens.ink,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxContentHeight.h),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: tokens.body,
                          height: 1.6,
                        ),
                        child: content,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                              onCancel?.call();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: tokens.body,
                              side: BorderSide(color: tokens.hairline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(cancelText, style: TextStyle(fontSize: 15.sp)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                              onConfirm?.call();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: tokens.primary,
                              foregroundColor: tokens.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(confirmText, style: TextStyle(fontSize: 15.sp)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          if (showCloseButton) ...[
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
