import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_album_selection.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_banner_carousel.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_category_tabs.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_editor_picks.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_expert_showcase.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_feature_row.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_guess_you_like.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_header.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_hot_rank_section.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_recent_learning.dart';

class DubbingHomePage extends GetView<DubbingHomeController> {
  const DubbingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DubbingHomeController>()) {
      DubbingHomeBinding().dependencies();
    }

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: DubbingHomeTheme.background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final data = controller.feed.value;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final banners = data.banners.toList();
          final features = data.features.toList();
          final recentLearning = data.recentLearning.toList();
          final expertShowcase = data.expertShowcase.toList();
          final hotRankBoards = data.hotRankBoards.toList();
          final editorPicks = data.editorPicks.toList();
          final albums = data.albums.toList();
          final guessYouLike = data.guessYouLike.toList();

          return AppRefreshView(
            onRefresh: controller.refreshFeed,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: DubbingHomeHeader()),
                const SliverToBoxAdapter(child: DubbingHomeCategoryTabs()),
                SliverToBoxAdapter(
                  child: DubbingHomeBannerCarousel(banners: banners),
                ),
                SliverToBoxAdapter(
                  child: DubbingHomeFeatureRow(features: features),
                ),
                SliverToBoxAdapter(
                  child: DubbingHomeRecentLearning(items: recentLearning),
                ),
                SliverToBoxAdapter(
                  child: DubbingHomeExpertShowcase(items: expertShowcase),
                ),
                SliverToBoxAdapter(
                  child: DubbingHomeHotRankSection(
                    sectionKey: controller.hotRankSectionKey,
                    boards: hotRankBoards,
                  ),
                ),
                SliverToBoxAdapter(
                  child: DubbingHomeEditorPicks(items: editorPicks),
                ),
                SliverToBoxAdapter(
                  child: DubbingHomeAlbumSelection(albums: albums),
                ),
                SliverToBoxAdapter(
                  child: DubbingHomeGuessYouLike(items: guessYouLike),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
