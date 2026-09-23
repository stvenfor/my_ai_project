import 'package:flutter/material.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/api/points_api.dart';
import 'package:module_home/home/theme/check_in_mall_theme.dart';
import 'package:module_http/module_http.dart';
import 'package:module_utils/module_utils.dart';

/// 首页每日签到弹窗：设备本地自然日最多弹一次（仿社区公约）。
abstract final class DailyCheckInDialog {
  static const prefsKey = 'check_in_dialog_ack_date';

  static String todayLocalString([DateTime? now]) {
    final n = now ?? DateTime.now();
    final y = n.year.toString().padLeft(4, '0');
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 纯逻辑：便于单测。
  static bool shouldShow({
    required bool isLoggedIn,
    required bool checkedInToday,
    required String? ackDate,
    required String todayLocal,
  }) {
    if (!isLoggedIn) return false;
    if (checkedInToday) return false;
    if (ackDate == todayLocal) return false;
    return true;
  }

  static Future<void> markAcked([String? today]) async {
    await SpUtils.setString(prefsKey, today ?? todayLocalString());
  }

  /// 已登录且服务端未签到、且本日未弹过时展示；可在弹窗内签到。
  static Future<void> maybeShow(BuildContext context, {PointsApi? api}) async {
    if (!AuthSession.isLoggedIn) return;
    final today = todayLocalString();
    if (SpUtils.getString(prefsKey) == today) return;
    if (!context.mounted) return;

    final pointsApi = api ?? PointsApi();
    try {
      final status = await pointsApi.fetchStatus();
      if (!shouldShow(
        isLoggedIn: true,
        checkedInToday: status.checkedInToday,
        ackDate: SpUtils.getString(prefsKey),
        todayLocal: today,
      )) {
        return;
      }
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (ctx) => _DailyCheckInAlert(
          todayReward: status.todayReward,
          streak: status.streak,
          onCheckIn: () async {
            try {
              final res = await pointsApi.checkIn();
              await markAcked(today);
              UiKitInitializer.toast('签到成功，+${res.points}积分');
              if (ctx.mounted) Navigator.of(ctx).pop();
            } on HttpRequestException catch (e) {
              UiKitInitializer.toast(e.message.isEmpty ? '签到失败' : e.message);
            } catch (_) {
              UiKitInitializer.toast('签到失败');
            }
          },
          onDismiss: () async {
            await markAcked(today);
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
        ),
      ).whenComplete(() {
        // 外点关闭也记已弹，避免同日反复打扰。
        markAcked(today);
      });
    } catch (_) {
      // 网络失败不弹，避免干扰首页。
    }
  }
}

class _DailyCheckInAlert extends StatefulWidget {
  const _DailyCheckInAlert({
    required this.todayReward,
    required this.streak,
    required this.onCheckIn,
    required this.onDismiss,
  });

  final int todayReward;
  final int streak;
  final Future<void> Function() onCheckIn;
  final Future<void> Function() onDismiss;

  @override
  State<_DailyCheckInAlert> createState() => _DailyCheckInAlertState();
}

class _DailyCheckInAlertState extends State<_DailyCheckInAlert> {
  bool _busy = false;

  Future<void> _handleCheckIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onCheckIn();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: CheckInMallTheme.primaryBlue.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHero(),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                  child: Column(
                    children: [
                      Text(
                        '每日签到',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: CheckInMallTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '签到攒积分，可在签到页兑换好物',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.4,
                          color: CheckInMallTheme.textSecondary,
                        ),
                      ),
                      if (widget.streak > 0) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: CheckInMallTheme.coinGold
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '已连续签到 ${widget.streak} 天',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB7791F),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: FilledButton(
                          onPressed: _busy ? null : _handleCheckIn,
                          style: FilledButton.styleFrom(
                            backgroundColor: CheckInMallTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: CheckInMallTheme.primaryBlue
                                .withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                          ),
                          child: _busy
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  '立即签到 · +${widget.todayReward}积分',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextButton(
                        onPressed: _busy ? null : () => widget.onDismiss(),
                        style: TextButton.styleFrom(
                          foregroundColor: CheckInMallTheme.textHint,
                          minimumSize: Size(0, 36.h),
                        ),
                        child: Text(
                          '稍后再说',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: _busy ? null : () => widget.onDismiss(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A8CFF),
            CheckInMallTheme.primaryBlue,
            const Color(0xFF0050C8),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '+${widget.todayReward}',
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.w800,
              height: 1,
              color: CheckInMallTheme.coinGold,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '今日可领积分',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
