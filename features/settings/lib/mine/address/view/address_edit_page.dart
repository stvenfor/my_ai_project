import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/mine/address/controller/address_edit_controller.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
import 'package:wys_common/wys_common.dart';

class AddressEditPage extends GetView<AddressEditController> {
  const AddressEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.standard,
      backgroundColor: MineTheme.background,
      navBar: AppNavBar(
        title: controller.isEdit ? '编辑地址' : '新增地址',
        showBackButton: true,
        backgroundColor: MineTheme.surface,
        foregroundColor: MineTheme.labelPrimary,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            _card([
              _field(
                '收货人',
                controller.nameCtrl,
                maxLength: WysContactValidators.maxNameLength,
              ),
              _field(
                '手机号',
                controller.phoneCtrl,
                keyboard: TextInputType.phone,
                maxLength: WysContactValidators.maxCnMobileLength,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              Obx(() {
                final label = controller.regionLabel.value;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('省市区', style: MineTheme.caption),
                  subtitle: Text(
                    label.isEmpty ? '请选择省 / 市 / 区' : label,
                    style: MineTheme.body.copyWith(
                      color: label.isEmpty
                          ? MineTheme.labelTertiary
                          : MineTheme.labelPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: MineTheme.labelTertiary,
                    size: 20.w,
                  ),
                  onTap: () => controller.pickRegion(context),
                );
              }),
              _field('详细地址', controller.detailCtrl, maxLines: 2),
              _field('标签（可选）', controller.labelCtrl),
            ]),
            SizedBox(height: 12.h),
            _card([
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('设为默认地址', style: MineTheme.body),
                  value: controller.isDefault.value,
                  activeThumbColor: MineTheme.accent,
                  onChanged: (v) => controller.isDefault.value = v,
                ),
              ),
            ]),
            SizedBox(height: 24.h),
            Obx(
              () => FilledButton(
                onPressed: controller.saving.value ? null : controller.save,
                style: FilledButton.styleFrom(
                  backgroundColor: MineTheme.accent,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(controller.saving.value ? '保存中…' : '保存'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: MineTheme.surface,
        borderRadius: BorderRadius.circular(MineTheme.radiusMd),
        border: Border.all(color: MineTheme.separator),
      ),
      child: Column(children: children),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboard,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: MineTheme.body,
      cursorColor: MineTheme.accent,
      buildCounter: maxLength == null
          ? null
          : (
              _, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) =>
              null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: MineTheme.caption,
        border: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: MineTheme.separator),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: MineTheme.accent),
        ),
      ),
    );
  }
}
