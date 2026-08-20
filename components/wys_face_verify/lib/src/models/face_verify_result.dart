class WysFaceVerifyResult {
  const WysFaceVerifyResult({
    required this.success,
    this.code,
    this.description,
    this.reason,
    this.orderNo,
  });

  final bool success;
  final String? code;
  final String? description;
  final String? reason;
  final String? orderNo;

  factory WysFaceVerifyResult.fromJson(Map<dynamic, dynamic>? json) {
    return WysFaceVerifyResult(
      success: json?['success'] == true,
      code: json?['code']?.toString(),
      description: json?['desc']?.toString(),
      reason: json?['reason']?.toString(),
      orderNo: json?['orderNo']?.toString(),
    );
  }

  String get message {
    final desc = description?.trim() ?? '';
    if (desc.isNotEmpty) return desc;
    final detail = reason?.trim() ?? '';
    if (detail.isNotEmpty) return detail;
    return '人脸核身未通过';
  }
}
