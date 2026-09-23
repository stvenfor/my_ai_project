import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/after_sales/api/after_sales_api.dart';
import 'package:module_home/after_sales/theme/after_sales_theme.dart';
import 'package:module_home/after_sales/widgets/after_sales_skeleton.dart';

class AfterSalesCreatePage extends StatefulWidget {
  const AfterSalesCreatePage({super.key});

  @override
  State<AfterSalesCreatePage> createState() => _AfterSalesCreatePageState();
}

class _AfterSalesCreatePageState extends State<AfterSalesCreatePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _title = TextEditingController();
  final _plate = TextEditingController();
  final _mileage = TextEditingController();
  final _content = TextEditingController();
  final _date = TextEditingController(
    text: DateTime.now().toIso8601String().split('T').first,
  );
  int? _appointmentId;
  String _kind = '1';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      final id = args['appointment_id'];
      if (id is int) {
        _appointmentId = id;
      } else if (id != null) {
        _appointmentId = int.tryParse('$id');
      }
      final name = args['customer_name'];
      if (name is String && name.isNotEmpty) {
        _name.text = name;
        _title.text = '$name 售后服务';
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _title.dispose();
    _plate.dispose();
    _mileage.dispose();
    _content.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_date.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AfterSalesTheme.accent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _date.text =
            '${picked.year.toString().padLeft(4, '0')}-'
            '${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      setState(() => _error = '请填写客户姓名与手机号');
      return;
    }
    if (_title.text.trim().isEmpty) {
      setState(() => _error = '请填写服务标题');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final mileageText = _mileage.text.trim();
      await AfterSalesApi().create(
        serviceKind: _kind,
        title: _title.text.trim(),
        serviceDate: _date.text.trim(),
        customerName: _name.text.trim(),
        customerPhone: _phone.text.trim(),
        appointmentId: _appointmentId,
        plateNo: _plate.text.trim(),
        mileage: mileageText.isEmpty ? null : int.tryParse(mileageText),
        content: _content.text.trim(),
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
    final fromAppt = _appointmentId != null;
    return AppPageScaffold(
      backgroundColor: AfterSalesTheme.background,
      navBar: AppNavBar(
        title: fromAppt ? '从预约建档' : '新建服务记录',
        showBackButton: true,
        backgroundColor: AfterSalesTheme.surface,
        foregroundColor: AfterSalesTheme.ink,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (fromAppt)
                  AfterSalesFadeSlideIn(
                    index: 0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AfterSalesTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AfterSalesTheme.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: AfterSalesTheme.accent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '关联预约 #$_appointmentId，提交后预约将标记完成',
                              style: AfterSalesTheme.caption.copyWith(
                                color: AfterSalesTheme.accentDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                AfterSalesFadeSlideIn(
                  index: 1,
                  child: _CardBlock(
                  title: '服务类型',
                  child: Row(
                    children: [
                      Expanded(
                        child: _KindTile(
                          label: '保养',
                          icon: Icons.water_drop_outlined,
                          selected: _kind == '1',
                          color: AfterSalesTheme.maintenance,
                          onTap: () => setState(() => _kind = '1'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KindTile(
                          label: '维修',
                          icon: Icons.handyman_outlined,
                          selected: _kind == '0',
                          color: AfterSalesTheme.repair,
                          onTap: () => setState(() => _kind = '0'),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                const SizedBox(height: 12),
                AfterSalesFadeSlideIn(
                  index: 2,
                  child: _CardBlock(
                  title: '客户信息',
                  child: Column(
                    children: [
                      TextField(
                        controller: _name,
                        decoration: AfterSalesTheme.fieldDecoration('客户姓名'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phone,
                        decoration: AfterSalesTheme.fieldDecoration('手机号'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                ),
                const SizedBox(height: 12),
                AfterSalesFadeSlideIn(
                  index: 3,
                  child: _CardBlock(
                  title: '服务内容',
                  child: Column(
                    children: [
                      TextField(
                        controller: _title,
                        decoration: AfterSalesTheme.fieldDecoration('标题'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _date,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: AfterSalesTheme.fieldDecoration('服务日期').copyWith(
                          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _plate,
                        decoration: AfterSalesTheme.fieldDecoration('车牌（可选）'),
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _mileage,
                        decoration: AfterSalesTheme.fieldDecoration('里程 km（可选）'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _content,
                        decoration: AfterSalesTheme.fieldDecoration('备注（可选）'),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: AfterSalesTheme.repair, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: AfterSalesTheme.surface,
                border: Border(top: BorderSide(color: AfterSalesTheme.hairline)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AfterSalesTheme.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(fromAppt ? '提交并完成预约' : '提交记录'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: AfterSalesTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AfterSalesTheme.sectionTitle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _KindTile extends StatelessWidget {
  const _KindTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.12) : AfterSalesTheme.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AfterSalesTheme.hairline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : AfterSalesTheme.mute),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : AfterSalesTheme.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
