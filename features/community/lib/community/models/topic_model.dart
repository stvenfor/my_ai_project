class TopicModel {
  TopicModel({
    required this.id,
    required this.name,
    this.heat = 0,
    this.isAskEveryone = false,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      heat: (json['heat'] as num?)?.toInt() ?? 0,
      isAskEveryone: json['is_ask_everyone'] == true,
    );
  }

  final String id;
  final String name;
  final int heat;
  final bool isAskEveryone;

  /// 热度展示：≥1万用「x.x万」。
  String get heatLabel {
    if (heat >= 10000) {
      final wan = heat / 10000;
      final text = wan == wan.roundToDouble()
          ? wan.toInt().toString()
          : wan.toStringAsFixed(1);
      return '$text万';
    }
    return '$heat';
  }

  String get displayName => '#$name';
}
