class LevelCardModel {
  const LevelCardModel({
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

class MineHttpTestArgs {
  MineHttpTestArgs({
    required this.level,
    required this.title,
    required this.collected,
    required this.total,
    required this.collecting,
    required this.locked,
  });

  factory MineHttpTestArgs.empty() {
    return MineHttpTestArgs(
      level: 1,
      title: 'Level 1 Starter',
      collected: 0,
      total: 120,
      collecting: false,
      locked: false,
    );
  }

  int level;
  String title;
  int collected;
  int total;
  bool collecting;
  bool locked;

  void updateFromRoute(Object? arguments) {
    if (arguments is! Map) return;
    level = arguments['level'] as int? ?? level;
    title = arguments['title']?.toString() ?? title;
    collected = arguments['collected'] as int? ?? collected;
    total = arguments['total'] as int? ?? total;
    collecting = arguments['collecting'] as bool? ?? collecting;
    locked = arguments['locked'] as bool? ?? locked;
  }
}
