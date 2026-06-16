import 'dart:async';

import 'package:get/get.dart';
import 'package:module_core/model/auth/auth_session_state.dart';
import 'package:module_core/model/user.dart';
import 'package:module_core/service/user_service.dart';
import 'package:module_supabase/auth/supabase_auth_service.dart';
import 'package:module_supabase/mapper/supabase_user_mapper.dart';
import 'package:module_supabase/profile/supabase_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// 将 Supabase 会话同步到 [UserService.currentUser]。
class UserServiceBridge extends UserService implements SessionRefreshable {
  UserServiceBridge({
    required SupabaseAuthService authService,
    required SupabaseClient client,
  })  : _authService = authService,
        _client = client,
        _profiles = SupabaseProfileRepository(client);

  final SupabaseAuthService _authService;
  final SupabaseClient _client;
  final SupabaseProfileRepository _profiles;

  @override
  final Rxn<User> currentUser = Rxn<User>();

  Future<void> init() async {
    await _authService.bindAuthListener(_onAuthState);
    await refreshSession();
  }

  @override
  Future<void> refreshSession() async {
    await _restoreCurrentSession();
  }

  /// 供 [SupabaseAuthService] 在每次认证成功后立即同步。
  Future<void> syncFromCurrentSession() => refreshSession();

  Future<void> _restoreCurrentSession() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      currentUser.value = null;
      return;
    }
    await _syncFromSession(session);
  }

  Future<void> _onAuthState(AuthSessionState state) async {
    if (state == AuthSessionState.signedOut) {
      currentUser.value = null;
      return;
    }
    final session = _client.auth.currentSession;
    if (session != null) {
      await _syncFromSession(session);
    }
  }

  Future<void> _syncFromSession(Session session) async {
    Map<String, dynamic>? profile;
    try {
      profile = await _profiles.fetchByUserId(session.user.id);
    } catch (_) {
      profile = null;
    }
    currentUser.value = SupabaseUserMapper.toDomain(
      session: session,
      profile: profile,
    );
  }

  @override
  Future<void> setUser(User user) async {
    currentUser.value = user;
    await _profiles.upsertDisplayName(
      userId: user.id,
      displayName: user.name,
    );
  }

  @override
  Future<void> clearUser() async {
    await _authService.signOut();
    currentUser.value = null;
  }
}
