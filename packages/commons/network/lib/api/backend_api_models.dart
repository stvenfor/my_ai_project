class BackendProfile {
  const BackendProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory BackendProfile.fromJson(Map<String, dynamic> json) {
    return BackendProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => {
        'display_name': displayName,
        'avatar_url': avatarUrl,
      };
}

class BackendTransaction {
  const BackendTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.userId,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory BackendTransaction.fromJson(Map<String, dynamic> json) {
    return BackendTransaction(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String?,
      type: json['type'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final int id;
  final String? userId;
  final String type;
  final String category;
  final double amount;
  final String date;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toCreateJson() => {
        'type': type,
        'category': category,
        'amount': amount,
        'date': date,
        if (note != null) 'note': note,
      };

  Map<String, dynamic> toUpdateJson() => {
        if (type.isNotEmpty) 'type': type,
        if (category.isNotEmpty) 'category': category,
        'amount': amount,
        if (date.isNotEmpty) 'date': date,
        if (note != null) 'note': note,
      };
}

class BackendTransactionList {
  const BackendTransactionList({required this.items});

  factory BackendTransactionList.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final list = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(BackendTransaction.fromJson)
            .toList()
        : <BackendTransaction>[];
    return BackendTransactionList(items: list);
  }

  final List<BackendTransaction> items;
}
