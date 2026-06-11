import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';

/// 登录模块独立运行时的登录成功页。
class AuthDevHomePage extends GetView<AuthController> {
  const AuthDevHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Get.find<UserService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth 独立运行'),
        actions: [
          TextButton(
            onPressed: controller.logout,
            child: const Text('登出', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        final user = userService.currentUser.value;
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(RoutePath.login);
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '登录成功，会话已写入本地',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatar),
                ),
                title: Text(user.name),
                subtitle: Text('ID: ${user.id}'),
              ),
              const SizedBox(height: 8),
              Text('Token: ${user.token}', style: const TextStyle(fontSize: 12)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: controller.logout,
                  child: const Text('登出并清除缓存'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
