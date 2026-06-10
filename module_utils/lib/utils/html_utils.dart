import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// HTML 渲染工具。
class HtmlUtils {
  HtmlUtils._();

  /// 渲染 HTML 字符串。
  static Widget build({
    required String data,
    Map<String, Style>? style,
    OnTap? onLinkTap,
    bool shrinkWrap = true,
  }) {
    return Html(
      data: data,
      style: style ?? _defaultStyle(),
      onLinkTap: onLinkTap,
      shrinkWrap: shrinkWrap,
    );
  }

  /// 简单文本样式 HTML。
  static Widget buildSimple(String data, {TextStyle? textStyle}) {
    return build(
      data: data,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(textStyle?.fontSize ?? 14),
          color: textStyle?.color,
          lineHeight: const LineHeight(1.5),
        ),
        'p': Style(margin: Margins.only(bottom: 8)),
        'a': Style(
          color: Colors.blue,
          textDecoration: TextDecoration.underline,
        ),
      },
    );
  }

  static Map<String, Style> _defaultStyle() {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(14),
        lineHeight: const LineHeight(1.5),
      ),
      'p': Style(margin: Margins.only(bottom: 8)),
      'a': Style(
        color: Colors.blue,
        textDecoration: TextDecoration.underline,
      ),
    };
  }
}
