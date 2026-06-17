import 'package:flutter/material.dart';
import 'package:module_utils/utils/screen_util_utils.dart';

/// 通用弹框组件
/// 
/// 特点：
/// - 内容区域超过300高度时自动启用滚动
/// - 支持自定义标题、内容、按钮文字和回调
/// - 支持关闭按钮显示/隐藏
class GeneralDialog extends StatelessWidget {
  const GeneralDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = '好的，我知道了',
    this.onConfirm,
    this.showCloseButton = true,
    this.maxContentHeight = 300,
  });

  /// 弹框标题
  final String title;
  
  /// 弹框内容（可以是纯文本或自定义Widget）
  final Widget content;
  
  /// 确认按钮文字
  final String confirmText;
  
  /// 确认按钮点击回调
  final VoidCallback? onConfirm;
  
  /// 是否显示关闭按钮
  final bool showCloseButton;
  
  /// 内容区域最大高度（超过此高度启用滚动）
  final double maxContentHeight;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: maxContentHeight + 180.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                // 标题
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // 内容区域（可滚动）
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxContentHeight.h),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF666666),
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          // 关闭按钮
          if (showCloseButton) ...[
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

