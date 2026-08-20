import 'package:flutter_test/flutter_test.dart';
import 'package:wys_common/src/wys_image_downloader.dart';

void main() {
  group('WysImageDownloader.isAlbumSaveSuccess', () {
    test('Map isSuccess bool / typo / path', () {
      expect(
        WysImageDownloader.isAlbumSaveSuccess({'isSuccess': true}),
        isTrue,
      );
      expect(
        WysImageDownloader.isAlbumSaveSuccess({'isSuccess': false}),
        isFalse,
      );
      expect(
        WysImageDownloader.isAlbumSaveSuccess({'isSucess': true}),
        isTrue,
      );
      expect(
        WysImageDownloader.isAlbumSaveSuccess({
          'filePath': 'file:///tmp/a.jpg',
        }),
        isTrue,
      );
    });

    test('bool / string / null', () {
      expect(WysImageDownloader.isAlbumSaveSuccess(true), isTrue);
      expect(WysImageDownloader.isAlbumSaveSuccess(false), isFalse);
      expect(WysImageDownloader.isAlbumSaveSuccess('true'), isTrue);
      expect(WysImageDownloader.isAlbumSaveSuccess(null), isFalse);
    });
  });
}
