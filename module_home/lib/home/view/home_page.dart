import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/home_controller.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(HomeController.new);
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static const _gridEntries = [
    _HomeGridEntry(
      title: '学习报告',
      subtitle: '今日高光 · 学习记录',
      emoji: '📊',
      route: RoutePath.homeLearningReport,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            onPressed: controller.refreshBanners,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final showBannerError = controller.errorMessage.value != null &&
            controller.banners.isEmpty;
        final showBannerLoading =
            controller.isLoading.value && controller.banners.isEmpty;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Obx(
                () => Container(
                  margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 36.sp,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          controller.userGreeting.value,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Text(
                  '功能入口',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.35,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = _gridEntries[index];
                    return _HomeGridTile(
                      entry: entry,
                      onTap: () => Get.toNamed(entry.route),
                    );
                  },
                  childCount: _gridEntries.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
                child: Text(
                  'Banner',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (showBannerLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (showBannerError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.errorMessage.value!),
                      SizedBox(height: 12.h),
                      FilledButton(
                        onPressed: controller.refreshBanners,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              )
            else if (controller.banners.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('暂无 Banner 数据')),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                sliver: SliverList.separated(
                  itemCount: controller.banners.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final banner = controller.banners[index];
                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      title: Text(banner.title ?? 'Banner'),
                      subtitle: Text(banner.url ?? ''),
                      leading: banner.imagePath == null
                          ? const Icon(Icons.image_outlined)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                banner.imagePath!,
                                width: 48.w,
                                height: 48.w,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _HomeGridEntry {
  const _HomeGridEntry({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final String route;
}

class _HomeGridTile extends StatelessWidget {
  const _HomeGridTile({
    required this.entry,
    required this.onTap,
  });

  final _HomeGridEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.emoji, style: TextStyle(fontSize: 28.sp)),
              const Spacer(),
              Text(
                entry.title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                entry.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
