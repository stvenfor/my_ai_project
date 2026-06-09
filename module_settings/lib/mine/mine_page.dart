import 'package:flutter/material.dart';
import 'package:module_route/route/route_path.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  static const List<_LevelCardData> _levels = [
    _LevelCardData(
      level: 1,
      title: 'Level 1 Starter',
      collected: 60,
      total: 120,
      collecting: true,
      locked: false,
    ),
    _LevelCardData(
      level: 2,
      title: 'Level 2 Mover',
      collected: 0,
      total: 120,
      locked: true,
    ),
    _LevelCardData(
      level: 3,
      title: 'Level 3 Flyer',
      collected: 0,
      total: 120,
      locked: true,
    ),
    _LevelCardData(
      level: 4,
      title: 'Level 4 Explorer',
      collected: 0,
      total: 120,
      locked: true,
    ),
    _LevelCardData(
      level: 5,
      title: 'Level 5 Pionter',
      collected: 0,
      total: 120,
      locked: true,
    ),
    _LevelCardData(
      level: 6,
      title: 'Level 6 Master',
      collected: 0,
      total: 120,
      locked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF5F4),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _MineHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 36),
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  return _LevelCard(
                    data: level,
                    onTap: () => _openTestPage(context, level),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 38),
                itemCount: _levels.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTestPage(BuildContext context, _LevelCardData level) {
    Navigator.pushNamed(
      context,
      RoutePath.mineHttpTest,
      arguments: level.toArguments(),
    );
  }
}

class _MineHeader extends StatelessWidget {
  const _MineHeader();

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
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 34,
              color: const Color(0xFF2F3034),
              onPressed: () => Navigator.maybePop(context),
              tooltip: '返回',
            ),
          ),
          const Text(
            'Level 1 知识卡片',
            style: TextStyle(
              color: Color(0xFF2B2D31),
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.data,
    required this.onTap,
  });

  final _LevelCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 146,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 0,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 24, 26, 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2E3034),
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (data.collecting) ...[
                            const SizedBox(width: 14),
                            const _CollectingTag(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFFA8ABAF),
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(text: '知识卡片收集进度：   '),
                            TextSpan(
                              text: '${data.collected}',
                              style: const TextStyle(
                                color: Color(0xFF313236),
                              ),
                            ),
                            TextSpan(text: '/${data.total}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (data.locked) ...[
                  const SizedBox(width: 18),
                  const Icon(
                    Icons.lock_rounded,
                    color: Color(0xFFDDE3E5),
                    size: 42,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectingTag extends StatelessWidget {
  const _CollectingTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE4FCE8),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Text(
        '收集中',
        style: TextStyle(
          color: Color(0xFF53D65B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LevelCardData {
  const _LevelCardData({
    required this.level,
    required this.title,
    required this.collected,
    required this.total,
    this.collecting = false,
    this.locked = false,
  });

  final int level;
  final String title;
  final int collected;
  final int total;
  final bool collecting;
  final bool locked;

  Map<String, dynamic> toArguments() {
    return {
      'level': level,
      'title': title,
      'collected': collected,
      'total': total,
      'collecting': collecting,
      'locked': locked,
    };
  }
}
