import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 路径工具，封装 path_provider 常用目录。
class PathProviderUtils {
  PathProviderUtils._();

  /// 应用文档目录。
  static Future<String> get documentsPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// 应用缓存目录。
  static Future<String> get cachePath async {
    final dir = await getApplicationCacheDirectory();
    return dir.path;
  }

  /// 系统临时目录。
  static Future<String> get tempPath async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  /// 应用支持目录（iOS/macOS 等）。
  static Future<String> get supportPath async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  /// 在外部存储目录创建子目录（Android 等）。
  static Future<String?> externalStoragePath({String? subDir}) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return null;
    if (subDir == null || subDir.isEmpty) return dir.path;
    final target = Directory('${dir.path}/$subDir');
    if (!target.existsSync()) {
      await target.create(recursive: true);
    }
    return target.path;
  }

  /// 在文档目录下创建子目录，不存在则自动创建。
  static Future<String> createDocumentsSubDir(String subDir) async {
    final base = await documentsPath;
    final target = Directory('$base/$subDir');
    if (!target.existsSync()) {
      await target.create(recursive: true);
    }
    return target.path;
  }

  /// 在缓存目录下创建临时文件。
  static Future<File> createTempFile(String fileName) async {
    final base = await tempPath;
    return File('$base/$fileName');
  }
}
