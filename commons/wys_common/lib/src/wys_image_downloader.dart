import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

/// 图片下载 / 保存工具 —— 公共 API
///
/// - [downloadToCache]：下载到临时目录（供预览等场景）
/// - [saveFileToAlbum]：将本地图片文件写入系统相册（推荐，对齐泡泡页路径保存）
/// - [saveBytesToAlbum]：将图片字节写入系统相册（内部先落盘再走 [saveFileToAlbum]）
class WysImageDownloader {
  WysImageDownloader._();

  /// 下载图片到临时目录
  ///
  /// [url] 图片 URL。
  /// 返回保存的本地路径，失败返回 null。
  static Future<String?> downloadToCache(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = _extractFileName(url);
      final savePath = '${dir.path}/$fileName';
      await Dio().download(url, savePath);
      debugPrint('[WysImageDownloader] download success: $savePath');
      return savePath;
    } catch (e) {
      debugPrint('[WysImageDownloader] download failed: $e');
      return null;
    }
  }

  /// 将本地图片文件保存到系统相册。
  ///
  /// [filePath] 沙盒内可读绝对路径；[name] 可选相册文件名（可不含扩展名）。
  /// 成功返回 `true`。
  static Future<bool> saveFileToAlbum(
    String filePath, {
    String? name,
  }) async {
    final path = filePath.trim();
    if (path.isEmpty) return false;
    try {
      final file = File(path);
      if (!await file.exists() || await file.length() <= 0) {
        debugPrint('[WysImageDownloader] saveFileToAlbum missing: $path');
        return false;
      }
      final result = await ImageGallerySaverPlus.saveFile(
        path,
        name: name,
      );
      final ok = isAlbumSaveSuccess(result);
      debugPrint('[WysImageDownloader] saveFileToAlbum ok=$ok result=$result');
      return ok;
    } catch (e) {
      debugPrint('[WysImageDownloader] saveFileToAlbum failed: $e');
      return false;
    }
  }

  /// 将图片字节保存到系统相册。
  ///
  /// 优先落临时文件再走 [saveFileToAlbum]（避免部分平台对字节解码失败）；
  /// 失败时再尝试 `saveImage` 直传字节。
  static Future<bool> saveBytesToAlbum(
    Uint8List bytes, {
    String? name,
    int quality = 100,
  }) async {
    if (bytes.isEmpty) return false;

    final baseName = (name == null || name.trim().isEmpty)
        ? 'wys_${DateTime.now().millisecondsSinceEpoch}'
        : name.trim();
    final fileName = _ensureImageExt(baseName);

    try {
      final dir = await getTemporaryDirectory();
      final localPath = '${dir.path}/$fileName';
      final file = File(localPath);
      await file.writeAsBytes(bytes, flush: true);
      final viaFile = await saveFileToAlbum(
        localPath,
        name: fileName,
      );
      if (viaFile) return true;
    } catch (e) {
      debugPrint('[WysImageDownloader] saveBytesToAlbum via file failed: $e');
    }

    try {
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: quality.clamp(0, 100),
        name: fileName,
      );
      final ok = isAlbumSaveSuccess(result);
      debugPrint(
        '[WysImageDownloader] saveBytesToAlbum via bytes ok=$ok result=$result',
      );
      return ok;
    } catch (e) {
      debugPrint('[WysImageDownloader] saveBytesToAlbum failed: $e');
      return false;
    }
  }

  /// 解析插件返回值中的成功标记（兼容 Map / bool / 字符串）。
  @visibleForTesting
  static bool isAlbumSaveSuccess(dynamic result) {
    if (result == null) return false;
    if (result is bool) return result;
    if (result is Map) {
      final raw = result['isSuccess'] ??
          result['isSucess'] ??
          result['success'];
      if (raw is bool) return raw;
      if (raw is num) return raw != 0;
      if (raw is String) {
        final lower = raw.toLowerCase().trim();
        return lower == 'true' || lower == '1' || lower == 'success';
      }
      // 部分实现成功时只回 filePath。
      final path = result['filePath'] ?? result['file_path'];
      if (path is String && path.trim().isNotEmpty) return true;
      return false;
    }
    if (result is String) {
      final lower = result.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 'success') return true;
      // OHOS 偶发直接回文件路径字符串
      if (lower.contains('/') || lower.startsWith('file:')) return true;
      return false;
    }
    return false;
  }

  /// 从 URL 中提取文件名
  static String _extractFileName(String url) {
    final withoutQuery = url.split('?').first;
    final segments = withoutQuery.split('/');
    final raw = segments.isNotEmpty
        ? segments.last
        : 'image_${DateTime.now().millisecondsSinceEpoch}';
    return _ensureImageExt(raw.isEmpty ? 'image' : raw);
  }

  static String _ensureImageExt(String name) {
    final lower = name.toLowerCase();
    const exts = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.heic', '.bmp'];
    for (final ext in exts) {
      if (lower.endsWith(ext)) return name;
    }
    return '$name.jpg';
  }
}
