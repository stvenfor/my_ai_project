import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.token,
    this.sessionId = '',
    this.deviceId = '',
  });

  final String id;
  final String name;
  final String avatar;
  final String token;
  final String sessionId;
  final String deviceId;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      token: json['token'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'token': token,
        'sessionId': sessionId,
        'deviceId': deviceId,
      };

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    String? token,
    String? sessionId,
    String? deviceId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
      sessionId: sessionId ?? this.sessionId,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  List<Object?> get props => [id, name, avatar, token, sessionId, deviceId];
}
