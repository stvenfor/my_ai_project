import 'dart:typed_data';

import 'package:image/image.dart' as image_lib;

const int wechatThumbMaxBytes = 64 * 1024;
const int wechatThumbMaxSize = 150;

/// 将网络原图转换为微信网页分享要求的 JPEG 缩略图。
Uint8List? compressWechatThumb(Uint8List bytes) {
  if (bytes.isEmpty) return null;
  image_lib.Image? decoded;
  try {
    decoded = image_lib.decodeImage(bytes);
  } catch (_) {
    return null;
  }
  if (decoded == null || decoded.width <= 0 || decoded.height <= 0) {
    return null;
  }

  final oriented = image_lib.bakeOrientation(decoded);
  final width = oriented.width;
  final height = oriented.height;
  final scale = width > height
      ? wechatThumbMaxSize / width
      : wechatThumbMaxSize / height;
  final targetWidth = scale < 1
      ? (width * scale).round().clamp(1, width)
      : width;
  final targetHeight = scale < 1
      ? (height * scale).round().clamp(1, height)
      : height;
  final thumbnail = targetWidth == width && targetHeight == height
      ? oriented
      : image_lib.copyResize(
          oriented,
          width: targetWidth,
          height: targetHeight,
          interpolation: image_lib.Interpolation.average,
        );

  for (final quality in const [90, 80, 70, 60, 50, 40, 30]) {
    final encoded = image_lib.encodeJpg(thumbnail, quality: quality);
    if (encoded.isNotEmpty && encoded.length <= wechatThumbMaxBytes) {
      return Uint8List.fromList(encoded);
    }
  }
  return null;
}
