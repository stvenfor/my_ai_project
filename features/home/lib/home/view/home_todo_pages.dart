import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/api/home_todo_api.dart';
import 'package:module_home/home/model/home_todo_models.dart';

/// 新伙伴待确认列表：确认 / 拒绝。
class PartnerPendingPage extends StatefulWidget {
  const PartnerPendingPage({super.key});

  @override
  State<PartnerPendingPage> createState() => _PartnerPendingPageState();
}

class _PartnerPendingPageState extends State<PartnerPendingPage> {
  final _api = HomeTodoApi();
  late Future<List<HomeTodoJoinApplication>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchJoinApplications();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.fetchJoinApplications();
    });
    await _future;
  }

  Future<void> _approve(HomeTodoJoinApplication app) async {
    await _api.approveJoin(app.applicationId);
    if (!mounted) return;
    Get.snackbar('已确认', '${app.applicantUserId} 已成为门店成员');
    await _reload();
  }

  Future<void> _reject(HomeTodoJoinApplication app) async {
    await _api.rejectJoin(app.applicationId);
    if (!mounted) return;
    Get.snackbar('已拒绝', app.applicantUserId);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新伙伴待确认')),
      body: FutureBuilder<List<HomeTodoJoinApplication>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('暂无待审申请'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final app = items[i];
                return ListTile(
                  title: Text(app.applicantUserId),
                  subtitle: Text('申请 #${app.applicationId} · 门店 ${app.storeId}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _reject(app),
                        child: const Text('拒绝'),
                      ),
                      FilledButton(
                        onPressed: () => _approve(app),
                        child: const Text('确认'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// 只读待办列表页。
class HomeTodoListPage extends StatefulWidget {
  const HomeTodoListPage({
    super.key,
    required this.title,
    required this.loader,
    required this.itemTitle,
    required this.itemSubtitle,
  });

  final String title;
  final Future<List<Map<String, dynamic>>> Function() loader;
  final String Function(Map<String, dynamic>) itemTitle;
  final String Function(Map<String, dynamic>) itemSubtitle;

  @override
  State<HomeTodoListPage> createState() => _HomeTodoListPageState();
}

class _HomeTodoListPageState extends State<HomeTodoListPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  Future<void> _reload() async {
    setState(() => _future = widget.loader());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('暂无数据'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final row = items[i];
                return ListTile(
                  title: Text(widget.itemTitle(row)),
                  subtitle: Text(widget.itemSubtitle(row)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
