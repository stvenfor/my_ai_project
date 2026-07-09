import 'package:module_home/home/model/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 通过 Supabase 直连 `transactions` 表（RLS 按当前登录用户隔离）。
class SupabaseTransactionDataSource {
  SupabaseTransactionDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const table = 'transactions';

  Future<List<TransactionModel>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    final rows = await _client
        .from(table)
        .select()
        .order('id', ascending: false)
        .range(from, to);
    return _parseRows(rows);
  }

  Future<TransactionModel> fetchById(int id) async {
    final row = await _client.from(table).select().eq('id', id).maybeSingle();
    if (row == null) {
      throw StateError('交易记录不存在');
    }
    return TransactionModel.fromJson(row);
  }

  List<TransactionModel> _parseRows(dynamic rows) {
    if (rows is! List) return const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList();
  }
}
