import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/api/points_api.dart';
import 'package:module_home/home/model/points_models.dart';
import 'package:module_home/home/theme/check_in_mall_theme.dart';
import 'package:module_http/module_http.dart';
import 'package:wys_router/wys_router.dart';

class CheckInMallPage extends StatefulWidget {
  const CheckInMallPage({super.key});

  @override
  State<CheckInMallPage> createState() => _CheckInMallPageState();
}

class _CheckInMallPageState extends State<CheckInMallPage> {
  final PointsApi _api = PointsApi();

  bool _reminderEnabled = false;
  bool _loading = true;
  bool _checkingIn = false;
  String? _error;
  String? _claimingCode;

  PointsStatus? _status;
  List<GrowthTask> _tasks = const [];
  List<PointsGiftItem> _gifts = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!AuthSession.isLoggedIn) {
      await AuthNavigation.openLogin(redirectRoute: RoutePath.homeCheckInMall);
      if (!mounted) return;
      if (!AuthSession.isLoggedIn) {
        Get.back<void>();
        return;
      }
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.fetchStatus(),
        _api.fetchTasks(),
        _api.fetchPointsGifts(),
      ]);
      if (!mounted) return;
      setState(() {
        _status = results[0] as PointsStatus;
        _tasks = results[1] as List<GrowthTask>;
        _gifts = results[2] as List<PointsGiftItem>;
        _loading = false;
      });
    } on HttpRequestException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message.isEmpty ? '加载失败' : e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败';
        _loading = false;
      });
    }
  }

  Future<void> _onCheckIn() async {
    final status = _status;
    if (status == null || status.checkedInToday || _checkingIn) return;
    setState(() => _checkingIn = true);
    try {
      final res = await _api.checkIn();
      if (!mounted) return;
      UiKitInitializer.toast('签到成功，+${res.points}积分');
      await _load();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '签到失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('签到失败');
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  Future<void> _onTaskTap(GrowthTask task) async {
    switch (task.progress) {
      case TaskProgress.claimed:
        return;
      case TaskProgress.incomplete:
        _goCompleteTask(task);
        return;
      case TaskProgress.claimable:
        if (_claimingCode != null) return;
        setState(() => _claimingCode = task.code);
        try {
          final res = await _api.claimTask(task.code);
          if (!mounted) return;
          UiKitInitializer.toast('领取成功，+${res.points}积分');
          await _load();
        } on HttpRequestException catch (e) {
          UiKitInitializer.toast(e.message.isEmpty ? '领取失败' : e.message);
        } catch (_) {
          UiKitInitializer.toast('领取失败');
        } finally {
          if (mounted) setState(() => _claimingCode = null);
        }
    }
  }

  void _goCompleteTask(GrowthTask task) {
    switch (task.code) {
      case 'post':
        Get.toNamed(RoutePath.communityPublish);
      case 'order':
        Get.toNamed(RoutePath.mall);
      default:
        UiKitInitializer.toast('去完成：${task.title}');
    }
  }

  void _onGiftTap(PointsGiftItem item) {
    if (item.productId.isEmpty) {
      UiKitInitializer.toast(item.title);
      return;
    }
    Get.toNamed(RoutePath.mallDetail, arguments: item.productId);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: CheckInMallTheme.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _status == null) {
      return Column(
        children: [
          _buildHeaderChrome(),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }
    if (_error != null && _status == null) {
      return Column(
        children: [
          _buildHeaderChrome(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    style: TextStyle(color: CheckInMallTheme.textSecondary),
                  ),
                  SizedBox(height: 12.h),
                  FilledButton(
                    onPressed: _load,
                    style: FilledButton.styleFrom(
                      backgroundColor: CheckInMallTheme.primaryBlue,
                    ),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckInCard(),
              SizedBox(height: 16.h),
              _buildTaskSection(),
              SizedBox(height: 16.h),
              _buildGiftSection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderChrome() {
    return ColoredBox(
      color: CheckInMallTheme.primaryBlue,
      child: Column(
        children: [
          AppNavBar(
            title: '签到商城',
            showBackButton: true,
            onBack: () => Get.back<void>(),
            style: AppNavBarStyle.transparent,
            foregroundColor: Colors.white,
          ),
          _buildNoticeBar(),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final status = _status;
    return ColoredBox(
      color: CheckInMallTheme.primaryBlue,
      child: Column(
        children: [
          AppNavBar(
            title: '签到商城',
            showBackButton: true,
            onBack: () => Get.back<void>(),
            style: AppNavBarStyle.transparent,
            foregroundColor: Colors.white,
          ),
          _buildNoticeBar(),
          SizedBox(height: 16.h),
          _buildStatsRow(status),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildNoticeBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3A8EE6),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Icon(Icons.volume_up, color: Colors.white, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: _NoticeMarquee(
              text: '温馨提示：本页面只保留近3个月内的积分记录',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(PointsStatus? status) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: '我的积分',
              value: '${status?.balance ?? 0}',
            ),
          ),
          Expanded(
            child: _buildStatItem(
              label: '连续签到',
              value: '${status?.streak ?? 0}',
              suffix: '天',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (suffix != null) ...[
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  suffix,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCheckInCard() {
    final status = _status;
    final checkedIn = status?.checkedInToday ?? false;
    final streak = status?.streak ?? 0;
    final calendar = status?.calendar ?? const <CheckInDayView>[];
    final weekRewardHint =
        calendar.isEmpty ? '每日签到领积分' : '连签可得更多积分';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekRewardHint,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: CheckInMallTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '已连续签到 ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CheckInMallTheme.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: '$streak',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CheckInMallTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' 天',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CheckInMallTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: checkedIn || _checkingIn ? null : _onCheckIn,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: checkedIn
                        ? const Color(0xFFF5F6F8)
                        : CheckInMallTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    checkedIn
                        ? '已签到'
                        : (_checkingIn ? '签到中…' : '立即签到'),
                    style: TextStyle(
                      color: checkedIn
                          ? CheckInMallTheme.textHint
                          : Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (calendar.isNotEmpty)
            Row(
              children: [
                for (final day in calendar)
                  Expanded(child: _buildDayItem(day)),
              ],
            ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '断签或者签完需重新开始',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CheckInMallTheme.textHint,
                ),
              ),
              Row(
                children: [
                  Text(
                    '签到提醒',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CheckInMallTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 44.w,
                    height: 24.h,
                    child: Switch(
                      value: _reminderEnabled,
                      onChanged: (value) {
                        setState(() => _reminderEnabled = value);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: CheckInMallTheme.primaryBlue,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor:
                          CheckInMallTheme.textHint.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(CheckInDayView day) {
    final Color bgColor;
    final Color textColor;
    final String label;
    final dayNum = day.day.length >= 10 ? day.day.substring(8) : day.day;

    if (day.signed) {
      bgColor = CheckInMallTheme.primaryBlue;
      textColor = Colors.white;
      label = '已签';
    } else if (day.isToday) {
      bgColor = CheckInMallTheme.coinGold;
      textColor = Colors.white;
      label = '今天';
    } else {
      bgColor = const Color(0xFFF5F6F8);
      textColor = CheckInMallTheme.textSecondary;
      label = dayNum.isEmpty ? '-' : dayNum;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+${day.reward}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: textColor.withValues(alpha: 0.8),
                    size: 10.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: day.signed
                  ? CheckInMallTheme.primaryBlue
                  : CheckInMallTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '成长任务',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: CheckInMallTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: _tasks.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      '暂无任务',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: CheckInMallTheme.textHint,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < _tasks.length; i++) ...[
                        _buildTaskItem(_tasks[i]),
                        if (i < _tasks.length - 1)
                          Divider(
                            height: 1,
                            indent: 56.w,
                            endIndent: 16.w,
                            color: CheckInMallTheme.divider,
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  IconData _taskIcon(String code) {
    switch (code) {
      case 'post':
        return Icons.chat_bubble_outline;
      case 'order':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.login;
    }
  }

  Widget _buildTaskItem(GrowthTask task) {
    final claiming = _claimingCode == task.code;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FA),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _taskIcon(task.code),
              color: const Color(0xFF4A90E2),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: CheckInMallTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '+${task.reward}积分',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CheckInMallTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: claiming ? null : () => _onTaskTap(task),
            child: _buildTaskButton(task, claiming: claiming),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskButton(GrowthTask task, {required bool claiming}) {
    final String text;
    final bool primary;
    switch (task.progress) {
      case TaskProgress.incomplete:
        text = '去完成';
        primary = true;
      case TaskProgress.claimable:
        text = claiming ? '领取中…' : '领取';
        primary = true;
      case TaskProgress.claimed:
        text = '已领取';
        primary = false;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: primary ? CheckInMallTheme.primaryBlue : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primary ? Colors.white : CheckInMallTheme.textHint,
          fontSize: 12.sp,
          fontWeight: primary ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildGiftSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '积分换礼',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: CheckInMallTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          if (_gifts.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.card_giftcard_outlined,
                      size: 80.sp,
                      color: CheckInMallTheme.textHint.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '暂无积分商品',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CheckInMallTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _gifts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) => _buildGiftCard(_gifts[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildGiftCard(PointsGiftItem item) {
    return GestureDetector(
      onTap: () => _onGiftTap(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: item.coverUrl.isEmpty
                  ? ColoredBox(
                      color: const Color(0xFFF5F6F8),
                      child: Icon(
                        Icons.image_outlined,
                        color: CheckInMallTheme.textHint,
                        size: 32.sp,
                      ),
                    )
                  : Image.network(
                      item.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: const Color(0xFFF5F6F8),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: CheckInMallTheme.textHint,
                          size: 32.sp,
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
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: CheckInMallTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.priceLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CheckInMallTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 温馨提示跑马灯：文字横向滚动，外层喇叭图标保持固定。
class _NoticeMarquee extends StatefulWidget {
  const _NoticeMarquee({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  State<_NoticeMarquee> createState() => _NoticeMarqueeState();
}

class _NoticeMarqueeState extends State<_NoticeMarquee>
    with SingleTickerProviderStateMixin {
  static const _gap = 48.0;
  static const _pixelsPerSecond = 36.0;

  late final AnimationController _controller;
  double _textWidth = 0;
  double _viewportWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _NoticeMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restartIfNeeded());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _restartIfNeeded() {
    if (!mounted || _viewportWidth <= 0) return;
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _textWidth = painter.width;
    if (_textWidth <= 0) return;

    // 公告条始终横向滚动（文案短时也播），喇叭固定在左侧。
    final distance = _textWidth + _gap;
    final seconds = distance / _pixelsPerSecond;
    if (!_controller.isAnimating ||
        _controller.duration?.inMilliseconds != (seconds * 1000).round()) {
      _controller
        ..duration = Duration(milliseconds: (seconds * 1000).round().clamp(1, 60000))
        ..repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width != _viewportWidth) {
          _viewportWidth = width;
          WidgetsBinding.instance.addPostFrameCallback((_) => _restartIfNeeded());
        }

        return ClipRect(
          child: SizedBox(
            height: (widget.style.fontSize ?? 12) * (widget.style.height ?? 1.2),
            width: width,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final cycle = (_textWidth > 0 ? _textWidth : width) + _gap;
                final dx = -_controller.value * cycle;
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Transform.translate(
                      offset: Offset(dx, 0),
                      child: _label(),
                    ),
                    Transform.translate(
                      offset: Offset(dx + cycle, 0),
                      child: _label(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _label() {
    return Text(
      widget.text,
      maxLines: 1,
      softWrap: false,
      style: widget.style,
    );
  }
}
