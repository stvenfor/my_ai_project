import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/model/im/im_session_state.dart';
import 'package:module_core/service/im_backup_service.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_rongcloud_im/backup/mock_im_backup_service.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_rongcloud_im/im_initializer.dart';

class ImDebugPage extends StatelessWidget {
  const ImDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = ImInitializer.session;
    if (session == null) {
      return const AppPageScaffold(
        navBar: AppNavBar(title: '融云 IM 调试', showBackButton: true),
        body: Center(child: Text('IM 未初始化')),
      );
    }

    final backup = Get.isRegistered<ImBackupService>()
        ? Get.find<ImBackupService>()
        : null;

    return AppPageScaffold(
      navBar: const AppNavBar(title: '融云 IM 调试', showBackButton: true),
      body: StreamBuilder<ImConnectionState>(
        stream: session.connectionState,
        initialData: session.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data ?? session.currentState;
          final info = session.sessionInfo;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('useMockIm=${RongImConfig.useMockIm}'),
              Text('state=${state.label}'),
              Text('imUserId=${info?.imUserId ?? '—'}'),
              Text('bizUserId=${info?.bizUserId ?? '—'}'),
              if (backup is MockImBackupService)
                Text('backupQueue=${backup.pendingCount}'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ImInitializer.tryConnectIfReady(),
                child: const Text('连接 / 重连'),
              ),
              OutlinedButton(
                onPressed: () => session.disconnect(reason: 'debug'),
                child: const Text('断开'),
              ),
              if (backup != null)
                OutlinedButton(
                  onPressed: () => backup.flushPending(),
                  child: const Text('flush 备份队列'),
                ),
            ],
          );
        },
      ),
    );
  }
}
