import 'package:supabase_flutter/supabase_flutter.dart';

/// profiles 表读写（RLS 保护）。
class SupabaseProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const table = 'profiles';

  Future<Map<String, dynamic>?> fetchByUserId(String userId) async {
    final row = await _client
        .from(table)
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row;
  }

  Future<void> upsertDisplayName({
    required String userId,
    required String displayName,
  }) async {
    await _client.from(table).upsert({
      'id': userId,
      'display_name': displayName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
