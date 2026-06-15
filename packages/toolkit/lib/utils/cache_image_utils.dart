import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 网络图片缓存工具（唯一依赖 cached_network_image 的文件）。
class CacheImageUtils {
  CacheImageUtils._();

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
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: placeholder,
      errorWidget: errorWidget,
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
