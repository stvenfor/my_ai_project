import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_settings/mine/api/mine_http_config.dart';
import 'package:module_settings/mine/model/harmony_index_model.dart';
import 'package:module_settings/mine/viewmodel/mine_http_test_viewmodel.dart';

class MineHttpTestPage extends GetView<MineHttpTestViewModel> {
  const MineHttpTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF5F4),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _TestHeader(
              title: controller.args.title,
              onBack: () => Get.back<void>(),
              onRefresh: controller.loadData,
            ),
            Expanded(
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  children: [
                    _RequestInfoCard(
                      baseUrl: MineHttpConfig.baseUrl,
                      path: MineHttpConfig.harmonyIndexPath,
                      loadState: controller.loadState.value,
                      level: controller.args.level,
                      loadedAt: controller.loadedAt.value,
                      articleCount: controller.indexModel.value?.totalArticleCount,
                    ),
                    const SizedBox(height: 20),
                    if (controller.loadState.value == MineLoadState.loading)
                      const _LoadingPanel()
                    else if (controller.loadState.value == MineLoadState.error)
                      _ErrorPanel(
                        message: controller.errorMessage.value ?? '请求失败',
                        onRetry: controller.loadData,
                      )
                    else ...[
                      if (controller.args.level >= 4)
                        _OverviewBanner(model: controller.indexModel.value!),
                      ...controller.visibleSections.map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _SectionBlock(section: section),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestHeader extends StatelessWidget {
  const _TestHeader({
    required this.title,
    required this.onBack,
    required this.onRefresh,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 114,
      color: Colors.white,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 34,
              color: const Color(0xFF2F3034),
              onPressed: onBack,
              tooltip: '返回',
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2B2D31),
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          Positioned(
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              iconSize: 30,
              color: const Color(0xFF53D65B),
              onPressed: onRefresh,
              tooltip: '重新请求',
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestInfoCard extends StatelessWidget {
  const _RequestInfoCard({
    required this.baseUrl,
    required this.path,
    required this.loadState,
    required this.level,
    this.loadedAt,
    this.articleCount,
  });

  final String baseUrl;
  final String path;
  final MineLoadState loadState;
  final int level;
  final DateTime? loadedAt;
  final int? articleCount;

  @override
  Widget build(BuildContext context) {
    final status = switch (loadState) {
      MineLoadState.loading => _StatusInfo('请求中', const Color(0xFFFFB020)),
      MineLoadState.success => _StatusInfo('请求成功', const Color(0xFF53D65B)),
      MineLoadState.error => _StatusInfo('请求失败', const Color(0xFFFF6B6B)),
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F3034), Color(0xFF43464D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      loadState == MineLoadState.loading
                          ? Icons.sync_rounded
                          : loadState == MineLoadState.success
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                      size: 18,
                      color: status.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.label,
                      style: TextStyle(
                        color: status.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Level $level',
                style: const TextStyle(
                  color: Color(0xFFB8BBC0),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'BaseUrl', value: baseUrl),
          const SizedBox(height: 10),
          _InfoRow(label: 'Path', value: path),
          if (loadedAt != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              label: '完成时间',
              value:
                  '${loadedAt!.hour.toString().padLeft(2, '0')}:${loadedAt!.minute.toString().padLeft(2, '0')}:${loadedAt!.second.toString().padLeft(2, '0')}',
            ),
          ],
          if (articleCount != null) ...[
            const SizedBox(height: 10),
            _InfoRow(label: '资源总数', value: '$articleCount 条'),
          ],
        ],
      ),
    );
  }
}

class _StatusInfo {
  const _StatusInfo(this.label, this.color);

  final String label;
  final Color color;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9EA2A8),
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF53D65B),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '正在验证网络请求...',
            style: TextStyle(
              color: Color(0xFF6B7078),
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: Color(0xFFFF6B6B),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7078),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF53D65B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewBanner extends StatelessWidget {
  const _OverviewBanner({required this.model});

  final HarmonyIndexModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE4FCE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.hub_rounded, color: Color(0xFF53D65B), size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '已加载 ${model.allSections.length} 个分类，共 ${model.totalArticleCount} 条鸿蒙资源',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final HarmonySectionModel section;

  @override
  Widget build(BuildContext context) {
    final articles = section.articleList ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF53D65B),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                section.name ?? '未命名分类',
                style: const TextStyle(
                  color: Color(0xFF2E3034),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${articles.length} 条',
              style: const TextStyle(
                color: Color(0xFFA8ABAF),
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...articles.map(
          (article) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ArticleCard(article: article),
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final HarmonyArticleModel article;

  void _showLinkDialog(BuildContext context) {
    final link = article.link?.trim();
    if (link == null || link.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('资源链接'),
        content: SelectableText(link),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('链接已复制')),
              );
            },
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desc = article.desc?.trim();
    final link = article.link?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: link == null || link.isEmpty
            ? null
            : () => _showLinkDialog(context),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title ?? '未命名资源',
                style: const TextStyle(
                  color: Color(0xFF2E3034),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              if (desc != null && desc.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8E9197),
                    fontSize: 18,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (article.chapterName?.isNotEmpty == true)
                    _TagChip(
                      icon: Icons.folder_outlined,
                      label: article.chapterName!,
                    ),
                  if (article.author?.isNotEmpty == true)
                    _TagChip(
                      icon: Icons.person_outline_rounded,
                      label: article.author!,
                    ),
                  if (article.niceDate?.isNotEmpty == true)
                    _TagChip(
                      icon: Icons.schedule_rounded,
                      label: article.niceDate!,
                    ),
                ],
              ),
              if (link != null && link.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link_rounded,
                        size: 18,
                        color: Color(0xFF53D65B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          link,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF5C6168),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFB8BBC0),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8E9197)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7078),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
