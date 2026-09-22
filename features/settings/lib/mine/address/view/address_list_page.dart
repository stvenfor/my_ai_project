import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/mine/address/controller/address_list_controller.dart';
import 'package:module_settings/mine/address/model/address_model.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';

class AddressListPage extends GetView<AddressListController> {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.standard,
      backgroundColor: MineTheme.background,
      navBar: AppNavBar(
        title: controller.chooseMode ? '选择收货地址' : '收货地址',
        showBackButton: true,
        backgroundColor: MineTheme.surface,
        foregroundColor: MineTheme.labelPrimary,
        actions: [
          TextButton(
            onPressed: () => controller.openEdit(),
            child: Text('新增', style: TextStyle(color: MineTheme.accent)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final err = controller.errorMessage.value;
        if (err.isNotEmpty && controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(err, style: MineTheme.caption),
                TextButton(onPressed: controller.load, child: const Text('重试')),
              ],
            ),
          );
        }
        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('暂无地址', style: MineTheme.caption),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () => controller.openEdit(),
                  child: const Text('添加收货地址'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            itemCount: controller.items.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (_, i) => _AddressTile(
              item: controller.items[i],
              chooseMode: controller.chooseMode,
              onTap: () => controller.onTap(controller.items[i]),
              onDefault: () => controller.setDefault(controller.items[i]),
              onDelete: () => controller.delete(controller.items[i]),
            ),
          ),
        );
      }),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.item,
    required this.chooseMode,
    required this.onTap,
    required this.onDefault,
    required this.onDelete,
  });

  final AddressModel item;
  final bool chooseMode;
  final VoidCallback onTap;
  final VoidCallback onDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MineTheme.surface,
      borderRadius: BorderRadius.circular(MineTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MineTheme.radiusMd),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MineTheme.radiusMd),
            border: Border.all(color: MineTheme.separator),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.receiverName}  ${item.receiverPhone}',
                      style: MineTheme.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (item.isDefault)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3E5FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '默认',
                        style: MineTheme.caption.copyWith(color: MineTheme.accent),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                item.fullAddress.isEmpty ? item.detailAddress : item.fullAddress,
                style: MineTheme.caption,
              ),
              if (!chooseMode) ...[
                SizedBox(height: 10.h),
                Row(
                  children: [
                    if (!item.isDefault)
                      TextButton(
                        onPressed: onDefault,
                        child: Text('设为默认', style: TextStyle(color: MineTheme.accent, fontSize: 13)),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: onDelete,
                      child: Text('删除', style: TextStyle(color: MineTheme.labelTertiary, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
