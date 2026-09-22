import 'package:flutter_test/flutter_test.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_settings/mine/repository/mine_repository.dart';

void main() {
  test('stats map to mine labels in fixed order', () {
    const stats = UserStoreStats(
      daysJoined: 12,
      employeeCount: 4,
      storeDays: 30,
      totalCustomers: 9,
    );
    final models = MineRepository.statsToMineModels(stats);
    expect(models.map((e) => e.label).toList(), [
      '加入天数',
      '员工数',
      '店铺天数',
      '累计客户',
    ]);
    expect(models.map((e) => e.value).toList(), ['12', '4', '30', '9']);
  });

  test('parses stored store stats from profile envelope', () {
    final profile = UserProfile.fromJson({
      'id': 'a1111111-1111-4111-8111-111111111111',
      'displayName': 'Demo User',
      'stats': {
        'store_id': 1,
        'store_name': '[4S]北京沃德龙鼎吉利',
        'days_joined': 1028,
        'employee_count': 28,
        'store_days': 2059,
        'total_customers': 9366,
        'role': 1,
        'role_label': '销售经理',
      },
    });
    expect(profile.stats.storeId, 1);
    expect(profile.stats.role, 1);
    expect(profile.stats.roleLabel, '销售经理');
    final models = MineRepository.statsToMineModels(profile.stats);
    expect(models.map((e) => e.value).toList(), ['1028', '28', '2059', '9366']);
  });

  test('missing or negative stats become zero', () {
    final stats = UserStoreStats.fromJson({
      'days_joined': -1,
      'employee_count': '3',
    });
    expect(stats.daysJoined, 0);
    expect(stats.employeeCount, 3);
    expect(stats.storeDays, 0);
    expect(stats.totalCustomers, 0);
  });

  test('parses dealer store list envelope', () {
    final result = UserStoreListResult.fromJson({
      'current_store_id': 2,
      'list': [
        {
          'store_id': 1,
          'store_name': '[4S]北京沃德龙鼎吉利',
          'role': 0,
          'role_label': '销售顾问',
          'is_current': false,
        },
        {
          'store_id': 2,
          'store_name': '[4S]北京腾远吉利',
          'role': 1,
          'role_label': '销售经理',
          'is_current': true,
        },
      ],
    });
    expect(result.currentStoreId, 2);
    expect(result.list.length, 2);
    expect(result.list[1].isCurrent, isTrue);
    expect(result.list[1].storeName, '[4S]北京腾远吉利');
  });
}
