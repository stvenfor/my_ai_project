import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/theme/home_report_theme.dart';
import 'package:module_utils/module_utils.dart';

class HomeLearningReportPage extends StatelessWidget {
  const HomeLearningReportPage({super.key});

  static const _highlights = [
    _HighlightItem(
      emoji: '🎬',
      title: '《哈利波特》第3章',
      subtitle: '视频配音 · 刚刚发布',
      trailing: _HighlightTrailing.score('100'),
    ),
    _HighlightItem(
      emoji: '🏆',
      title: '解锁「45天」打卡勋章',
      subtitle: '里程碑达成 · 太棒了！',
      trailing: _HighlightTrailing.emoji('🎉'),
    ),
    _HighlightItem(
      emoji: '🎵',
      title: '"Wingardium Leviosa!"',
      subtitle: '满分句子 · 可播放原声',
      trailing: _HighlightTrailing.play(),
    ),
  ];

  static const _records = [
    _RecordItem(
      emoji: '🎬',
      title: '视频配音',
      subtitle: '哈利波特 第3章',
      time: '18:32',
      status: '已发布',
      statusHighlight: true,
    ),
    _RecordItem(
      emoji: '⚔️',
      title: '配音闯关',
      subtitle: 'Level 8 · 3关',
      time: '17:10',
      status: '15 min',
    ),
    _RecordItem(
      emoji: '📚',
      title: '同步练',
      subtitle: 'PEP 五年级上册 Unit 3',
      time: '16:45',
      status: '8 min',
    ),
    _RecordItem(
      emoji: '🤖',
      title: 'AI 外教',
      subtitle: '自由对话 · Tom老师',
      time: '15:20',
      status: '12 min',
    ),
    _RecordItem(
      emoji: '🎧',
      title: '听力练习',
      subtitle: '英美绕口令 · 5题',
      time: '14:00',
      status: '5 min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeReportColors.background,
      appBar: AppBar(
        backgroundColor: HomeReportColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          '学习报告',
          style: TextStyle(
            color: HomeReportColors.titleWhite,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    dotColor: HomeReportColors.dotYellow,
                    title: '今日高光',
                  ),
                  SizedBox(height: 10.h),
                  _HighlightCard(items: _highlights),
                  SizedBox(height: 20.h),
                  _SectionHeader(
                    dotColor: HomeReportColors.dotBlue,
                    title: '今日学习记录',
                  ),
                  SizedBox(height: 10.h),
                  _LearningRecordCard(items: _records),
                ],
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.paddingOf(context).bottom + 12.h,
              child: const _MembershipBanner(),
            ),
            Positioned(
              right: 16.w,
              bottom: MediaQuery.paddingOf(context).bottom + 88.h,
              child: const _ParentAssistantChip(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.dotColor,
    required this.title,
  });

  final Color dotColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            color: HomeReportColors.titleWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.items});

  final List<_HighlightItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeReportColors.highlightCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: HomeReportColors.highlightBorder, width: 1),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _HighlightRow(item: items[i]),
            if (i != items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: HomeReportColors.divider,
                indent: 16.w,
                endIndent: 16.w,
              ),
          ],
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.item});

  final _HighlightItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          _EmojiIconBox(emoji: item.emoji, gradient: true),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HomeReportColors.titleWhite,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HomeReportColors.subtitleGrey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          item.trailing.build(),
        ],
      ),
    );
  }
}

class _LearningRecordCard extends StatelessWidget {
  const _LearningRecordCard({required this.items});

  final List<_RecordItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: HomeReportColors.recordCard,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          for (final item in items) ...[
            _RecordRow(item: item),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.item});

  final _RecordItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: HomeReportColors.recordItem,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _EmojiIconBox(emoji: item.emoji, gradient: false),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: HomeReportColors.titleWhite,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HomeReportColors.subtitleGrey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.time,
                style: TextStyle(
                  color: HomeReportColors.metaGrey,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.status,
                style: TextStyle(
                  color: item.statusHighlight
                      ? HomeReportColors.orange
                      : HomeReportColors.metaGrey,
                  fontSize: 12.sp,
                  fontWeight: item.statusHighlight
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiIconBox extends StatelessWidget {
  const _EmojiIconBox({
    required this.emoji,
    required this.gradient,
  });

  final String emoji;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HomeReportColors.iconTealLight,
                  HomeReportColors.iconTeal,
                ],
              )
            : null,
        color: gradient ? null : HomeReportColors.recordItem,
        borderRadius: BorderRadius.circular(12.r),
        border: gradient
            ? null
            : Border.all(color: HomeReportColors.divider, width: 1),
      ),
      child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
    );
  }
}

class _MembershipBanner extends StatelessWidget {
  const _MembershipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HomeReportColors.bannerStart, HomeReportColors.bannerEnd],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF3D2A20)),
      ),
      child: Row(
        children: [
          Text('👑', style: TextStyle(fontSize: 28.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '开通会员，解锁全部内容',
                  style: TextStyle(
                    color: HomeReportColors.titleWhite,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '全量剧集 · AI外教不限时 · 专属勋章',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HomeReportColors.subtitleGrey,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: HomeReportColors.orangeDeep,
            borderRadius: BorderRadius.circular(20.r),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: Text(
                  '立即开通',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentAssistantChip extends StatelessWidget {
  const _ParentAssistantChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: HomeReportColors.parentChip,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: HomeReportColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.family_restroom_rounded,
              size: 16.sp, color: HomeReportColors.subtitleGrey),
          SizedBox(width: 6.w),
          Text(
            '家长助手',
            style: TextStyle(
              color: HomeReportColors.subtitleGrey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightItem {
  const _HighlightItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final _HighlightTrailing trailing;
}

class _RecordItem {
  const _RecordItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    this.statusHighlight = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final bool statusHighlight;
}

class _HighlightTrailing {
  const _HighlightTrailing._(this._type, this._value);

  const _HighlightTrailing.score(String value)
      : this._(_HighlightTrailingType.score, value);

  const _HighlightTrailing.emoji(String value)
      : this._(_HighlightTrailingType.emoji, value);

  const _HighlightTrailing.play()
      : this._(_HighlightTrailingType.play, null);

  final _HighlightTrailingType _type;
  final String? _value;

  Widget build() {
    switch (_type) {
      case _HighlightTrailingType.score:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: HomeReportColors.orangeDeep,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _value!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      case _HighlightTrailingType.emoji:
        return Text(_value!, style: TextStyle(fontSize: 24.sp));
      case _HighlightTrailingType.play:
        return Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: const Color(0xFF2E3340),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: HomeReportColors.dotBlue,
            size: 20.sp,
          ),
        );
    }
  }
}

enum _HighlightTrailingType { score, emoji, play }
