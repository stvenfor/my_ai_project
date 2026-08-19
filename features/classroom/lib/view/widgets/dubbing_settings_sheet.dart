import 'package:flutter/material.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';

/// 配音设置 BottomSheet。
class DubbingSettingsSheet extends StatefulWidget {
  const DubbingSettingsSheet({super.key});

  @override
  State<DubbingSettingsSheet> createState() => _DubbingSettingsSheetState();
}

class _DubbingSettingsSheetState extends State<DubbingSettingsSheet> {
  DubbingMode _dubbingMode = DubbingMode.practice;
  ScoringMode _scoringMode = ScoringMode.standard;
  bool _highScoreFreeze = true;
  bool _collaborationMode = true;
  bool _liaisonPrompt = false;
  bool _aiLiaison = false;
  bool _intonationPrompt = false;
  bool _mutePromptSound = false;
  bool _showTooltip = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '配音设置',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SettingRow(
                    label: '配音模式',
                    child: _SegmentedControl<DubbingMode>(
                      values: DubbingMode.values,
                      selected: _dubbingMode,
                      labels: const ['练习模式', '标准模式', '挑战模式'],
                      onChanged: (v) => setState(() => _dubbingMode = v),
                    ),
                  ),
                  _SwitchRow(
                    label: '高分冻结',
                    value: _highScoreFreeze,
                    onChanged: (v) => setState(() => _highScoreFreeze = v),
                  ),
                  _SwitchRow(
                    label: '合作模式',
                    value: _collaborationMode,
                    onChanged: (v) => setState(() => _collaborationMode = v),
                    showInfo: true,
                    onInfoTap: () => setState(() => _showTooltip = !_showTooltip),
                  ),
                  if (_showTooltip)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '开启合作模式并留空相应卡片，将由原声填充对应句子。发布后还可以邀请他人参与合作，生成合作作品。',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  _SettingRow(
                    label: '露脸演绎',
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('预览'),
                          SizedBox(width: 4),
                          Icon(Icons.play_arrow, size: 16),
                        ],
                      ),
                    ),
                  ),
                  _SettingRow(
                    label: '评分模式',
                    child: _SegmentedControl<ScoringMode>(
                      values: ScoringMode.values,
                      selected: _scoringMode,
                      labels: const ['少儿模式', '标准模式', '关闭评分'],
                      onChanged: (v) => setState(() => _scoringMode = v),
                    ),
                  ),
                  _SwitchRow(
                    label: '连读提示',
                    value: _liaisonPrompt,
                    onChanged: (v) => setState(() => _liaisonPrompt = v),
                  ),
                  _SwitchRow(
                    label: 'AI连读讲解',
                    value: _aiLiaison,
                    onChanged: (v) => setState(() => _aiLiaison = v),
                  ),
                  _SwitchRow(
                    label: '语调提示',
                    value: _intonationPrompt,
                    onChanged: (v) => setState(() => _intonationPrompt = v),
                  ),
                  _SwitchRow(
                    label: '关闭提示音',
                    value: _mutePromptSound,
                    onChanged: (v) => setState(() => _mutePromptSound = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: ClassroomColors.titleBlack),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.showInfo = false,
    this.onInfoTap,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showInfo;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: ClassroomColors.titleBlack),
          ),
          if (showInfo) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onInfoTap,
              child: const Icon(Icons.help_outline, size: 16, color: ClassroomColors.textGray),
            ),
          ],
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ClassroomColors.primaryGreen.withValues(alpha: 0.5),
            activeThumbColor: ClassroomColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.values,
    required this.selected,
    required this.labels,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final List<String> labels;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: List.generate(values.length, (i) {
        final isSelected = values[i] == selected;
        return GestureDetector(
          onTap: () => onChanged(values[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? ClassroomColors.primaryGreenLight : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? ClassroomColors.primaryGreen
                    : ClassroomColors.textGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }
}
