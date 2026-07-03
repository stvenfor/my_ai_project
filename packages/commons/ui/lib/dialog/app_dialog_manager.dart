import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/dialog/confirm_dialog.dart';
import 'package:module_common_ui/dialog/dialog_priority.dart';
import 'package:module_common_ui/dialog/general_dialog.dart';

/// 全局 Dialog 调度器：互斥展示，按优先级 + 同档 FIFO 排队。
class AppDialogManager {
  AppDialogManager._();

  static final AppDialogManager instance = AppDialogManager._();

  /// 简写访问。
  static AppDialogManager get I => instance;

  final List<_DialogEntry<dynamic>> _queue = [];
  _DialogEntry<dynamic>? _current;
  int _sequence = 0;
  var _pumping = false;

  bool get isShowing => _current != null;

  int get pendingCount => _queue.length;

  /// 单按钮提示（原 GeneralDialog.showText）。
  Future<void> showAlert({
    required String title,
    required String content,
    DialogPriority priority = DialogPriority.medium,
    String confirmText = '好的，我知道了',
    bool showCloseButton = true,
    bool barrierDismissible = false,
    VoidCallback? onConfirm,
  }) {
    return enqueue<void>(
      priority: priority,
      barrierDismissible: barrierDismissible,
      builder: (context) => GeneralDialog(
        title: title,
        content: Text(content),
        confirmText: confirmText,
        showCloseButton: showCloseButton,
        onConfirm: onConfirm,
      ),
    );
  }

  /// 长内容 / 自定义 Widget 提示。
  Future<void> showAlertWidget({
    required String title,
    required Widget content,
    DialogPriority priority = DialogPriority.medium,
    String confirmText = '好的，我知道了',
    bool showCloseButton = true,
    bool barrierDismissible = false,
    VoidCallback? onConfirm,
    double maxContentHeight = 300,
  }) {
    return enqueue<void>(
      priority: priority,
      barrierDismissible: barrierDismissible,
      builder: (context) => GeneralDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        showCloseButton: showCloseButton,
        onConfirm: onConfirm,
        maxContentHeight: maxContentHeight,
      ),
    );
  }

  /// 双按钮确认，返回 true=确定 / false=取消 / null=被清空队列。
  Future<bool?> showConfirm({
    required String title,
    required String content,
    DialogPriority priority = DialogPriority.medium,
    String confirmText = '确定',
    String cancelText = '取消',
    bool showCloseButton = true,
    bool barrierDismissible = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return enqueue<bool>(
      priority: priority,
      barrierDismissible: barrierDismissible,
      builder: (context) => ConfirmDialog(
        title: title,
        content: Text(content),
        confirmText: confirmText,
        cancelText: cancelText,
        showCloseButton: showCloseButton,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  /// 自定义 Dialog Widget。
  Future<T?> showCustom<T>({
    required Widget Function(BuildContext context) builder,
    DialogPriority priority = DialogPriority.medium,
    bool barrierDismissible = true,
  }) {
    return enqueue<T>(
      priority: priority,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  Future<T?> enqueue<T>({
    required Widget Function(BuildContext context) builder,
    DialogPriority priority = DialogPriority.medium,
    bool barrierDismissible = false,
    String? tag,
  }) {
    final completer = Completer<T?>();
    final entry = _DialogEntry<T>(
      id: tag ?? 'dialog_${_sequence + 1}',
      priority: priority,
      sequence: ++_sequence,
      barrierDismissible: barrierDismissible,
      builder: builder,
      completer: completer,
    );
    _queue.add(entry);
    _sortQueue();
    unawaited(_pump());
    return completer.future;
  }

  /// 清空待展示队列（不影响当前正在展示的弹框）。
  int clearPending() {
    final removed = _queue.length;
    for (final entry in _queue) {
      if (!entry.completer.isCompleted) {
        entry.completer.complete(null);
      }
    }
    _queue.clear();
    return removed;
  }

  /// 取消指定 tag 的待展示弹框。
  bool cancelPending(String tag) {
    final index = _queue.indexWhere((e) => e.id == tag);
    if (index < 0) return false;
    final entry = _queue.removeAt(index);
    if (!entry.completer.isCompleted) {
      entry.completer.complete(null);
    }
    return true;
  }

  void _sortQueue() {
    _queue.sort((a, b) {
      final byPriority = a.priority.weight.compareTo(b.priority.weight);
      if (byPriority != 0) return byPriority;
      return a.sequence.compareTo(b.sequence);
    });
  }

  Future<void> _pump() async {
    if (_pumping || _current != null) return;
    if (_queue.isEmpty) return;

    final context = Get.overlayContext ?? Get.context;
    if (context == null || !context.mounted) return;

    _pumping = true;
    final entry = _queue.removeAt(0);
    _current = entry;

    try {
      final result = await showDialog<dynamic>(
        context: context,
        barrierDismissible: entry.barrierDismissible,
        useRootNavigator: true,
        builder: entry.builder,
      );
      if (!entry.completer.isCompleted) {
        entry.completer.complete(result as dynamic);
      }
    } catch (e, st) {
      if (!entry.completer.isCompleted) {
        entry.completer.completeError(e, st);
      }
    } finally {
      _current = null;
      _pumping = false;
      await _pump();
    }
  }
}

class _DialogEntry<T> {
  _DialogEntry({
    required this.id,
    required this.priority,
    required this.sequence,
    required this.barrierDismissible,
    required this.builder,
    required this.completer,
  });

  final String id;
  final DialogPriority priority;
  final int sequence;
  final bool barrierDismissible;
  final Widget Function(BuildContext context) builder;
  final Completer<T?> completer;
}
