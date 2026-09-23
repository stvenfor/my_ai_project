import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/new_car_follow/api/new_car_follow_api.dart';

class NewCarFollowCreatePage extends StatefulWidget {
  const NewCarFollowCreatePage({super.key});

  @override
  State<NewCarFollowCreatePage> createState() => _NewCarFollowCreatePageState();
}

class _NewCarFollowCreatePageState extends State<NewCarFollowCreatePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _vehicle = TextEditingController();
  String _level = 'H';
  bool _saving = false;
  String? _error;

  static const _levels = ['H', 'A', 'B', 'E'];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _vehicle.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await NewCarFollowApi().create(
        followLevel: _level,
        displayName: _name.text.trim(),
        phone: _phone.text.trim(),
        vehicleInterest: _vehicle.text.trim(),
      );
      if (mounted) Get.back(result: true);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '新建跟进档案', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '客户姓名'),
          ),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: '手机号'),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _vehicle,
            decoration: const InputDecoration(labelText: '意向车型'),
          ),
          const SizedBox(height: 12),
          const Text('跟进级别'),
          Wrap(
            spacing: 8,
            children: [
              for (final lv in _levels)
                ChoiceChip(
                  label: Text(lv),
                  selected: _level == lv,
                  onSelected: (_) => setState(() => _level = lv),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(_saving ? '提交中…' : '创建档案'),
          ),
        ],
      ),
    );
  }
}
