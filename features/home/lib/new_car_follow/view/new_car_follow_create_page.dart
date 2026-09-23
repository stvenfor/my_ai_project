import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/new_car_follow/api/new_car_follow_api.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';
import 'package:module_home/new_car_follow/widgets/new_car_follow_fake_upload.dart';

class NewCarFollowCreatePage extends StatefulWidget {
  const NewCarFollowCreatePage({super.key});

  @override
  State<NewCarFollowCreatePage> createState() => _NewCarFollowCreatePageState();
}

class _NewCarFollowCreatePageState extends State<NewCarFollowCreatePage> {
  static const _bgColor = Color(0xFFF5F6F8);

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _vehicle = TextEditingController();
  final _imagePath = RxnString();
  String _level = 'H';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _vehicle.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(() => _error = '请填写客户姓名和手机号');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // 假上传：本地图仅预览，不入 API body。
      await NewCarFollowApi().create(
        followLevel: _level,
        displayName: name,
        phone: phone,
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
      backgroundColor: _bgColor,
      navBar: const AppNavBar(title: '新建跟进档案', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _Card(
                  child: Column(
                    children: [
                      _Field(
                        label: '客户姓名',
                        controller: _name,
                        hint: '请输入姓名',
                      ),
                      const Divider(height: 1),
                      _Field(
                        label: '手机号',
                        controller: _phone,
                        hint: '请输入手机号',
                        keyboardType: TextInputType.phone,
                      ),
                      const Divider(height: 1),
                      _Field(
                        label: '意向车型',
                        controller: _vehicle,
                        hint: '选填',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '跟进级别',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (lv, label) in NewCarFollowLabels.levelChoices)
                            ChoiceChip(
                              label: Text(label),
                              selected: _level == lv,
                              selectedColor: const Color(0xFF3B8CFF)
                                  .withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _level == lv
                                    ? const Color(0xFF3B8CFF)
                                    : const Color(0xFF1A1A1A),
                              ),
                              side: BorderSide(
                                color: _level == lv
                                    ? const Color(0xFF3B8CFF)
                                    : Colors.grey.shade300,
                              ),
                              onSelected: (_) => setState(() => _level = lv),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  child: NewCarFollowFakeUpload(localPath: _imagePath),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFE53935), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B8CFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _saving ? '提交中…' : '创建档案',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }
}
