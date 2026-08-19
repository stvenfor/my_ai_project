import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/all_services_controller.dart';
import 'package:module_home/home/model/all_services_data.dart';
import 'package:module_home/home/model/all_services_model.dart';
import 'package:module_home/home/theme/all_services_theme.dart';
import 'package:module_home/home/view/widgets/all_services_section_widget.dart';

class AllServicesPage extends GetView<AllServicesController> {
  const AllServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AllServicesController>()) {
      AllServicesBinding().dependencies();
    }

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: AllServicesTheme.background,
      body: Column(
        children: [
          AppNavBar(
            title: '全部服务',
            showBackButton: false,
            onBack: () => Get.back<void>(),
            leading: GestureDetector(
              onTap: () => Get.back<void>(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Image.asset(
                  AllServicesAssets.path('nav_back_black.png'),
                  package: AllServicesAssets.package,
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            backgroundColor: AllServicesTheme.background,
            foregroundColor: AllServicesTheme.titleBlack,
          ),
          Expanded(
            child: Obx(() {
              final favoriteSection = AllServiceSection(
                title: AllServicesData.favoriteSectionMeta.title,
                subtitle: AllServicesData.favoriteSectionMeta.subtitle,
                showEditButton: true,
                items: controller.favoriteItems.toList(),
              );

              return ListView(
                padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                children: [
                  AllServicesSectionWidget(
                    section: favoriteSection,
                    isEditing: controller.isEditing.value,
                    isFavoriteSection: true,
                    favoriteIds: controller.favoriteIds,
                    canRemoveFavorite: controller.canRemoveFavorite,
                    onEditTap: controller.toggleEdit,
                    onRemoveFavorite: (item) => controller.removeFavorite(item.id),
                    onItemTap: controller.onServiceTap,
                  ),
                  for (final section in AllServicesData.catalogSections)
                    AllServicesSectionWidget(
                      section: section,
                      isEditing: controller.isEditing.value,
                      favoriteIds: controller.favoriteIds,
                      canAddFavorite: controller.canAddFavorite,
                      onAddFavorite: (item) => controller.addFavorite(item.id),
                      onItemTap: controller.onServiceTap,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
