import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';
import 'package:module_home/new_car_follow/viewmodel/new_car_follow_list_viewmodel.dart';
import 'package:wys_router/src/route/route_path.dart';

class NewCarFollowListPage extends GetView<NewCarFollowListViewModel> {
  const NewCarFollowListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: AppNavBar(
        title: '新车跟进',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () async {
              final ok = await Get.toNamed(RoutePath.homeNewCarFollowCreate);
              if (ok == true) controller.refreshAll();
            },
            child: const Text('建档'),
          ),
        ],
      ),
      body: Obx(() {
        final sum = controller.summary.value;
        return Column(
          children: [
            if (sum != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${sum.displayName} · ${sum.positionLabel}'),
                    Text(sum.storeName, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      '跟进中 ${sum.stats.active} · 逾期 ${sum.stats.overdue} · '
                      '高意向 ${sum.stats.highIntent} · 战败 ${sum.stats.lost}',
                    ),
                  ],
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (var i = 0; i < NewCarFollowTab.values.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(NewCarFollowTab.values[i].label),
                        selected: controller.tabIndex.value == i,
                        onSelected: (_) => controller.switchTab(i),
                      ),
                    ),
                ],
              ),
            ),
            if (controller.error.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(controller.error.value, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshAll,
                child: ListView.separated(
                  itemCount: controller.items.length + (controller.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i >= controller.items.length) {
                      controller.loadMore();
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = controller.items[i];
                    return ListTile(
                      title: Text('${item.customerName} · ${item.followLevel}/${item.intentBand}'),
                      subtitle: Text('${item.customerPhone} · ${item.vehicleInterest}'),
                      onTap: () => Get.toNamed(
                        RoutePath.homeNewCarFollowDetail,
                        arguments: item.fileId,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
