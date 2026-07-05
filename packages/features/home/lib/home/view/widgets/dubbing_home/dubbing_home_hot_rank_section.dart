import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_hot_rank_card.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_section_header.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeHotRankSection extends GetView<DubbingHomeController> {
  const DubbingHomeHotRankSection({
    super.key,
    required this.boards,
    this.sectionKey,
  });

  final List<DubbingHomeHotRankBoard> boards;
  final Key? sectionKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DubbingHomeSectionHeader(title: '热榜'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < boards.length; i++) ...[
                  if (i > 0) SizedBox(width: 10.w),
                  Expanded(
                    child: DubbingHomeHotRankCard(
                      board: boards[i],
                      onViewAll: () => controller.onViewAllHotRank(boards[i]),
                      onItemTap: controller.onHotRankItemTap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
