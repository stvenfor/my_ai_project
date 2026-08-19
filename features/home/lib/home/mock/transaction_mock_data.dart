import 'package:module_home/home/model/transaction_model.dart';

/// Mock 认证 / 离线演示用交易数据。
abstract final class TransactionMockData {
  static const pageSize = 20;

  static final _all = <TransactionModel>[
    TransactionModel(
      id: 1,
      type: 'income',
      category: '宝马 320Li',
      amount: 228000,
      date: '2024-05-10',
      note: '一手车，全程4S保养',
    ),
    TransactionModel(
      id: 2,
      type: 'expense',
      category: '奥迪 A4L',
      amount: 185000,
      date: '2024-05-08',
      note: '置换收购，待整备',
    ),
    TransactionModel(
      id: 3,
      type: 'income',
      category: '丰田 凯美瑞',
      amount: 168000,
      date: '2024-05-05',
      note: '2021款 2.0G 豪华版',
    ),
  ];

  static List<TransactionModel> page(int page) {
    final start = page * pageSize;
    if (start >= _all.length) return const [];
    final end = (start + pageSize).clamp(0, _all.length);
    return _all.sublist(start, end);
  }

  static TransactionModel? byId(int id) {
    for (final item in _all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
