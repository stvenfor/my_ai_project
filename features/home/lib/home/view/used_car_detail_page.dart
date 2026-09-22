import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/used_car_detail_controller.dart';
import 'package:module_home/home/model/used_car_order_models.dart';

class UsedCarDetailPage extends GetView<UsedCarDetailController> {
  const UsedCarDetailPage({super.key});

  static const _bg = Color(0xFFF3F5F8);
  static const _ink = Color(0xFF1C2430);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bg,
      navBar: const AppNavBar(title: '业务单详情', showBackButton: true),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final errorMessage = controller.errorMessage.value;
        final order = controller.order.value;

        if (isLoading && order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (errorMessage != null && order == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorMessage),
                const SizedBox(height: 12),
                FilledButton(onPressed: controller.loadDetail, child: const Text('重试')),
              ],
            ),
          );
        }
        if (order == null) {
          return const Center(child: Text('业务单不存在'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _HeroCard(order: order),
            const SizedBox(height: 12),
            _Section(
              title: '客户',
              rows: [
                ('姓名', order.customerName),
                ('手机', order.phone),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: '车辆',
              rows: [
                ('车型', order.vehicleModel),
                ('车牌', order.plateNo),
                ('VIN', order.vin),
                ('里程', '${order.mileageKm} km'),
                ('年款', '${order.modelYear}'),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: '审核',
              rows: [
                ('状态', order.statusLabel),
                if (order.rejectReason != null && order.rejectReason!.isNotEmpty)
                  ('驳回原因', order.rejectReason!),
                if (order.ratingStars != null) ('评分', '${order.ratingStars} 星'),
                ('提交时间', order.submittedAt.toLocal().toString()),
              ],
            ),
            if (order.imageUrl != null && order.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(order.imageUrl!, fit: BoxFit.cover),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.order});
  final UsedCarOrderItem order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.kindLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B6E4F),
                ),
              ),
              const Spacer(),
              Text(order.statusLabel, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.vehicleModel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: UsedCarDetailPage._ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(order.amountLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(
            '¥${order.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: UsedCarDetailPage._ink,
            ),
          ),
          const SizedBox(height: 6),
          Text('单号 #${order.orderId}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(row.$1, style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  Expanded(child: Text(row.$2, style: const TextStyle(height: 1.35))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
