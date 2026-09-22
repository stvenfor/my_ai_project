import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// 「如何拍摄小视频」说明页。
class ShortVideoHelpPage extends StatelessWidget {
  const ShortVideoHelpPage({super.key});

  static const _steps = <(IconData, String, String)>[
    (
      Icons.video_library_outlined,
      '准备素材',
      '点击发布入口，从相册选择已有视频，或用相机现场拍摄一段竖屏短片。'
    ),
    (
      Icons.crop_portrait_outlined,
      '建议竖屏',
      '优先 9:16 竖屏构图，主体居中，光线充足，时长控制在 15 秒左右更易完播。'
    ),
    (
      Icons.edit_outlined,
      '填写标题与话题',
      '选片后进入发布页：写好标题，可选关联一个社区话题，方便被发现。'
    ),
    (
      Icons.cloud_upload_outlined,
      '一键发布',
      '当前版本不会实际上传本地文件，服务端会使用默认示范片源入库；审核通过后即可在列表播放。'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      navBar: const AppNavBar(
        title: '如何拍摄小视频',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDCEEF9), Color(0xFFE8F5E9)],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_outlined,
                    size: 36.sp, color: const Color(0xFF0070F3)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '四步完成一条小视频：选片 → 写标题 → 关联话题 → 发布',
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF171717),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          for (var i = 0; i < _steps.length; i++) ...[
            _StepCard(
              index: i + 1,
              icon: _steps[i].$1,
              title: _steps[i].$2,
              body: _steps[i].$3,
            ),
            if (i < _steps.length - 1) SizedBox(height: 12.h),
          ],
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小贴士',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF171717),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '· 发布后短时为「审核中」，约 30 秒后自动通过并可播放。\n'
                  '· 长按列表卡片可删除自己的视频。\n'
                  '· 点击个人头像可更换头像，与「我的」资料同步。',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int index;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0070F3),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18.sp, color: const Color(0xFF0070F3)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF171717),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
