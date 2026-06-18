class ImUserProfile {
  const ImUserProfile({
    required this.imUserId,
    required this.displayName,
    required this.avatarUrl,
    this.extra = const {},
  });

  final String imUserId;
  final String displayName;
  final String avatarUrl;
  final Map<String, dynamic> extra;

  ImUserProfile copyWith({
    String? imUserId,
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? extra,
  }) {
    return ImUserProfile(
      imUserId: imUserId ?? this.imUserId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      extra: extra ?? this.extra,
    );
  }
}
