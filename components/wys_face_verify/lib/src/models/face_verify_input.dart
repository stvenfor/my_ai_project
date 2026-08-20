/// 腾讯云慧眼人脸核身 SDK 的一次性输入参数。
///
/// `userid`、`orderNo`、`version`、`sign`、`nonce` 和 `faceId` 必须来自
/// 同一次业务后端响应，客户端不能自行生成或替换。
class WysFaceVerifyInput {
  const WysFaceVerifyInput({
    required this.userid,
    required this.orderNo,
    required this.version,
    required this.sign,
    required this.nonce,
    required this.faceId,
  });

  final String userid;
  final String orderNo;
  final String version;
  final String sign;
  final String nonce;
  final String faceId;

  factory WysFaceVerifyInput.fromJson(Map<String, dynamic> json) {
    return WysFaceVerifyInput(
      userid: json['userid']?.toString() ?? '',
      orderNo: json['orderNo']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      sign: json['sign']?.toString() ?? '',
      nonce: json['nonce']?.toString() ?? '',
      faceId: json['faceId']?.toString() ?? '',
    );
  }

  bool get isComplete =>
      userid.isNotEmpty &&
      orderNo.isNotEmpty &&
      version.isNotEmpty &&
      sign.isNotEmpty &&
      nonce.isNotEmpty &&
      faceId.isNotEmpty;
}
