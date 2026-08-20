# wys_account

各 **feature module** 统一获取 **登录状态** 与 **用户信息**（内存 + `shared_preferences` 持久化）。

## 初始化（主工程）

```dart
import 'package:wys_account/wys_account.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WysAccount.initialize(bindNetHeaders: true); // 自动给 wys_network 带 token 头
  runApp(...);
}
```

`pubspec.yaml`：

```yaml
wys_account:
  path: commons/wys_account
```

业务 module 同样 path 依赖 `../../commons/wys_account`。

## 其它 module 用法

```dart
import 'package:wys_account/wys_account.dart';

// 是否登录
if (WysAccount.isLoggedIn) { ... }

// 当前用户
final user = WysAccount.currentUser; // AccountUser?
final token = WysAccount.token;

// 监听登录/登出
WysAccount.repo.authStateChanges.listen((AccountUser? user) {
  // user == null 表示已登出
});

// 登出（一般在「我的」）
await WysAccount.logout();
```

## 登录模块写入会话

`module_login` 在接口成功后：

```dart
await WysAccount.setSession(AccountUser(
  userId: '...',
  token: '...',
  phone: phone,
  nickname: '...',
));
```

## 模型

`AccountUser`：`userId`、`token`、`nickname`、`avatarUrl`、`phone`、`extra`。

## 与 wys_network

`initialize(bindNetHeaders: true)` 会设置 `globalHeaderProvider`，请求自动附加 `Authorization` / `token`（可按后端改 `wys_account.dart`）。