import 'package:flutter/material.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/api/points_api.dart';
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('每日签到'),
      content: Text(
        '今日可领 ${widget.todayReward} 积分'
        '${widget.streak > 0 ? '（已连签 ${widget.streak} 天）' : ''}。'
        '签到攒积分，可在签到页兑换好物。',
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => widget.onDismiss(),
          child: const Text('稍后再说'),
        ),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  await widget.onCheckIn();
                  if (mounted) setState(() => _busy = false);
                },
          child: Text(_busy ? '签到中…' : '立即签到'),
        ),
      ],
    );
  }
}
