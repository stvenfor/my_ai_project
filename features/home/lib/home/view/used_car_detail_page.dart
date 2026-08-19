import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/used_car_detail_controller.dart';
import 'package:module_home/home/widgets/transaction_list_item.dart';
import 'package:module_home/home/model/transaction_model.dart';

class UsedCarDetailPage extends GetView<UsedCarDetailController> {
  const UsedCarDetailPage({super.key});

  static const _bgColor = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bgColor,
      navBar: const AppNavBar(title: '交易详情', showBackButton: true),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final errorMessage = controller.errorMessage.value;
        final transaction = controller.transaction.value;

        if (isLoading && transaction == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null && transaction == null) {
          return _ErrorState(
            message: errorMessage,
            onRetry: controller.loadDetail,
          );
        }

        if (transaction == null) {
          return const Center(child: Text('记录不存在'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AmountCard(transaction: transaction),
              const SizedBox(height: 12),
              _InfoCard(
                title: '基本信息',
                rows: [
                  _InfoRow(label: '类型', value: transaction.type),
                  _InfoRow(label: '分类', value: transaction.category),
                  _InfoRow(label: '日期', value: transaction.date),
                  if (transaction.userId != null)
                    _InfoRow(label: '用户 ID', value: transaction.userId!),
                ],
              ),
              if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoCard(
                  title: '备注',
                  rows: [
                    _InfoRow(
                      label: '内容',
                      value: transaction.note!,
                      onCopy: () {
                        Clipboard.setData(
                          ClipboardData(text: transaction.note!),
                        );
                        UiKitInitializer.toast('已复制备注');
                      },
                    ),
                  ],
                ),
              ],
              if (transaction.createdAt != null ||
                  transaction.updatedAt != null) ...[
                const SizedBox(height: 12),
                _InfoCard(
                  title: '时间信息',
                  rows: [
                    if (transaction.createdAt != null)
                      _InfoRow(label: '创建时间', value: transaction.createdAt!),
                    if (transaction.updatedAt != null)
                      _InfoRow(label: '更新时间', value: transaction.updatedAt!),
                  ],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            TransactionListItem.formatAmount(transaction.amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '记录编号 #${transaction.id}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          for (final row in rows) row,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: '复制',
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('加载失败'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('点击重试')),
        ],
      ),
    );
  }
}
