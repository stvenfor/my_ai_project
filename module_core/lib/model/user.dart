import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.token,
  });

  final String id;
  final String name;
  final String avatar;
  final String token;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'token': token,
      };

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, name, avatar, token];
}
