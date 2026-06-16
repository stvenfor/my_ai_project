import 'package:module_settings/mine/model/mine_stat_model.dart';

class MineProfileModel {
  const MineProfileModel({
    required this.displayName,
    required this.avatarUrl,
    required this.roleBadge,
    required this.storeName,
    required this.maskedPhone,
    required this.stats,
  });

  final String displayName;
  final String? avatarUrl;
  final String roleBadge;
  final String storeName;
  final String maskedPhone;
  final List<MineStatModel> stats;

  static const guestStats = [
    MineStatModel(value: '0', label: '加入天数'),
    MineStatModel(value: '0', label: '员工数'),
    MineStatModel(value: '0', label: '店铺天数'),
    MineStatModel(value: '0', label: '累计客户'),
  ];

  static const demoStats = [
    MineStatModel(value: '1028', label: '加入天数'),
    MineStatModel(value: '28', label: '员工数'),
    MineStatModel(value: '2059', label: '店铺天数'),
    MineStatModel(value: '9366', label: '累计客户'),
  ];
}
