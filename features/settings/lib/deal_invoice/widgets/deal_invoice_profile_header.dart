import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';
import 'package:module_utils/module_utils.dart';

/// 顶部用户卡片 + 统计。
class DealInvoiceProfileHeader extends StatelessWidget {
  const DealInvoiceProfileHeader({
    super.key,
    this.summary,
  });

  final DealInvoiceSummary? summary;

  @override
  Widget build(BuildContext context) {
    final displayName =
        (summary?.displayName.isNotEmpty ?? false) ? summary!.displayName : '—';
    final position = summary?.positionLabel ?? '';
    final storeName =
        (summary?.storeName.isNotEmpty ?? false) ? summary!.storeName : '—';
    final avatarUrl = summary?.avatarUrl ?? '';
    final stats = summary?.stats ??
        const DealInvoiceStats(
          uploaded: 0,
          pendingReview: 0,
          approved: 0,
          rejected: 0,
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (position.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B8CFF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              position,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      storeName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipOval(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: _AvatarImage(url: avatarUrl, fallbackName: displayName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCell(value: '${stats.uploaded}', label: '已上传'),
              _StatCell(value: '${stats.pendingReview}', label: '待审核'),
              _StatCell(value: '${stats.approved}', label: '已通过'),
              _StatCell(value: '${stats.rejected}', label: '未通过'),
            ],
          ),
        ],
      ),
    );
  }
}

/// 与「我的」头像同源：支持 data URL / 本地路径 / 网络图。
class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url, required this.fallbackName});

  final String url;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _letterPlaceholder();

    if (url.startsWith('data:')) {
      final bytes = _decodeDataUrl(url);
      if (bytes == null) return _letterPlaceholder();
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    if (url.startsWith('/') || url.startsWith('file:')) {
      return Image.file(
        File(url.replaceFirst('file:', '')),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _letterPlaceholder(),
      );
    }

    return CacheImageUtils.network(url, width: 56, height: 56, fit: BoxFit.cover);
  }

  Uint8List? _decodeDataUrl(String dataUrl) {
    final comma = dataUrl.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(dataUrl.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  Widget _letterPlaceholder() {
    return Container(
      color: const Color(0xFFE8EEF8),
      alignment: Alignment.center,
      child: Text(
        fallbackName.isNotEmpty ? fallbackName[0] : '?',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3B8CFF),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
