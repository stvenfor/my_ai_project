import 'package:flutter/material.dart';
import 'package:module_community/community/models/post_model.dart';
import 'package:module_community/community/theme/community_theme.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_utils/module_utils.dart';

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CacheImageUtils.circle(post.avatar, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.nickname, style: CommunityTheme.headline),
              const SizedBox(height: 2),
              Text(
                '${CommunityViewModel.formatPublishTime(post.publishTime)} · ${post.source}',
                style: CommunityTheme.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
