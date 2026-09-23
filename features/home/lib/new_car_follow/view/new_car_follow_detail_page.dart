import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/new_car_follow/api/new_car_follow_api.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';

class NewCarFollowDetailPage extends StatefulWidget {
  const NewCarFollowDetailPage({super.key});

  @override
  State<NewCarFollowDetailPage> createState() => _NewCarFollowDetailPageState();
}

class _NewCarFollowDetailPageState extends State<NewCarFollowDetailPage> {
  final _api = NewCarFollowApi();
  NewCarFollowFile? _file;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = '${Get.arguments ?? ''}';
    if (id.isEmpty) {
      setState(() {
        _error = '缺少档案 id';
        _loading = false;
      });
      return;
    }
    try {
      final file = await _api.fetchDetail(id);
      setState(() {
        _file = file;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _setLevel(String level) async {
    final file = _file;
    if (file == null) return;
    try {
      final updated = await _api.patch(fileId: file.fileId, followLevel: level);
      setState(() => _file = updated);
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '跟进档案详情', showBackButton: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _file == null
              ? Center(child: Text(_error ?? '未找到'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(_file!.customerName, style: Theme.of(context).textTheme.titleLarge),
                    Text(_file!.customerPhone),
                    const SizedBox(height: 12),
                    Text('级别 ${_file!.followLevel} · 意向 ${_file!.intentBand}'),
                    Text('阶段 ${_file!.stage}'),
                    Text('意向车型 ${_file!.vehicleInterest}'),
                    if (_file!.nextFollowUpAt != null) Text('下次跟进 ${_file!.nextFollowUpAt}'),
                    const SizedBox(height: 16),
                    const Text('调整级别'),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final lv in const ['H', 'A', 'B', 'E'])
                          ChoiceChip(
                            label: Text(lv),
                            selected: _file!.followLevel == lv,
                            onSelected: (_) => _setLevel(lv),
                          ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
    );
  }
}
