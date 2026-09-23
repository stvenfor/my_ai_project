import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/new_car_follow/api/new_car_follow_api.dart';
import 'package:module_home/new_car_follow/model/new_car_follow_models.dart';
import 'package:module_home/new_car_follow/widgets/new_car_follow_fake_upload.dart';

class NewCarFollowDetailPage extends StatefulWidget {
  const NewCarFollowDetailPage({super.key});

  @override
  State<NewCarFollowDetailPage> createState() => _NewCarFollowDetailPageState();
}

class _NewCarFollowDetailPageState extends State<NewCarFollowDetailPage> {
  static const _bgColor = Color(0xFFF5F6F8);

  final _api = NewCarFollowApi();
  final _imagePath = RxnString();
  final _logBody = TextEditingController();
  NewCarFollowFile? _file;
  final _logs = <NewCarFollowLog>[];
  String? _error;
  bool _loading = true;
  bool _savingLevel = false;
  bool _savingLog = false;
  String? _logLevel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _logBody.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = '${Get.arguments ?? ''}';
    if (id.isEmpty) {
      setState(() {
        _error = '缺少档案 id';
        _loading = false;
      });
      return;
    }
    try {
      final file = await _api.fetchDetail(id);
      final logs = await _api.fetchLogs(fileId: id);
      setState(() {
        _file = file;
        _logs
          ..clear()
          ..addAll(logs.list);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _setLevel(String level) async {
    final file = _file;
    if (file == null || _savingLevel || file.followLevel == level) return;
    setState(() {
      _savingLevel = true;
      _error = null;
    });
    try {
      final updated = await _api.patch(fileId: file.fileId, followLevel: level);
      setState(() => _file = updated);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _savingLevel = false);
    }
  }

  Future<void> _submitLog() async {
    final file = _file;
    if (file == null || _savingLog) return;
    final body = _logBody.text.trim();
    if (body.isEmpty) {
      setState(() => _error = '请填写跟进内容');
      return;
    }
    setState(() {
      _savingLog = true;
      _error = null;
    });
    try {
      await _api.createLog(
        fileId: file.fileId,
        body: body,
        followLevel: _logLevel,
      );
      _logBody.clear();
      _logLevel = null;
      final updated = await _api.fetchDetail(file.fileId);
      final logs = await _api.fetchLogs(fileId: file.fileId);
      setState(() {
        _file = updated;
        _logs
          ..clear()
          ..addAll(logs.list);
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _savingLog = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bgColor,
      navBar: const AppNavBar(title: '跟进档案详情', showBackButton: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _file == null
              ? Center(
                  child: Text(
                    _error ?? '未找到',
                    style: const TextStyle(color: Color(0xFFE53935)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    _HeroCard(file: _file!),
                    const SizedBox(height: 12),
                    _InfoCard(file: _file!),
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '调整级别',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final (lv, label)
                                  in NewCarFollowLabels.levelChoices)
                                ChoiceChip(
                                  label: Text(label),
                                  selected: _file!.followLevel == lv,
                                  selectedColor: const Color(0xFF3B8CFF)
                                      .withValues(alpha: 0.15),
                                  labelStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _file!.followLevel == lv
                                        ? const Color(0xFF3B8CFF)
                                        : const Color(0xFF1A1A1A),
                                  ),
                                  side: BorderSide(
                                    color: _file!.followLevel == lv
                                        ? const Color(0xFF3B8CFF)
                                        : Colors.grey.shade300,
                                  ),
                                  onSelected: _savingLevel
                                      ? null
                                      : (_) => _setLevel(lv),
                                ),
                            ],
                          ),
                          if (_savingLevel) ...[
                            const SizedBox(height: 12),
                            const LinearProgressIndicator(minHeight: 2),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '写一条跟进',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _logBody,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: '跟进内容（必填）',
                              filled: true,
                              fillColor: const Color(0xFFF5F6F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('不改级别'),
                                selected: _logLevel == null,
                                onSelected: (_) =>
                                    setState(() => _logLevel = null),
                              ),
                              for (final (lv, label)
                                  in NewCarFollowLabels.levelChoices)
                                ChoiceChip(
                                  label: Text(label),
                                  selected: _logLevel == lv,
                                  onSelected: (_) =>
                                      setState(() => _logLevel = lv),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _savingLog ? null : _submitLog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B8CFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: Text(_savingLog ? '提交中…' : '提交跟进'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '跟进流水（${_logs.length}）',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_logs.isEmpty)
                            Text(
                              '暂无流水',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            )
                          else
                            for (var i = 0; i < _logs.length; i++) ...[
                              if (i > 0) const Divider(height: 20),
                              _LogTile(log: _logs[i]),
                            ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Card(
                      child: NewCarFollowFakeUpload(
                        localPath: _imagePath,
                        title: '资料图（假上传）',
                        hint: '仅本机预览，不落库',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final NewCarFollowLog log;

  @override
  Widget build(BuildContext context) {
    final who = log.authorDisplayName.isNotEmpty
        ? log.authorDisplayName
        : (log.authorUserId.isNotEmpty ? log.authorUserId : '—');
    final time = log.createdAt.length >= 16
        ? log.createdAt.substring(0, 16).replaceFirst('T', ' ')
        : log.createdAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                who,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          log.body,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            height: 1.4,
          ),
        ),
        if (log.followLevel.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '级别 → ${log.followLevel}${log.intentBand.isNotEmpty ? ' · ${log.intentBand}' : ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.file});

  final NewCarFollowFile file;

  @override
  Widget build(BuildContext context) {
    final bandColor = switch (file.intentBand) {
      '高' => const Color(0xFFE53935),
      '中' => const Color(0xFFFAAD14),
      '低' => const Color(0xFF8C8C8C),
      _ => const Color(0xFF3B8CFF),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.customerName.isNotEmpty ? file.customerName : '—',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  file.customerPhone.isNotEmpty ? file.customerPhone : '未填手机号',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                if (file.ownerDisplayName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '销售 ${file.ownerDisplayName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bandColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${file.followLevel} · ${file.intentBand}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: bandColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.file});

  final NewCarFollowFile file;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _InfoRow(label: '阶段', value: NewCarFollowLabels.stage(file.stage)),
          const Divider(height: 20),
          _InfoRow(
            label: '意向车型',
            value: file.vehicleInterest.isNotEmpty ? file.vehicleInterest : '—',
          ),
          const Divider(height: 20),
          _InfoRow(
            label: '下次跟进',
            value: (file.nextFollowUpAt != null && file.nextFollowUpAt!.isNotEmpty)
                ? file.nextFollowUpAt!
                : '未设置',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
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
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
