/// 用户资料 DTO（对齐 Go `ProfileItem` camelCase；`stats` 为 snake_case）。
class UserProfile {
  const UserProfile({
    required this.id,
    this.userId = '',
    this.userName = '',
    this.email = '',
    this.status = 0,
    this.displayName = '',
    this.avatarUrl = '',
    this.phone = '',
    this.stats = UserStoreStats.zero,
  });

  final String id;
  final String userId;
  final String userName;
  final String email;
  final int status;
  final String displayName;
  final String avatarUrl;
  final String phone;
  final UserStoreStats stats;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    final userId = json['user_id']?.toString() ?? '';
    final id = json['id']?.toString() ?? '';
    final userName = _stringOf(json['user_name'] ?? json['userName']);
    final displayName = _stringOf(json['displayName'] ?? json['display_name'] ?? json['username']);
    return UserProfile(
      id: id.isNotEmpty ? id : userId,
      userId: userId.isNotEmpty ? userId : id,
      userName: userName.isNotEmpty ? userName : displayName,
      email: _stringOf(json['email']),
      status: UserStoreStats._intOf(json['status']),
      displayName: displayName.isNotEmpty ? displayName : userName,
      avatarUrl: _stringOf(json['avatarUrl'] ?? json['avatar_url']),
      phone: _stringOf(json['phone']),
      stats: statsRaw is Map
          ? UserStoreStats.fromJson(Map<String, dynamic>.from(statsRaw))
          : UserStoreStats.zero,
    );
  }

  static String _stringOf(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}

/// GET `/api/v1/me/stores` 的 data。
class UserStoreListResult {
  const UserStoreListResult({
    required this.list,
    this.currentStoreId = 0,
  });

  final List<UserStoreListItem> list;
  final int currentStoreId;

  factory UserStoreListResult.fromJson(Map<String, dynamic> json) {
    final raw = json['list'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => UserStoreListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <UserStoreListItem>[];
    return UserStoreListResult(
      list: list,
      currentStoreId: UserStoreStats._intOf(json['current_store_id'] ?? json['currentStoreId']),
    );
  }
}

/// 可切换经销商一项。
class UserStoreListItem {
  const UserStoreListItem({
    required this.storeId,
    required this.storeName,
    this.role = 0,
    this.roleLabel = '',
    this.isCurrent = false,
  });

  final int storeId;
  final String storeName;
  final int role;
  final String roleLabel;
  final bool isCurrent;

  factory UserStoreListItem.fromJson(Map<String, dynamic> json) {
    final role = UserStoreStats._intOf(json['role']);
    final label = UserStoreStats._stringOf(json['role_label'] ?? json['roleLabel']);
    return UserStoreListItem(
      storeId: UserStoreStats._intOf(json['store_id'] ?? json['storeId']),
      storeName: UserStoreStats._stringOf(json['store_name'] ?? json['storeName']),
      role: role,
      roleLabel: label.isNotEmpty ? label : UserStoreStats.labelOfRole(role),
      isCurrent: json['is_current'] == true || json['isCurrent'] == true,
    );
  }
}

/// Mine 四项统计（对齐 Go `stats` snake_case）。
/// role: 0=销售顾问 1=销售经理 2=总经理
class UserStoreStats {
  const UserStoreStats({
    required this.daysJoined,
    required this.employeeCount,
    required this.storeDays,
    required this.totalCustomers,
    this.storeId = 0,
    this.storeName = '',
    this.role = 0,
    this.roleLabel = '销售顾问',
  });

  static const zero = UserStoreStats(
    daysJoined: 0,
    employeeCount: 0,
    storeDays: 0,
    totalCustomers: 0,
  );

  final int storeId;
  final String storeName;
  final int daysJoined;
  final int employeeCount;
  final int storeDays;
  final int totalCustomers;
  final int role;
  final String roleLabel;

  factory UserStoreStats.fromJson(Map<String, dynamic> json) {
    final role = _intOf(json['role']);
    final label = _stringOf(json['role_label'] ?? json['roleLabel']);
    return UserStoreStats(
      storeId: _intOf(json['store_id'] ?? json['storeId']),
      storeName: _stringOf(json['store_name'] ?? json['storeName']),
      daysJoined: _intOf(json['days_joined'] ?? json['daysJoined']),
      employeeCount: _intOf(json['employee_count'] ?? json['employeeCount']),
      storeDays: _intOf(json['store_days'] ?? json['storeDays']),
      totalCustomers: _intOf(json['total_customers'] ?? json['totalCustomers']),
      role: role,
      roleLabel: label.isNotEmpty ? label : labelOfRole(role),
    );
  }

  static String labelOfRole(int role) {
    switch (role) {
      case 1:
        return '销售经理';
      case 2:
        return '总经理';
      default:
        return '销售顾问';
    }
  }

  static String _stringOf(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static int _intOf(Object? value) {
    if (value is int) return value < 0 ? 0 : value;
    if (value is num) return value < 0 ? 0 : value.toInt();
    return int.tryParse(value?.toString() ?? '')?.clamp(0, 1 << 31) ?? 0;
  }
}

class UpdateUserProfileRequest {
  const UpdateUserProfileRequest({
    this.displayName,
    this.avatarBase64,
    this.avatarMime,
  });

  final String? displayName;
  final String? avatarBase64;
  final String? avatarMime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (displayName != null) {
      // Go ResolvedUserName：user_name 优先，display_name 兼容
      map['user_name'] = displayName;
      map['display_name'] = displayName;
    }
    if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      map['avatar_base64'] = avatarBase64;
      map['avatar_mime'] = avatarMime ?? 'image/jpeg';
    }
    return map;
  }
}
