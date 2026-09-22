import 'package:module_home/home/model/home_todo_models.dart';

/// 将有序待办卡装入 2×2 页（每页容量 4 格）。
class HomeTodoPacker {
  const HomeTodoPacker._();

  /// 是否单行包裹、不启用左右滑：全小卡且数量 ≤ 2。
  static bool shouldWrapOnly(List<HomeTodoCard> cards) {
    if (cards.isEmpty) return true;
    if (cards.length > 2) return false;
    return cards.every((c) => c.size == HomeTodoSize.small);
  }

  static List<List<HomeTodoCard>> packPages(List<HomeTodoCard> cards) {
    if (cards.isEmpty) return const [];
    final pages = <List<HomeTodoCard>>[];
    var current = <HomeTodoCard>[];
    var used = 0;

    void flush() {
      if (current.isEmpty) return;
      pages.add(List<HomeTodoCard>.from(current));
      current = <HomeTodoCard>[];
      used = 0;
    }

    for (final card in cards) {
      final need = card.size.cells;
      if (need == 4 && used > 0) {
        flush();
      }
      if (used + need > 4) {
        flush();
      }
      current.add(card);
      used += need;
      if (used >= 4) {
        flush();
      }
    }
    flush();
    return pages;
  }
}
