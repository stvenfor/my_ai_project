import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

/// 对齐 Android `RSAUtil.rsaEncode`：X509 公钥 + RSA/ECB/PKCS1Padding + Base64。
abstract final class WysRsaUtil {
  WysRsaUtil._();

  static String encode(String plainText, String publicKeyBase64) {
    final publicKey = _parsePublicKey(publicKeyBase64);
    final cipher = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final output = cipher.process(Uint8List.fromList(utf8.encode(plainText)));
    return base64.encode(output);
  }

  static RSAPublicKey _parsePublicKey(String publicKeyBase64) {
    final bytes = base64.decode(publicKeyBase64);
    final topLevelSeq = ASN1Parser(bytes).nextObject() as ASN1Sequence;
    final publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;
    final values = publicKeyBitString.stringValues;
    if (values == null || values.isEmpty) {
      throw ArgumentError('invalid public key');
    }
    final publicKeySeq =
        ASN1Parser(Uint8List.fromList(values)).nextObject() as ASN1Sequence;
    final modulus = (publicKeySeq.elements![0] as ASN1Integer).integer!;
    final exponent = (publicKeySeq.elements![1] as ASN1Integer).integer!;
    return RSAPublicKey(modulus, exponent);
  }
}
