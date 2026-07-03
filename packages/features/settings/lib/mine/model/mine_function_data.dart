import 'package:flutter/material.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';

abstract final class MineFunctionData {
  static const catalog = <MineFunctionItem>[
    MineFunctionItem(
      id: 'sms',
      title: '短信模板',
      subtitle: '一键发送 轻松快捷',
      accentColor: Color(0xFFE8F8EF),
      iconColor: Color(0xFF52C41A),
      icon: Icons.sms_outlined,
    ),
    MineFunctionItem(
      id: 'calculator',
      title: '购车计算器',
      subtitle: '全款/贷款/保险全能算',
      accentColor: Color(0xFFE8F0FF),
      iconColor: Color(0xFF1890FF),
      icon: Icons.calculate_outlined,
    ),
    MineFunctionItem(
      id: 'used_car',
      title: '二手车',
      subtitle: '置换/专卖/估价',
      accentColor: Color(0xFFE8F0FF),
      iconColor: Color(0xFF1890FF),
      icon: Icons.directions_car_outlined,
    ),
    MineFunctionItem(
      id: 'short_video',
      title: '小视频',
      subtitle: '用小视频秀车秀店',
      accentColor: Color(0xFFF0E8FF),
      iconColor: Color(0xFF9254DE),
      icon: Icons.play_circle_outline,
    ),
    MineFunctionItem(
      id: 'after_sales',
      title: '售后专区',
      subtitle: '售后维修保养记录',
      accentColor: Color(0xFFFFF8E8),
      iconColor: Color(0xFFFAAD14),
      icon: Icons.build_outlined,
    ),
    MineFunctionItem(
      id: 'qr_pay',
      title: '店铺收款码',
      subtitle: '常见问题 功能介绍',
      accentColor: Color(0xFFE8F8EF),
      iconColor: Color(0xFF52C41A),
      icon: Icons.qr_code_2_outlined,
    ),
    MineFunctionItem(
      id: 'qa',
      title: '选买问答',
      subtitle: '在线解答客户问题',
      accentColor: Color(0xFFE8F0FF),
      iconColor: Color(0xFF1890FF),
      icon: Icons.support_agent_outlined,
    ),
    MineFunctionItem(
      id: 'poster',
      title: '商家海报',
      subtitle: '置换/专卖/估价',
      accentColor: Color(0xFFFFF8E8),
      iconColor: Color(0xFFFAAD14),
      icon: Icons.bar_chart_outlined,
    ),
  ];

  static const defaultOrderIds = [
    'sms',
    'calculator',
    'used_car',
    'short_video',
    'after_sales',
    'qr_pay',
    'qa',
    'poster',
  ];

  static final Map<String, MineFunctionItem> _catalogById = {
    for (final item in catalog) item.id: item,
  };

  static List<MineFunctionItem> resolveOrderedItems(List<String> ids) {
    final resolved = <MineFunctionItem>[];
    final seen = <String>{};

    for (final id in ids) {
      final item = _catalogById[id];
      if (item != null && seen.add(id)) {
        resolved.add(item);
      }
    }

    for (final item in catalog) {
      if (seen.add(item.id)) {
        resolved.add(item);
      }
    }

    return resolved;
  }
}
