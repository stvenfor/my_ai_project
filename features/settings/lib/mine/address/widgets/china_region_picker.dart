import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';

class ChinaRegionNode {
  ChinaRegionNode({
    required this.code,
    required this.name,
    this.children = const [],
  });

  final String code;
  final String name;
  final List<ChinaRegionNode> children;

  factory ChinaRegionNode.fromJson(Map<String, dynamic> json) {
    final raw = json['children'];
    final kids = <ChinaRegionNode>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          kids.add(ChinaRegionNode.fromJson(e));
        } else if (e is Map) {
          kids.add(ChinaRegionNode.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return ChinaRegionNode(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      children: kids,
    );
  }
}

class ChinaRegionSelection {
  const ChinaRegionSelection({
    required this.province,
    required this.city,
    required this.district,
    required this.provinceCode,
    required this.cityCode,
    required this.districtCode,
  });

  final String province;
  final String city;
  final String district;
  final String provinceCode;
  final String cityCode;
  final String districtCode;

  String get label => '$province $city $district';
}

/// 加载真实 `china_pca.json`（省→市→区三级）。
class ChinaRegionData {
  ChinaRegionData._();

  static List<ChinaRegionNode>? _cache;

  static Future<List<ChinaRegionNode>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(
      'packages/module_settings/assets/regions/china_pca.json',
    );
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .whereType<Map>()
        .map((e) => ChinaRegionNode.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return _cache!;
  }
}

Future<ChinaRegionSelection?> showChinaRegionPicker(
  BuildContext context, {
  String? initialProvince,
  String? initialCity,
  String? initialDistrict,
}) async {
  final provinces = await ChinaRegionData.load();
  if (!context.mounted) return null;
  return showModalBottomSheet<ChinaRegionSelection>(
    context: context,
    backgroundColor: MineTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (_) => _ChinaRegionPickerSheet(
      provinces: provinces,
      initialProvince: initialProvince,
      initialCity: initialCity,
      initialDistrict: initialDistrict,
    ),
  );
}

class _ChinaRegionPickerSheet extends StatefulWidget {
  const _ChinaRegionPickerSheet({
    required this.provinces,
    this.initialProvince,
    this.initialCity,
    this.initialDistrict,
  });

  final List<ChinaRegionNode> provinces;
  final String? initialProvince;
  final String? initialCity;
  final String? initialDistrict;

  @override
  State<_ChinaRegionPickerSheet> createState() => _ChinaRegionPickerSheetState();
}

class _ChinaRegionPickerSheetState extends State<_ChinaRegionPickerSheet> {
  late int _p;
  late int _c;
  late int _d;
  late FixedExtentScrollController _pCtrl;
  late FixedExtentScrollController _cCtrl;
  late FixedExtentScrollController _dCtrl;

  List<ChinaRegionNode> get _cities =>
      widget.provinces.isEmpty ? const [] : widget.provinces[_p].children;

  List<ChinaRegionNode> get _districts =>
      _cities.isEmpty ? const [] : _cities[_c].children;

  @override
  void initState() {
    super.initState();
    _p = _indexByName(widget.provinces, widget.initialProvince);
    _c = _indexByName(_cities, widget.initialCity);
    _d = _indexByName(_districts, widget.initialDistrict);
    _pCtrl = FixedExtentScrollController(initialItem: _p);
    _cCtrl = FixedExtentScrollController(initialItem: _c);
    _dCtrl = FixedExtentScrollController(initialItem: _d);
  }

  int _indexByName(List<ChinaRegionNode> list, String? name) {
    if (name == null || name.isEmpty || list.isEmpty) return 0;
    final i = list.indexWhere((e) => e.name == name);
    return i < 0 ? 0 : i;
  }

  @override
  void dispose() {
    _pCtrl.dispose();
    _cCtrl.dispose();
    _dCtrl.dispose();
    super.dispose();
  }

  void _onProvince(int i) {
    setState(() {
      _p = i;
      _c = 0;
      _d = 0;
    });
    _cCtrl.jumpToItem(0);
    _dCtrl.jumpToItem(0);
  }

  void _onCity(int i) {
    setState(() {
      _c = i;
      _d = 0;
    });
    _dCtrl.jumpToItem(0);
  }

  void _confirm() {
    if (widget.provinces.isEmpty || _cities.isEmpty || _districts.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final p = widget.provinces[_p];
    final c = _cities[_c];
    final d = _districts[_d];
    Navigator.pop(
      context,
      ChinaRegionSelection(
        province: p.name,
        city: c.name,
        district: d.name,
        provinceCode: p.code,
        cityCode: c.code,
        districtCode: d.code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 320.h,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消', style: MineTheme.caption),
                  ),
                  const Spacer(),
                  Text('选择省市区', style: MineTheme.body.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: _confirm,
                    child: Text('确定', style: MineTheme.body.copyWith(color: MineTheme.accent)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _pCtrl,
                      itemExtent: 36,
                      onSelectedItemChanged: _onProvince,
                      children: [
                        for (final e in widget.provinces)
                          Center(child: Text(e.name, style: MineTheme.body)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _cCtrl,
                      itemExtent: 36,
                      onSelectedItemChanged: _onCity,
                      children: [
                        for (final e in _cities)
                          Center(child: Text(e.name, style: MineTheme.body)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _dCtrl,
                      itemExtent: 36,
                      onSelectedItemChanged: (i) => setState(() => _d = i),
                      children: [
                        for (final e in _districts)
                          Center(child: Text(e.name, style: MineTheme.body)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
