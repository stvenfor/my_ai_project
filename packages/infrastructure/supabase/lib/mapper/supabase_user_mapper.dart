import 'package:module_core/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class SupabaseUserMapper {
  SupabaseUserMapper._();

  static User toDomain({
    required Session session,
    Map<String, dynamic>? profile,
  }) {
    final metadata = session.user.userMetadata ?? {};
    final phone = session.user.phone;
    final phoneSuffix = phone != null && phone.length >= 4
        ? phone.substring(phone.length - 4)
        : null;
    final displayName = profile?['display_name'] as String? ??
        metadata['display_name'] as String? ??
        (phoneSuffix != null ? '用户$phoneSuffix' : null) ??
        session.user.email?.split('@').first ??
        '用户';

    return User(
      id: session.user.id,
      name: displayName,
      avatar: profile?['avatar_url'] as String? ?? '',
      token: session.accessToken,
    );
  }
}
