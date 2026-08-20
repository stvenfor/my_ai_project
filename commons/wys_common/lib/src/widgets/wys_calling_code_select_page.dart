import 'package:flutter/material.dart';

import '../calling_code/wys_calling_code_item.dart';
import '../calling_code/wys_calling_code_repository.dart';

/// 选择国家 / 地区区号页，对齐登录模块 `CallingCodePage` /
/// 安卓 `SelectCallingCodeScreen`。
///
/// 支持按国家名或区号搜索；点击后默认 `Navigator.pop(context, code)`
/// 回传 `+86` 形式区号。
class WysCallingCodeSelectPage extends StatefulWidget {
  const WysCallingCodeSelectPage({
    super.key,
    this.repository,
    this.onSelected,
    this.title = '选择国家和地区',
  });

  final WysCallingCodeRepository? repository;
  final ValueChanged<String>? onSelected;
  final String title;

  @override
  State<WysCallingCodeSelectPage> createState() =>
      _WysCallingCodeSelectPageState();
}

class _WysCallingCodeSelectPageState extends State<WysCallingCodeSelectPage> {
  late final WysCallingCodeRepository _repository =
      widget.repository ?? WysCallingCodeRepository();
  final _searchController = TextEditingController();

  List<WysCallingCodeItem> _codes = const [];
  String _query = '';
  bool _loading = true;

  List<WysCallingCodeItem> get _filteredCodes {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _codes;
    final codeQuery = query.replaceAll(RegExp(r'[+\s]'), '');
    return _codes.where((item) {
      final name = item.name.toLowerCase();
      final code = item.code.toLowerCase();
      return name.contains(query) ||
          code.contains(query) ||
          code.replaceAll(RegExp(r'[+\s]'), '').contains(codeQuery);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCodes() async {
    try {
      final list = await _repository.fetchCallingCodes();
      if (mounted) setState(() => _codes = list);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _select(String code) {
    final onSelected = widget.onSelected;
    if (onSelected != null) {
      onSelected(code);
      return;
    }
    Navigator.of(context).pop<String>(code);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCodes;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '搜索国家、地区或区号',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '清空搜索',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear, size: 20),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(
                      child: Text(
                        '未找到相关国家、地区或区号',
                        style: TextStyle(color: Color(0xFF999999)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16),
                      itemBuilder: (_, index) {
                        final item = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            item.code,
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                          onTap: () => _select(item.code),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
