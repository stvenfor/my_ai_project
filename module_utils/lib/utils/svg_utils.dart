import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG 图片工具。
class SvgUtils {
  SvgUtils._();

  /// 加载 assets SVG。
  static Widget asset(
    String assetName, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    String? package,
  }) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      package: package,
    );
  }

  /// 加载网络 SVG。
  static Widget network(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    Widget Function(BuildContext)? placeholder,
    Widget Function(BuildContext, Object, StackTrace?)? errorWidget,
  }) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: placeholder,
      errorBuilder: errorWidget,
    );
  }

  /// 加载本地文件 SVG。
  static Widget file(
    String filePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return SvgPicture.file(
      File(filePath),
      width: width,
      height: height,
      fit: fit,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
