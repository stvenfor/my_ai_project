import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/after_sales/api/after_sales_api.dart';
import 'package:module_home/after_sales/model/after_sales_models.dart';
import 'package:module_home/after_sales/theme/after_sales_theme.dart';
import 'package:module_home/after_sales/widgets/after_sales_skeleton.dart';

class AfterSalesDetailPage extends StatefulWidget {
  const AfterSalesDetailPage({super.key});

  @override
  State<AfterSalesDetailPage> createState() => _AfterSalesDetailPageState();
}

class _AfterSalesDetailPageState extends State<AfterSalesDetailPage> {
  final _api = AfterSalesApi();
  AfterSalesRecord? _record;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = Get.arguments;
    final id = raw is int ? raw : int.tryParse('$raw') ?? 0;
    if (id <= 0) {
      setState(() {
        _error = '缺少记录 id';
        _loading = false;
      });
      return;
    }
    try {
      final record = await _api.fetchDetail(id);
      if (!mounted) return;
      setState(() {
        _record = record;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    return AppPageScaffold(
      backgroundColor: AfterSalesTheme.background,
      navBar: const AppNavBar(
        title: '服务详情',
        showBackButton: true,
        backgroundColor: AfterSalesTheme.surface,
        foregroundColor: AfterSalesTheme.ink,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        child: _loading
            ? const AfterSalesDetailSkeleton(key: ValueKey('sk'))
            : record == null
                ? _ErrorBody(
                    key: const ValueKey('err'),
                    message: _error ?? '未找到记录',
                    onRetry: () {
                      setState(() => _loading = true);
                      _load();
                    },
                  )
                : _DetailBody(key: ValueKey('ok-${record.recordId}'), record: record),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: AfterSalesTheme.body),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AfterSalesTheme.accent),
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({super.key, required this.record});
  final AfterSalesRecord record;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        AfterSalesFadeSlideIn(index: 0, child: _HeroCard(record: record)),
        const SizedBox(height: 12),
        AfterSalesFadeSlideIn(
          index: 1,
          child: _Section(
            title: '客户车辆',
            rows: [
              ('客户', record.customerName),
              ('手机', record.customerPhone),
              if (record.plateNo.isNotEmpty) ('车牌', record.plateNo),
              if (record.mileage != null) ('里程', '${record.mileage} km'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AfterSalesFadeSlideIn(
          index: 2,
          child: _Section(
            title: '服务信息',
            rows: [
              (
                '类型',
                record.serviceKindLabel.isEmpty
                    ? (record.serviceKind == 0 ? '维修' : '保养')
                    : record.serviceKindLabel
              ),
              ('日期', record.serviceDate),
              if (record.appointmentId != null) ('关联预约', '#${record.appointmentId}'),
            ],
          ),
        ),
        if (record.content.isNotEmpty) ...[
          const SizedBox(height: 12),
          AfterSalesFadeSlideIn(
            index: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: AfterSalesTheme.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '备注',
                    style: TextStyle(
                      color: AfterSalesTheme.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(record.content, style: AfterSalesTheme.body),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.record});
  final AfterSalesRecord record;

  @override
  Widget build(BuildContext context) {
    final kindColor = AfterSalesTheme.kindColor(record.serviceKind);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AfterSalesTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AfterSalesTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kindColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              record.serviceKindLabel.isEmpty
                  ? (record.serviceKind == 0 ? '维修' : '保养')
                  : record.serviceKindLabel,
              style: TextStyle(
                color: kindColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Hero(
            tag: 'after_sales_title_${record.recordId}',
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                record.title,
                style: AfterSalesTheme.title.copyWith(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(record.serviceDate, style: AfterSalesTheme.caption),
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
      decoration: AfterSalesTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AfterSalesTheme.sectionTitle),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(row.$1, style: AfterSalesTheme.caption),
                  ),
                  Expanded(child: Text(row.$2, style: AfterSalesTheme.body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
