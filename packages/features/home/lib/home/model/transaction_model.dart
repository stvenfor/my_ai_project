import 'package:module_http/api/result_model.dart';

class TransactionModel {
  const TransactionModel({
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as num).toInt(),
      userId: _readString(json['user_id'] ?? json['userId']),
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: json['date']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: _readString(json['created_at'] ?? json['createdAt']),
      updatedAt: _readString(json['updated_at'] ?? json['updatedAt']),
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    return value.toString();
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
}

typedef TransactionListResult = ResultModel<ListData<TransactionModel>>;
typedef TransactionDetailResult = ResultModel<TransactionModel>;
