import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';

class AuthController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = '请输入账号和密码';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      // 模拟登录 API，延迟 1 秒
      await Future<void>.delayed(const Duration(seconds: 1));
      final user = User(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: username.trim(),
        avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=$username',
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      await _userService.setUser(user);
      Get.offAllNamed(RoutePath.main);
    } catch (error) {
      errorMessage.value = '登录失败：$error';
    } finally {
      isLoading.value = false;
    }
  }
}
