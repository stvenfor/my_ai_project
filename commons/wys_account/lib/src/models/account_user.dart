/// 登录用户快照，各业务 module 只读使用。
class AccountUser {
  const AccountUser({
    this.userId,
    this.token,
    this.nickname,
    this.avatarUrl,
    this.phone,
    this.extra,
  });

  final String? userId;
  final String? token;
  final String? nickname;
  final String? avatarUrl;
  final String? phone;

  /// 业务扩展字段（如 memberLevel、starId 等）
  final Map<String, dynamic>? extra;

  bool get hasValidToken => token != null && token!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'token': token,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'phone': phone,
        'extra': extra,
      };

  factory AccountUser.fromJson(Map<String, dynamic> json) {
    return AccountUser(
      userId: json['userId'] as String?,
      token: json['token'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      extra: json['extra'] is Map
          ? Map<String, dynamic>.from(json['extra'] as Map)
          : null,
    );
  }

  AccountUser copyWith({
    String? userId,
    String? token,
    String? nickname,
    String? avatarUrl,
    String? phone,
    Map<String, dynamic>? extra,
  }) {
    return AccountUser(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      extra: extra ?? this.extra,
    );
  }
}