enum WysWechatStatus {
  success,
  cancelled,
  notInstalled,
  launchFailed,
  sdkError,
  timeout,
}

enum WysWechatScene { session, timeline }

class WysWechatResult {
  const WysWechatResult({
    required this.status,
    this.code,
    this.message,
    this.authCode,
  });

  final WysWechatStatus status;
  final int? code;
  final String? message;
  final String? authCode;

  bool get isSuccess => status == WysWechatStatus.success;
  bool get isCancelled => status == WysWechatStatus.cancelled;

  static WysWechatResult fromSdkCode(int? code, {String? message}) {
    if (code == 0) {
      return WysWechatResult(
        status: WysWechatStatus.success,
        code: code,
        message: message,
      );
    }
    if (code == -2) {
      return WysWechatResult(
        status: WysWechatStatus.cancelled,
        code: code,
        message: message,
      );
    }
    return WysWechatResult(
      status: WysWechatStatus.sdkError,
      code: code,
      message: message,
    );
  }
}

class WysWechatPayParams {
  const WysWechatPayParams({
    required this.appId,
    required this.partnerId,
    required this.prepayId,
    required this.packageValue,
    required this.nonceStr,
    required this.timestamp,
    required this.sign,
    this.signType,
    this.extData,
  });

  final String appId;
  final String partnerId;
  final String prepayId;
  final String packageValue;
  final String nonceStr;
  final int timestamp;
  final String sign;
  final String? signType;
  final String? extData;

  factory WysWechatPayParams.fromMap(Map<String, dynamic> map) {
    String readString(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
      return '';
    }

    final timestampText = readString(['timestamp', 'timeStamp']);
    return WysWechatPayParams(
      appId: readString(['appid', 'appId']),
      partnerId: readString(['partnerid', 'partnerId']),
      prepayId: readString(['prepayid', 'prepayId']),
      packageValue: readString(['package', 'packageValue']),
      nonceStr: readString(['noncestr', 'nonceStr']),
      timestamp: int.tryParse(timestampText) ?? 0,
      sign: readString(['sign']),
      signType: readString(['signType']),
      extData: readString(['extData']),
    );
  }

  bool get isValid =>
      appId.isNotEmpty &&
      partnerId.isNotEmpty &&
      prepayId.isNotEmpty &&
      packageValue.isNotEmpty &&
      nonceStr.isNotEmpty &&
      timestamp > 0 &&
      sign.isNotEmpty;
}
