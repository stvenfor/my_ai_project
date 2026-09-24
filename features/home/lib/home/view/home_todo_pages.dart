import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/api/home_todo_api.dart';
import 'package:module_home/home/model/home_todo_models.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_http/module_http.dart';

/// 新伙伴待确认列表：确认 / 拒绝。
class PartnerPendingPage extends StatefulWidget {
  const PartnerPendingPage({super.key});

  @override
  State<PartnerPendingPage> createState() => _PartnerPendingPageState();
}

class _PartnerPendingPageState extends State<PartnerPendingPage> {
  final _api = HomeTodoApi();
  late Future<List<HomeTodoJoinApplication>> _future;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchJoinApplications();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.fetchJoinApplications();
    });
    await _future;
  }

  Future<void> _approve(HomeTodoJoinApplication app) async {
    setState(() => _busyId = app.applicationId);
    try {
      await _api.approveJoin(app.applicationId);
      if (!mounted) return;
      UiKitInitializer.toast('已确认 ${app.displayName}');
      await _reload();
    } catch (e) {
      if (!mounted) return;
      UiKitInitializer.toast(_errMsg(e, '确认失败'));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _reject(HomeTodoJoinApplication app) async {
    final ok = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('拒绝申请'),
            content: Text('确定拒绝 ${app.displayName} 的入店申请？'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE5484D),
                ),
                child: const Text('拒绝'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;

    setState(() => _busyId = app.applicationId);
    try {
      await _api.rejectJoin(app.applicationId);
      if (!mounted) return;
      UiKitInitializer.toast('已拒绝 ${app.displayName}');
      await _reload();
    } catch (e) {
      if (!mounted) return;
      UiKitInitializer.toast(_errMsg(e, '拒绝失败'));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: HomeDashboardTheme.background,
      navBar: const AppNavBar(title: '新伙伴待确认', showBackButton: true),
      body: FutureBuilder<List<HomeTodoJoinApplication>>(
        future: _future,
        builder: (context, snap) {
          return _TodoListBody<HomeTodoJoinApplication>(
            snap: snap,
            emptyTitle: '暂无待审申请',
            emptySubtitle: '有人申请入店后会显示在这里',
            onRetry: _reload,
            itemBuilder: (app) {
              final busy = _busyId == app.applicationId;
              return _TodoCard(
                leading: _Avatar(label: app.displayName),
                title: app.displayName,
                subtitle: '申请于 ${formatTodoDateTime(app.createdAt)}',
                trailing: busy
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                footer: busy
                    ? null
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _reject(app),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: HomeDashboardTheme.labelSecondary,
                                side: BorderSide(
                                  color: HomeDashboardTheme.separator,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    HomeDashboardTheme.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text('拒绝'),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _approve(app),
                              style: FilledButton.styleFrom(
                                backgroundColor: HomeDashboardTheme.accent,
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    HomeDashboardTheme.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text('确认入店'),
                            ),
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

/// 待跟进客户。
class FollowUpCustomersPage extends StatefulWidget {
  const FollowUpCustomersPage({super.key});

  @override
  State<FollowUpCustomersPage> createState() => _FollowUpCustomersPageState();
}

class _FollowUpCustomersPageState extends State<FollowUpCustomersPage> {
  final _api = HomeTodoApi();
  late Future<List<HomeTodoFollowUpCustomer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchFollowUpCustomers();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.fetchFollowUpCustomers();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: HomeDashboardTheme.background,
      navBar: const AppNavBar(title: '待跟进客户', showBackButton: true),
      body: FutureBuilder<List<HomeTodoFollowUpCustomer>>(
        future: _future,
        builder: (context, snap) {
          return _TodoListBody<HomeTodoFollowUpCustomer>(
            snap: snap,
            emptyTitle: '暂无待跟进客户',
            emptySubtitle: '到期需跟进的客户会出现在这里',
            onRetry: _reload,
            itemBuilder: (c) => _TodoCard(
              leading: _Avatar(
                label: c.displayName,
                tint: HomeDashboardTheme.accent.withValues(alpha: 0.12),
                iconColor: HomeDashboardTheme.accent,
              ),
              title: c.displayName,
              subtitle: '跟进截止 ${formatTodoDateTime(c.nextFollowUpAt)}',
              badge: '待跟进',
              badgeColor: HomeDashboardTheme.badgeOrange,
            ),
          );
        },
      ),
    );
  }
}

/// 售后预约。
class AfterSalesAppointmentsPage extends StatefulWidget {
  const AfterSalesAppointmentsPage({super.key});

  @override
  State<AfterSalesAppointmentsPage> createState() =>
      _AfterSalesAppointmentsPageState();
}

class _AfterSalesAppointmentsPageState
    extends State<AfterSalesAppointmentsPage> {
  final _api = HomeTodoApi();
  late Future<List<HomeTodoAppointment>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchAppointments();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.fetchAppointments();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: HomeDashboardTheme.background,
      navBar: const AppNavBar(title: '售后预约', showBackButton: true),
      body: FutureBuilder<List<HomeTodoAppointment>>(
        future: _future,
        builder: (context, snap) {
          return _TodoListBody<HomeTodoAppointment>(
            snap: snap,
            emptyTitle: '暂无售后预约',
            emptySubtitle: '待处理且预约日未过期的记录会出现在这里',
            onRetry: _reload,
            itemBuilder: (a) => _TodoCard(
              leading: _Avatar(
                label: a.customerName,
                tint: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF2E7D32),
              ),
              title: a.customerName,
              subtitle: '预约日 ${formatTodoDate(a.appointmentDate)}',
              badge: '待到店',
              badgeColor: const Color(0xFF2E7D32),
            ),
          );
        },
      ),
    );
  }
}

/// 订单待审核。
class StoreReviewOrdersPage extends StatefulWidget {
  const StoreReviewOrdersPage({super.key});

  @override
  State<StoreReviewOrdersPage> createState() => _StoreReviewOrdersPageState();
}

class _StoreReviewOrdersPageState extends State<StoreReviewOrdersPage> {
  final _api = HomeTodoApi();
  late Future<List<HomeTodoReviewOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchReviewOrders();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.fetchReviewOrders();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: HomeDashboardTheme.background,
      navBar: const AppNavBar(title: '订单待审核', showBackButton: true),
      body: FutureBuilder<List<HomeTodoReviewOrder>>(
        future: _future,
        builder: (context, snap) {
          return _TodoListBody<HomeTodoReviewOrder>(
            snap: snap,
            emptyTitle: '暂无待审订单',
            emptySubtitle: '门店业务审核单会出现在这里',
            onRetry: _reload,
            itemBuilder: (o) => _TodoCard(
              leading: Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 22.sp,
                  color: HomeDashboardTheme.accent,
                ),
              ),
              title: o.title,
              subtitle:
                  '单号 #${o.orderId} · ${formatTodoDateTime(o.createdAt)}',
              badge: '待审核',
              badgeColor: HomeDashboardTheme.accent,
            ),
          );
        },
      ),
    );
  }
}

class _TodoListBody<T> extends StatelessWidget {
  const _TodoListBody({
    required this.snap,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRetry,
    required this.itemBuilder,
  });

  final AsyncSnapshot<List<T>> snap;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRetry;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (snap.connectionState != ConnectionState.done) {
      return Center(
        child: CircularProgressIndicator(color: HomeDashboardTheme.accent),
      );
    }
    if (snap.hasError) {
      if (_isForbiddenError(snap.error)) {
        return _TodoForbiddenPane(onBack: () => Get.back<void>());
      }
      return _TodoStatePane(
        icon: Icons.wifi_tethering_error_rounded,
        title: '暂时加载不出来',
        subtitle: _errMsg(snap.error, '网络异常，请稍后重试'),
        actionLabel: '重试',
        onAction: onRetry,
      );
    }
    final items = snap.data ?? const [];
    if (items.isEmpty) {
      return _TodoStatePane(
        icon: Icons.inbox_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: '刷新',
        onAction: onRetry,
      );
    }

    return AppRefreshView(
      onRefresh: onRetry,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        itemCount: items.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Text(
                '共 ${items.length} 条',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: HomeDashboardTheme.labelTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: itemBuilder(items[i - 1]),
          );
        },
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.badge,
    this.badgeColor,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? badge;
  final Color? badgeColor;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HomeDashboardTheme.radiusMd);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: radius,
        border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: HomeDashboardTheme.labelPrimary,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (badge != null) ...[
                            SizedBox(width: 8.w),
                            _StatusBadge(
                              label: badge!,
                              color: badgeColor ?? HomeDashboardTheme.accent,
                            ),
                          ],
                          if (trailing != null) ...[
                            SizedBox(width: 8.w),
                            trailing!,
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: HomeDashboardTheme.labelSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (footer != null) ...[
              SizedBox(height: 12.h),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.label,
    this.tint,
    this.iconColor,
  });

  final String label;
  final Color? tint;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final trimmed = label.trim();
    final ch = trimmed.isEmpty ? '?' : trimmed.substring(0, 1);
    return Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint ?? HomeDashboardTheme.fillSecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        ch.toUpperCase(),
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: iconColor ?? HomeDashboardTheme.labelPrimary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _TodoStatePane extends StatelessWidget {
  const _TodoStatePane({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: HomeDashboardTheme.fillSecondary,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: HomeDashboardTheme.separator),
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: HomeDashboardTheme.labelTertiary,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: HomeDashboardTheme.labelPrimary,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: HomeDashboardTheme.labelSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => onAction(),
                style: FilledButton.styleFrom(
                  backgroundColor: HomeDashboardTheme.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      HomeDashboardTheme.radiusMd,
                    ),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 403 / 业务无权限：不展示原始「无权限」硬文案，给可理解说明与返回。
class _TodoForbiddenPane extends StatelessWidget {
  const _TodoForbiddenPane({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HomeDashboardTheme.surface,
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusLg),
              border: Border.all(color: HomeDashboardTheme.separator),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 22.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: HomeDashboardTheme.accent.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 28.sp,
                      color: HomeDashboardTheme.accent,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    '暂无查看权限',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: HomeDashboardTheme.labelPrimary,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '该待办仅门店管理员可查看。\n如需处理，请联系店管开通权限，或切换有权限的账号。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: HomeDashboardTheme.labelSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onBack,
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeDashboardTheme.accent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            HomeDashboardTheme.radiusMd,
                          ),
                        ),
                      ),
                      child: const Text('返回'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _isForbiddenError(Object? e) {
  if (e is HttpRequestException) {
    if (e.statusCode == 403) return true;
    if (e.code == '10003') return true;
    final m = e.message;
    if (m.contains('无权限') ||
        m.contains('没有权限') ||
        m.contains('无权') ||
        m.contains('仅门店管理员')) {
      return true;
    }
  }
  final s = e?.toString() ?? '';
  return s.contains('无权限') ||
      s.contains('没有权限') ||
      s.contains('无权') ||
      s.contains('仅门店管理员');
}

String _errMsg(Object? e, String fallback) {
  if (e is HttpRequestException && e.message.isNotEmpty) return e.message;
  final s = e?.toString() ?? '';
  return s.isEmpty ? fallback : s;
}
