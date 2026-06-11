import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';

class AuthController extends GetxController {
  AuthController({UserService? userService})
      : _userService = userService ?? Get.find<UserService>();

  /// 独立运行 main_dev 时设为 true
  static bool standaloneMode = false;

  final UserService _userService;

  final isLoading = false.obs;
  final agreedPrivacy = true.obs;
  final phone = ''.obs;
  final password = ''.obs;

  String _pendingPhone = '';

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早上好，欢迎使用i车商';
    if (hour < 18) return '下午好，欢迎使用i车商';
    return '晚上好，欢迎使用i车商';
  }

  bool get isPasswordValid =>
      password.value.length >= 6 && password.value.length <= 16;

  void updatePhone(String value) => phone.value = value;

  void updatePassword(String value) => password.value = value;

  void togglePrivacy(bool? value) {
    if (value != null) agreedPrivacy.value = value;
  }

  bool _validatePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(digits);
  }

  void _showToast(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xCC333333),
        margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        borderRadius: 8,
      ),
    );
  }

  Future<void> goToPasswordPage() async {
    if (!agreedPrivacy.value) {
      _showToast('请先阅读并同意隐私条款');
      return;
    }
    final digits = phone.value.replaceAll(RegExp(r'\s+'), '');
    if (!_validatePhone(digits)) {
      _showToast('手机号不正确');
      return;
    }
    _pendingPhone = digits;
    await Get.toNamed(RoutePath.loginPassword);
  }

  Future<void> loginWithPassword() async {
    if (!isPasswordValid) {
      _showToast('请输入6-16位密码');
      return;
    }

    isLoading.value = true;
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final user = User(
        id: 'u_$_pendingPhone',
        name: '用户${_pendingPhone.substring(7)}',
        avatar:
            'https://api.dicebear.com/7.x/avataaars/png?seed=$_pendingPhone',
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      await _userService.setUser(user);
      if (standaloneMode) {
        _showToast('登录成功');
      } else {
        Get.offAllNamed(RoutePath.main);
      }
    } catch (error) {
      _showToast('登录失败：$error');
    } finally {
      isLoading.value = false;
    }
  }
}
