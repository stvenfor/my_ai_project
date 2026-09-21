import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.token,
    this.refreshToken = '',
    this.sessionId = '',
    this.deviceId = '',
    this.phoneMasked = '',
  });

  final String id;
  final String name;
  final String avatar;
  final String token;
  final String refreshToken;
  final String sessionId;
  final String deviceId;

  /// 脱敏手机号（只读展示）；空表示后端未提供。
  final String phoneMasked;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      phoneMasked: json['phoneMasked'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'token': token,
        'refreshToken': refreshToken,
        'sessionId': sessionId,
        'deviceId': deviceId,
        'phoneMasked': phoneMasked,
      };

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    String? token,
    String? refreshToken,
    String? sessionId,
    String? deviceId,
    String? phoneMasked,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      sessionId: sessionId ?? this.sessionId,
      deviceId: deviceId ?? this.deviceId,
      phoneMasked: phoneMasked ?? this.phoneMasked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatar,
        token,
        refreshToken,
        sessionId,
        deviceId,
        phoneMasked,
      ];
}
