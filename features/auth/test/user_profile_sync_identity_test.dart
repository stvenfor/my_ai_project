import 'package:flutter_test/flutter_test.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_auth/session/user_profile_sync.dart';
import 'package:module_core/core.dart';

void main() {
  group('UserProfileSync.mergeProfile', () {
    const current = User(
      id: 'user-b',
      name: '测试乙',
      avatar: 'https://a/b.png',
      token: 'tok-b',
      phoneMasked: '134****0001',
    );

    test('keeps identity when profile belongs to same user', () {
      final merged = UserProfileSync.mergeProfile(
        current,
        const UserProfile(
          id: 'user-b',
          userId: 'user-b',
          displayName: '测试乙改名',
          phone: '13400000001',
          avatarUrl: 'https://a/new.png',
        ),
      );
      expect(merged.id, 'user-b');
      expect(merged.name, '测试乙改名');
      expect(merged.phoneMasked, '134****0001');
      expect(merged.avatar, 'https://a/new.png');
    });

    test('rejects mismatched profile instead of switching account', () {
      final merged = UserProfileSync.mergeProfile(
        current,
        const UserProfile(
          id: 'user-a',
          userId: 'user-a',
          displayName: '测试甲',
          phone: '13400000000',
          avatarUrl: 'https://evil.png',
        ),
      );
      expect(merged.id, 'user-b');
      expect(merged.name, '测试乙');
      expect(merged.phoneMasked, '134****0001');
      expect(merged.avatar, 'https://a/b.png');
    });
  });

  group('UserProfileSync.maskPhone', () {
    test('masks eleven-digit phones', () {
      expect(UserProfileSync.maskPhone('13400000001'), '134****0001');
      expect(UserProfileSync.maskPhone('+8613400000000'), '134****0000');
    });
  });
}
