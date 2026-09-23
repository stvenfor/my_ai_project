import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/home_controller.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/model/home_todo_models.dart';
import 'package:module_home/home/model/home_todo_packer.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_home/home/navigation/ai_stone_navigation.dart';
import 'package:module_home/home/navigation/deal_invoice_navigation.dart';
import 'package:module_home/home/navigation/new_car_follow_navigation.dart';
import 'package:module_home/home/navigation/used_car_navigation.dart';
import 'package:wys_router/src/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  Future<void> _openScan(BuildContext context) async {
    final perm = await ImagePickerUtils.requestCameraAccess();
    switch (perm) {
      case MediaPermissionResult.granted:
        break;
      case MediaPermissionResult.denied:
        UiKitInitializer.toastError('需要相机权限才能扫码');
        return;
      case MediaPermissionResult.permanentlyDenied:
        final go = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('需要相机权限'),
            content: const Text('相机权限已被关闭。请在系统设置中开启后，再回来扫码。'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('去设置'),
              ),
            ],
          ),
        );
        if (go == true) {
          await ImagePickerUtils.openPermissionSettings();
        }
        return;
    }

    // Get.to 走根路由，避开首页 Tab IndexedStack 里 local Navigator 吞掉 push
    final result = await Get.to<String>(
      () => const ScanPage(),
      fullscreenDialog: true,
    );
    if (result == null || result.isEmpty) return;
    UiKitInitializer.toast(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed<void>(RoutePath.homeSearch),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.surface,
                  borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
                  border: Border.all(
                    color: HomeDashboardTheme.separator,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 20.sp,
                      color: HomeDashboardTheme.labelSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '搜索客户、订单、资讯',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: HomeDashboardTheme.labelTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Material(
            color: HomeDashboardTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              side: BorderSide(
                color: HomeDashboardTheme.separator,
                width: 0.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              onTap: () => _openScan(context),
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 22.sp,
                  color: HomeDashboardTheme.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBannerSection extends StatelessWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      height: 132.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        color: HomeDashboardTheme.surface,
        boxShadow: HomeDashboardTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CacheImageUtils.network(
            'https://picsum.photos/seed/banner/800/400',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.25),
            colorBlendMode: BlendMode.darken,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  HomeDashboardTheme.accent.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            top: 24.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '朋友圈营销',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '一键分享，高效触达客户',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '立即体验',
                    style: TextStyle(
                      color: HomeDashboardTheme.accent,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
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

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key, required this.items});

  final List<HomeFeatureItem> items;

  void _onFeatureTap(HomeFeatureItem item) {
    if (item.label == '更多') {
      Get.toNamed(RoutePath.homeAllServices);
      return;
    }
    if (item.label == '生活服务') {
      Get.toNamed(RoutePath.homeLifeService);
      return;
    }
    if (item.label == '直播带货') {
      Get.toNamed(RoutePath.homeLiveCommerce);
      return;
    }
    if (item.label == 'Club') {
      Get.toNamed(RoutePath.homeClub);
      return;
    }
    if (item.label == '二手车') {
      UsedCarNavigation.open();
      return;
    }
    if (item.label == '新车成交') {
      DealInvoiceNavigation.open();
      return;
    }
    if (item.label == '新车跟进') {
      NewCarFollowNavigation.open();
      return;
    }
    if (item.label == 'AI小石头') {
      AiStoneNavigation.open();
      return;
    }
    if (item.label == 'H5 调试') {
      final dashboard = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>().dashboard.value
          : null;
      Get.toNamed(
        RoutePath.web,
        arguments: WebPageConfig.asset(
          assetPath: WebBridgeAssets.testBridge,
          title: 'H5 调试',
          params: {
            'from': 'home',
            'feature': item.label,
            'storeName': dashboard?.storeName ?? '',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 产品：最多 9 格，末位固定「更多」（≠ 5×2 布局算术）
    const maxItems = 9;
    const crossAxisCount = 5;
    final iconSize = 44.w;
    final labelGap = 4.h;
    final labelStyle = TextStyle(
      fontSize: 11.sp,
      height: 1.2,
      color: HomeDashboardTheme.labelPrimary,
    );
    final more = items.where((e) => e.label == '更多').toList();
    final head = items
        .where((e) => e.label != '更多')
        .take(more.isEmpty ? maxItems : maxItems - 1)
        .toList();
    final visible =
        more.isEmpty ? head : [...head, more.last];
    final rows = <List<HomeFeatureItem>>[];
    for (var i = 0; i < visible.length; i += crossAxisCount) {
      final end = i + crossAxisCount > visible.length
          ? visible.length
          : i + crossAxisCount;
      rows.add(visible.sublist(i, end));
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 8.h),
      decoration: HomeDashboardTheme.groupedCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in rows[r])
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onFeatureTap(item),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: HomeDashboardTheme.fillSecondary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: item.imageUrl != null
                                ? CacheImageUtils.network(
                                    item.imageUrl!,
                                    width: iconSize,
                                    height: iconSize,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(12.r),
                                    placeholder: (_, __) => Center(
                                      child: SizedBox(
                                        width: 18.w,
                                        height: 18.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.apps_rounded,
                                      size: 22.sp,
                                      color: HomeDashboardTheme.accent,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      item.emoji ?? '?',
                                      style: TextStyle(fontSize: 22.sp),
                                    ),
                                  ),
                          ),
                          SizedBox(height: labelGap),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: labelStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                for (var j = rows[r].length; j < crossAxisCount; j++)
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class HomeGreetingSection extends StatelessWidget {
  const HomeGreetingSection({
    super.key,
    required this.greeting,
  });

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              greeting,
              style: HomeDashboardTheme.largeTitle.copyWith(fontSize: 28.sp),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: HomeDashboardTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 16.sp,
                  color: HomeDashboardTheme.accent,
                ),
                SizedBox(width: 4.w),
                Text(
                  '3条新消息',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: HomeDashboardTheme.accent,
                    fontWeight: FontWeight.w500,
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

class HomeTodoCardStrip extends StatefulWidget {
  const HomeTodoCardStrip({super.key, required this.cards});

  final List<HomeTodoCard> cards;

  static String resolveRoute(HomeTodoCard card) {
    if (card.actionRoute.isNotEmpty) return card.actionRoute;
    switch (card.type) {
      case 'partner_pending':
        return RoutePath.homeTodoPartnerPending;
      case 'follow_up_customer':
        return RoutePath.homeTodoFollowUp;
      case 'after_sales_appointment':
        return RoutePath.homeTodoAfterSales;
      case 'order_pending_review':
        return RoutePath.homeTodoOrderReview;
      case 'used_car_pending_review':
        return RoutePath.homeUsedCarList;
      default:
        return RoutePath.home;
    }
  }

  @override
  State<HomeTodoCardStrip> createState() => _HomeTodoCardStripState();
}

class _HomeTodoCardStripState extends State<HomeTodoCardStrip> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _open(HomeTodoCard card) {
    Get.toNamed<void>(HomeTodoCardStrip.resolveRoute(card));
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    if (cards.isEmpty) return const SizedBox.shrink();

    if (HomeTodoPacker.shouldWrapOnly(cards)) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(width: 12.w),
              Expanded(
                child: _HomeTodoCardView(card: cards[i], onTap: () => _open(cards[i])),
              ),
            ],
            for (var i = cards.length; i < 2; i++) ...[
              SizedBox(width: 12.w),
              const Expanded(child: SizedBox.shrink()),
            ],
          ],
        ),
      );
    }

    final pages = HomeTodoPacker.packPages(cards);
    final showIndicator = pages.length > 1;
    // 两行小卡 / 两大中卡 / 一大卡 的内容高度，避免 Expanded 把卡片拉扁。
    final pageHeight = 200.h;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: pageHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              itemBuilder: (context, index) {
                return _TodoPageGrid(page: pages[index], onOpen: _open);
              },
            ),
          ),
          if (showIndicator) ...[
            SizedBox(height: 10.h),
            _TodoPageDots(
              count: pages.length,
              index: _pageIndex,
            ),
          ],
        ],
      ),
    );
  }
}

class _TodoPageDots extends StatelessWidget {
  const _TodoPageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: 6.w),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == index ? 14.w : 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: i == index
                  ? HomeDashboardTheme.primaryBlue
                  : HomeDashboardTheme.separator,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ],
      ],
    );
  }
}

class _TodoPageGrid extends StatelessWidget {
  const _TodoPageGrid({required this.page, required this.onOpen});

  final List<HomeTodoCard> page;
  final void Function(HomeTodoCard) onOpen;

  @override
  Widget build(BuildContext context) {
    final rows = <List<HomeTodoCard>>[];
    var i = 0;
    while (i < page.length) {
      final card = page[i];
      if (card.size == HomeTodoSize.large || card.size == HomeTodoSize.medium) {
        rows.add([card]);
        i++;
        continue;
      }
      final row = <HomeTodoCard>[card];
      i++;
      if (i < page.length && page[i].size == HomeTodoSize.small) {
        row.add(page[i]);
        i++;
      }
      rows.add(row);
    }

    final hasLarge = page.any((c) => c.size == HomeTodoSize.large);

    // PageView 给了固定高：行必须有明确高度，小卡才能铺满壳层（白底/描边/阴影）。
    // 仅一行且非大卡时，行高按 2×2 的一格算，避免最后一屏小卡被压成「无壳」内容条。
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 12.h;
        final rowCount = hasLarge ? 1 : 2;
        final rowHeight =
            (constraints.maxHeight - gap * (rowCount - 1)) / rowCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: gap),
              SizedBox(
                height: rowHeight,
                child: _buildRow(rows[r]),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRow(List<HomeTodoCard> row) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var c = 0; c < row.length; c++) ...[
          if (c > 0) SizedBox(width: 12.w),
          Expanded(
            flex: row[c].size == HomeTodoSize.small ? 1 : 2,
            child: _HomeTodoCardView(
              card: row[c],
              onTap: () => onOpen(row[c]),
              expandFill: true,
            ),
          ),
        ],
        if (row.length == 1 && row.first.size == HomeTodoSize.small) ...[
          SizedBox(width: 12.w),
          const Expanded(child: SizedBox.shrink()),
        ],
      ],
    );
  }
}

class _HomeTodoCardView extends StatelessWidget {
  const _HomeTodoCardView({
    required this.card,
    required this.onTap,
    this.expandFill = false,
  });

  final HomeTodoCard card;
  final VoidCallback onTap;
  final bool expandFill;

  @override
  Widget build(BuildContext context) {
    return switch (card.size) {
      HomeTodoSize.large => _LargeTodoCard(card: card, onTap: onTap),
      HomeTodoSize.medium => _MediumTodoCard(card: card, onTap: onTap),
      HomeTodoSize.small => _SmallTodoCard(
          card: card,
          onTap: onTap,
          expandFill: expandFill,
        ),
    };
  }
}

/// 统一白底+描边+轻阴影。装饰放 DecoratedBox（Ink 上的 shadow/border 常不画）。
class _TodoCardShell extends StatelessWidget {
  const _TodoCardShell({
    required this.onTap,
    required this.child,
    this.padding,
  });

  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HomeDashboardTheme.radiusMd);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: radius,
        border: Border.all(
          color: HomeDashboardTheme.separator,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(14.w),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 原小卡视觉：图标+标题副文案，右下 CTA。
class _SmallTodoCard extends StatelessWidget {
  const _SmallTodoCard({
    required this.card,
    required this.onTap,
    this.expandFill = false,
  });

  final HomeTodoCard card;
  final VoidCallback onTap;
  final bool expandFill;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        _TodoThumb(imageUrl: card.imageUrl, size: 40.w),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: HomeDashboardTheme.labelPrimary,
                  height: 1.25,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                card.subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: HomeDashboardTheme.textGray,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    return _TodoCardShell(
      onTap: onTap,
      child: Column(
        mainAxisSize: expandFill ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // expandFill：行高扣掉 padding/chip 后可能差 1～2px；用 Expanded
          // 吃约束，避免 Spacer 压不住固定子件导致 RenderFlex overflow。
          if (expandFill)
            Expanded(
              child: Align(alignment: Alignment.topLeft, child: header),
            )
          else ...[
            header,
            SizedBox(height: 10.h),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: _TodoActionChip(label: card.actionLabel),
          ),
        ],
      ),
    );
  }
}

/// 中卡：整行，左侧图标+文案，右侧 CTA（由小卡横向扩展）。
class _MediumTodoCard extends StatelessWidget {
  const _MediumTodoCard({required this.card, required this.onTap});

  final HomeTodoCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TodoCardShell(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          _TodoThumb(imageUrl: card.imageUrl, size: 48.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: HomeDashboardTheme.labelPrimary,
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  card.subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: HomeDashboardTheme.textGray,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _TodoActionChip(label: card.actionLabel),
        ],
      ),
    );
  }
}

/// 大卡：字号/行高/计数层级拉开，仍用同一套白底描边 CTA。
class _LargeTodoCard extends StatelessWidget {
  const _LargeTodoCard({required this.card, required this.onTap});

  final HomeTodoCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TodoCardShell(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TodoThumb(imageUrl: card.imageUrl, size: 64.w),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.count > 0) ...[
                      Text(
                        '${card.count}',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: HomeDashboardTheme.primaryBlue,
                          height: 1.05,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: 6.h),
                    ],
                    Text(
                      card.title,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: HomeDashboardTheme.labelPrimary,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      card.subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.45,
                        color: HomeDashboardTheme.labelSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              if (card.count > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: HomeDashboardTheme.background,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '待处理 ${card.count}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: HomeDashboardTheme.labelSecondary,
                    ),
                  ),
                ),
              const Spacer(),
              _TodoActionChip(label: card.actionLabel, large: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodoThumb extends StatelessWidget {
  const _TodoThumb({required this.imageUrl, required this.size});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: HomeDashboardTheme.background,
      ),
      child: imageUrl != null
          ? CacheImageUtils.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(10.r),
              placeholder: (_, __) => Center(
                child: SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ),
              errorWidget: (_, __, ___) => Icon(
                Icons.image_outlined,
                size: size * 0.45,
                color: HomeDashboardTheme.textGray,
              ),
            )
          : Center(
              child: Icon(
                Icons.assignment_outlined,
                size: size * 0.45,
                color: HomeDashboardTheme.textGray,
              ),
            ),
    );
  }
}

class _TodoActionChip extends StatelessWidget {
  const _TodoActionChip({required this.label, this.large = false});

  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16.w : 12.w,
        vertical: large ? 8.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: large ? 13.sp : 12.sp,
          color: HomeDashboardTheme.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class HomeStoreMetricsCard extends StatelessWidget {
  const HomeStoreMetricsCard({
    super.key,
    required this.storeName,
    required this.selectedTab,
    required this.tabs,
    required this.metrics,
    required this.details,
    required this.onTabSelected,
    this.onStoreTap,
  });

  final String storeName;
  final int selectedTab;
  final List<String> tabs;
  final List<HomeMetric> metrics;
  final List<HomeMetricDetail> details;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onStoreTap;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '公司数据',
                style: HomeDashboardTheme.sectionTitle.copyWith(fontSize: 18.sp),
              ),
              const Spacer(),
              Text(
                '查看更多',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: HomeDashboardTheme.accent,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: HomeDashboardTheme.accent,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          DecoratedBox(
            decoration: HomeDashboardTheme.groupedCardDecoration,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StorePickerRow(
                    storeName: storeName,
                    onTap: onStoreTap,
                  ),
                  SizedBox(height: 14.h),
                  _MetricTabBar(
                    tabs: tabs,
                    selectedTab: selectedTab,
                    onTabSelected: onTabSelected,
                  ),
                  SizedBox(height: 14.h),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final gap = 10.w;
                      final tileW = (constraints.maxWidth - gap) / 2;
                      return Wrap(
                        spacing: gap,
                        runSpacing: 10.h,
                        children: [
                          for (final metric in metrics)
                            SizedBox(
                              width: tileW,
                              child: _MetricTile(metric: metric),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 14.h),
                  Divider(height: 1, thickness: 0.5, color: tokens.hairline),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      for (var i = 0; i < details.length; i++) ...[
                        if (i > 0) SizedBox(width: 8.w),
                        Expanded(child: _DetailActionTile(detail: details[i])),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorePickerRow extends StatelessWidget {
  const _StorePickerRow({
    required this.storeName,
    this.onTap,
  });

  final String storeName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: HomeDashboardTheme.fillSecondary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: HomeDashboardTheme.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 16.sp,
                color: HomeDashboardTheme.accent,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                storeName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: HomeDashboardTheme.labelPrimary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: HomeDashboardTheme.labelSecondary,
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.swap_horiz_rounded,
              size: 18.sp,
              color: HomeDashboardTheme.labelTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTabBar extends StatelessWidget {
  const _MetricTabBar({
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.fillSecondary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = index == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: active ? HomeDashboardTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  border: active
                      ? Border.all(color: HomeDashboardTheme.separator, width: 0.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? HomeDashboardTheme.labelPrimary
                        : HomeDashboardTheme.labelSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final HomeMetric metric;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: tokens.canvasSoft,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: tokens.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: HomeDashboardTheme.labelPrimary,
              height: 1.1,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            metric.label,
            style: TextStyle(
              fontSize: 12.sp,
              color: HomeDashboardTheme.labelSecondary,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailActionTile extends StatelessWidget {
  const _DetailActionTile({required this.detail});

  final HomeMetricDetail detail;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: tokens.linkBgSoft.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Text(
            detail.value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: HomeDashboardTheme.accent,
              height: 1.1,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            detail.label,
            style: TextStyle(
              fontSize: 11.sp,
              color: HomeDashboardTheme.labelSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            detail.actionLabel.replaceAll(' >', ''),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: HomeDashboardTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeServiceGrid extends StatelessWidget {
  const HomeServiceGrid({super.key, required this.items});

  final List<HomeServiceItem> items;

  void _onServiceTap(HomeServiceItem item) {
    if (item.label == '更多') {
      Get.toNamed(RoutePath.homeAllServices);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    final accents = <Color>[
      tokens.link,
      tokens.violet,
      tokens.cyan,
      tokens.warning,
      tokens.highlightPink,
      tokens.linkDeep,
      tokens.violet,
      tokens.ink,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '服务推荐',
                style: HomeDashboardTheme.sectionTitle.copyWith(fontSize: 18.sp),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.toNamed(RoutePath.homeAllServices),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '全部',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: HomeDashboardTheme.accent,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18.sp,
                      color: HomeDashboardTheme.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: HomeDashboardTheme.groupedCardDecoration,
            // Wrap 按子项固有高度撑开，不用 GridView 固定行高（.h 还会被屏高放大）
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 10, 4.w, 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const cols = 4;
                  final cellW = constraints.maxWidth / cols;
                  return Wrap(
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        SizedBox(
                          width: cellW,
                          child: _ServiceGridItem(
                            item: items[i],
                            accent: accents[i % accents.length],
                            onTap: () => _onServiceTap(items[i]),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceGridItem extends StatelessWidget {
  const _ServiceGridItem({
    required this.item,
    required this.accent,
    required this.onTap,
  });

  final HomeServiceItem item;
  final Color accent;
  final VoidCallback onTap;

  IconData get _icon {
    switch (item.label) {
      case '朋友圈':
        return Icons.photo_camera_outlined;
      case '视频号':
        return Icons.videocam_outlined;
      case '直播':
        return Icons.live_tv_outlined;
      case '素材库':
        return Icons.photo_library_outlined;
      case '话术库':
        return Icons.chat_bubble_outline_rounded;
      case '培训':
        return Icons.school_outlined;
      case '竞品分析':
        return Icons.insights_outlined;
      case '更多':
        return Icons.apps_rounded;
      default:
        return Icons.apps_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(_icon, size: 22.sp, color: accent),
              ),
              if (item.badge != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1),
                    decoration: BoxDecoration(
                      color: item.badge == '热门'
                          ? HomeDashboardTheme.badgeOrange
                          : HomeDashboardTheme.badgeBlue,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: HomeDashboardTheme.labelPrimary,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HomeContactList extends StatelessWidget {
  const HomeContactList({super.key, required this.items});

  final List<HomeContactItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('联系汽车之家', style: HomeDashboardTheme.sectionTitle),
          SizedBox(height: 12.h),
          DecoratedBox(
            decoration: BoxDecoration(
              color: HomeDashboardTheme.surface,
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              border: Border.all(
                color: HomeDashboardTheme.separator,
                width: 0.5,
              ),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      leading: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: HomeDashboardTheme.fillSecondary,
                        child: item.imageUrl != null
                            ? CacheImageUtils.circle(
                                item.imageUrl!,
                                size: 44.r,
                                placeholder: (_, __) => Center(
                                  child: SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: const CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.person_outline,
                                  size: 20.sp,
                                  color: HomeDashboardTheme.accent,
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 20.sp,
                                color: HomeDashboardTheme.accent,
                              ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: HomeDashboardTheme.labelPrimary,
                        ),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: HomeDashboardTheme.sectionLabel,
                      ),
                      trailing: _trailingIcon(item.trailingType),
                    ),
                    if (index < items.length - 1)
                      Divider(
                        height: 0.5,
                        indent: 68.w,
                        endIndent: 16.w,
                        color: HomeDashboardTheme.separator,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _trailingIcon(String? type) {
    return switch (type) {
      'chat' => Icon(Icons.chat_bubble_outline, color: HomeDashboardTheme.accent, size: 20.sp),
      'phone' => Icon(Icons.phone_outlined, color: HomeDashboardTheme.accent, size: 20.sp),
      null => Icon(Icons.chevron_right, color: HomeDashboardTheme.labelTertiary, size: 20.sp),
      _ => Icon(Icons.chevron_right, color: HomeDashboardTheme.labelTertiary, size: 20.sp),
    };
  }
}

class HomeNewsList extends StatelessWidget {
  const HomeNewsList({super.key, required this.items});

  final List<HomeNewsItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('行业动态', style: HomeDashboardTheme.sectionTitle),
              ),
              Text(
                '查看更多',
                style: HomeDashboardTheme.sectionLabel.copyWith(
                  color: HomeDashboardTheme.accent,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: HomeDashboardTheme.accent,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.surface,
                  borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
                  border: Border.all(
                    color: HomeDashboardTheme.separator,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: HomeDashboardTheme.labelPrimary,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${item.source}  ${item.date}',
                              style: HomeDashboardTheme.sectionLabel,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: item.imageUrl != null
                            ? CacheImageUtils.network(
                                item.imageUrl!,
                                width: 96.w,
                                height: 72.h,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 96.w,
                                  height: 72.h,
                                  color: HomeDashboardTheme.fillSecondary,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 96.w,
                                  height: 72.h,
                                  color: HomeDashboardTheme.fillSecondary,
                                  child: Icon(
                                    Icons.article_outlined,
                                    color: HomeDashboardTheme.labelTertiary,
                                    size: 28.sp,
                                  ),
                                ),
                              )
                            : Container(
                                width: 96.w,
                                height: 72.h,
                                color: HomeDashboardTheme.fillSecondary,
                                child: Icon(
                                  Icons.article_outlined,
                                  color: HomeDashboardTheme.labelTertiary,
                                  size: 28.sp,
                                ),
                              ),
                      ),
                    ],
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
