import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_lib;
import 'package:wys_login_share_pay/src/wys_wechat_thumb.dart';

void main() {
  test('压缩大图为微信限制内的缩略图', () {
    final source = image_lib.Image(width: 1200, height: 800);
    image_lib.fill(source, color: image_lib.ColorRgb8(230, 80, 60));
    final bytes = Uint8List.fromList(image_lib.encodePng(source));

    final compressed = compressWechatThumb(bytes);

    expect(compressed, isNotNull);
    expect(compressed!.length, lessThanOrEqualTo(wechatThumbMaxBytes));
    final decoded = image_lib.decodeJpg(compressed);
    expect(decoded, isNotNull);
    expect(decoded!.width, lessThanOrEqualTo(wechatThumbMaxSize));
    expect(decoded.height, lessThanOrEqualTo(wechatThumbMaxSize));
  });

  test('无效图片返回空结果', () {
    expect(compressWechatThumb(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
