enum WysPaymentMethod { wechat, alipay }

enum WysPaymentStatus {
  success,
  cancelled,
  processing,
  notInstalled,
  launchFailed,
  sdkError,
  timeout,
}

class WysPaymentResult {
  const WysPaymentResult({
    required this.status,
    this.code,
    this.message,
    this.rawResult,
  });

  final WysPaymentStatus status;
  final String? code;
  final String? message;
  final Map<String, dynamic>? rawResult;

  bool get isSuccess => status == WysPaymentStatus.success;
  bool get isCancelled => status == WysPaymentStatus.cancelled;
  bool get isProcessing => status == WysPaymentStatus.processing;
}
