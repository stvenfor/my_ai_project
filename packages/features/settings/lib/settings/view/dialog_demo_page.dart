import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// 弹框样式与调度策略演示页。
class DialogDemoPage extends StatefulWidget {
  const DialogDemoPage({super.key});

  @override
  State<DialogDemoPage> createState() => _DialogDemoPageState();
}

class _DialogDemoPageState extends State<DialogDemoPage> {
  final _manager = AppDialogManager.instance;
  String _lastResult = '—';

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _run(Future<dynamic> future) async {
    final result = await future;
    _lastResult = result?.toString() ?? 'null';
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '弹框示例', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _StatusCard(
            isShowing: _manager.isShowing,
            pendingCount: _manager.pendingCount,
            lastResult: _lastResult,
          ),
          _Section(
            title: '样式示例',
            children: [
              _Btn(
                label: '单按钮提示（GeneralDialog）',
                onTap: () => _run(
                  _manager.showAlert(
                    title: '温馨提示',
                    content: '这是单按钮提示弹框，点击确认后关闭。',
                  ),
                ),
              ),
              _Btn(
                label: '双按钮确认（ConfirmDialog）',
                onTap: () => _run(
                  _manager.showConfirm(
                    title: '确认操作',
                    content: '确定要执行此操作吗？',
                  ),
                ),
              ),
              _Btn(
                label: '自定义内容（长文本滚动）',
                onTap: () => _run(
                  _manager.showAlertWidget(
                    title: '活动规则',
                    content: Text(List.filled(8, '规则条目示例内容。').join('\n')),
                    maxContentHeight: 220,
                  ),
                ),
              ),
              _Btn(
                label: '无底部关闭按钮',
                onTap: () => _run(
                  _manager.showAlert(
                    title: '系统通知',
                    content: '仅可通过确认按钮关闭。',
                    showCloseButton: false,
                  ),
                ),
              ),
              _Btn(
                label: '点击遮罩可关闭',
                onTap: () => _run(
                  _manager.showAlert(
                    title: '可点击遮罩关闭',
                    content: 'barrierDismissible = true',
                    barrierDismissible: true,
                  ),
                ),
              ),
              _Btn(
                label: '完全自定义 Dialog',
                onTap: () => _run(
                  _manager.showCustom<void>(
                    builder: (ctx) => AlertDialog(
                      title: const Text('原生 AlertDialog'),
                      content: const Text('通过 showCustom 入队展示。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _Section(
            title: '优先级调度',
            children: [
              _Btn(
                label: '同优先级 FIFO：连续入队 3 个中优',
                onTap: () {
                  for (var i = 1; i <= 3; i++) {
                    _manager.showAlert(
                      title: '中优先级 · $i',
                      content: '同档先进先出，第 $i 个',
                      priority: DialogPriority.medium,
                    );
                  }
                  UiKitInitializer.toast('已入队 3 个中优先级弹框');
                  _refresh();
                },
              ),
              _Btn(
                label: '先展示低优，再入队高优（不打断当前）',
                onTap: () {
                  _manager.showAlert(
                    title: '低优先级',
                    content: '请先关闭本弹框。关闭后将优先展示已入队的高优先级弹框。',
                    priority: DialogPriority.low,
                  );
                  _manager.showAlert(
                    title: '高优先级',
                    content: '高优在队列中排在低优之前，但不会打断正在展示的弹框。',
                    priority: DialogPriority.high,
                  );
                  UiKitInitializer.toast('已入队：低优（展示中）+ 高优（等待）');
                  _refresh();
                },
              ),
              _Btn(
                label: '高优连续入队 2 个（高内 FIFO，不替换）',
                onTap: () {
                  _manager.showAlert(
                    title: '高优先级 · 1',
                    content: '第一个高优弹框',
                    priority: DialogPriority.high,
                  );
                  _manager.showAlert(
                    title: '高优先级 · 2',
                    content: '第二个高优需等第一个关闭后再展示',
                    priority: DialogPriority.high,
                  );
                  UiKitInitializer.toast('已入队 2 个高优先级弹框');
                  _refresh();
                },
              ),
              _Btn(
                label: '混合入队：低 → 中 → 高',
                onTap: () {
                  _manager.showAlert(
                    title: '低',
                    content: '优先级：低',
                    priority: DialogPriority.low,
                  );
                  _manager.showAlert(
                    title: '中',
                    content: '优先级：中',
                    priority: DialogPriority.medium,
                  );
                  _manager.showAlert(
                    title: '高',
                    content: '优先级：高（队列中排最前，但仍等当前关闭）',
                    priority: DialogPriority.high,
                  );
                  UiKitInitializer.toast('展示顺序应为：当前 → 高 → 中 → 低');
                  _refresh();
                },
              ),
            ],
          ),
          _Section(
            title: '队列管理',
            children: [
              _Btn(
                label: '入队带 tag 的弹框（tag: pending_demo）',
                onTap: () {
                  _manager.enqueue<void>(
                    tag: 'pending_demo',
                    priority: DialogPriority.low,
                    builder: (_) => GeneralDialog(
                      title: '可被 cancelPending 取消',
                      content: const Text('tag = pending_demo'),
                    ),
                  );
                  UiKitInitializer.toast('已入队 tag=pending_demo');
                  _refresh();
                },
              ),
              _Btn(
                label: 'cancelPending("pending_demo")',
                onTap: () {
                  final ok = _manager.cancelPending('pending_demo');
                  UiKitInitializer.toast(ok ? '已取消' : '未找到待展示项');
                  _refresh();
                },
              ),
              _Btn(
                label: 'clearPending() 清空待展示',
                onTap: () {
                  final n = _manager.clearPending();
                  UiKitInitializer.toast('已清空 $n 个待展示弹框');
                  _refresh();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isShowing,
    required this.pendingCount,
    required this.lastResult,
  });

  final bool isShowing;
  final int pendingCount;
  final String lastResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '调度状态',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('正在展示：${isShowing ? '是' : '否'}'),
            Text('待展示数量：$pendingCount'),
            Text('上次返回：$lastResult'),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, textAlign: TextAlign.left),
          ),
        ),
      ),
    );
  }
}
