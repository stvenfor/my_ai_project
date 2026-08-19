/// 弹框优先级：数值越小优先级越高。
enum DialogPriority {
  high(0),
  medium(1),
  low(2);

  const DialogPriority(this.weight);

  final int weight;

  String get label => switch (this) {
        DialogPriority.high => '高',
        DialogPriority.medium => '中',
        DialogPriority.low => '低',
      };
}
