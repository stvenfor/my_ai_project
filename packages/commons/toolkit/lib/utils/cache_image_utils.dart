import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 网络图片缓存工具（唯一依赖 cached_network_image 的文件）。
class CacheImageUtils {
  CacheImageUtils._();

  static bool isValidNetworkUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Widget _fallback({
    double? width,
    double? height,
    IconData icon = Icons.person,
  }) {
    final w = width ?? height ?? 48;
    final h = height ?? width ?? 48;
    return Container(
      width: w,
      height: h,
      color: const Color(0xFFE0E0E0),
      alignment: Alignment.center,
      child: Icon(icon, size: (w * 0.45).clamp(16, 32), color: Colors.grey),
    );
  }

  static Widget network(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    Color? color,
    BlendMode? colorBlendMode,
    BorderRadius? borderRadius,
  }) {
    if (!isValidNetworkUrl(url)) {
      return _fallback(width: width, height: height);
    }

    Widget image = CachedNetworkImage(
      imageUrl: url.trim(),
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: placeholder ??
          (_, __) => _fallback(width: width, height: height),
      errorWidget: errorWidget ??
          (_, __, ___) => _fallback(width: width, height: height),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius, child: image);
    }
    return image;
  }

  static Widget circle(
    String url, {
    double? size,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
  }) {
    final dimension = size ?? 48;
    return ClipOval(
      child: network(
        url,
        width: dimension,
        height: dimension,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}
