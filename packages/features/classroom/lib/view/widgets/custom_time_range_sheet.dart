import 'package:flutter/material.dart';
import 'package:module_classroom/theme/classroom_theme.dart';

/// 自定义时间区间选择 BottomSheet。
class CustomTimeRangeSheet extends StatefulWidget {
  const CustomTimeRangeSheet({
    super.key,
    required this.initialStart,
    required this.initialEnd,
  });

  final DateTime initialStart;
  final DateTime initialEnd;

  @override
  State<CustomTimeRangeSheet> createState() => _CustomTimeRangeSheetState();
}

class _CustomTimeRangeSheetState extends State<CustomTimeRangeSheet> {
  late DateTime _displayMonth;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(widget.initialStart.year, widget.initialStart.month);
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
  }

  void _onDayTap(DateTime day) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = day;
        _endDate = null;
      } else if (day.isBefore(_startDate!)) {
        _endDate = _startDate;
        _startDate = day;
      } else {
        _endDate = day;
      }
    });
  }

  bool _isInRange(DateTime day) {
    if (_startDate == null || _endDate == null) return false;
    return !day.isBefore(_startDate!) && !day.isAfter(_endDate!);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
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
                    '自定义时间',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: ClassroomColors.titleBlack,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _displayMonth = DateTime(
                        _displayMonth.year,
                        _displayMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_displayMonth.year}年${_displayMonth.month}月',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _displayMonth = DateTime(
                        _displayMonth.year,
                        _displayMonth.month + 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['日', '一', '二', '三', '四', '五', '六']
                  .map(
                    (w) => Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ClassroomColors.textGray,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _startDate != null && _endDate != null
                    ? () => Navigator.of(context).pop((_startDate!, _endDate!))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ClassroomColors.primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: ClassroomColors.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '确定',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayOffset = index - startWeekday + 1;
          if (dayOffset < 1 || dayOffset > daysInMonth) {
            return const SizedBox.shrink();
          }
          final day = DateTime(_displayMonth.year, _displayMonth.month, dayOffset);
          final isStart = _startDate != null && _isSameDay(day, _startDate!);
          final isEnd = _endDate != null && _isSameDay(day, _endDate!);
          final inRange = _isInRange(day);

          return GestureDetector(
            onTap: () => _onDayTap(day),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isStart || isEnd
                    ? ClassroomColors.primaryGreen
                    : inRange
                        ? ClassroomColors.primaryGreenLight
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayOffset',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isStart || isEnd ? FontWeight.w600 : FontWeight.normal,
                      color: isStart || isEnd
                          ? Colors.white
                          : ClassroomColors.titleBlack,
                    ),
                  ),
                  if (isStart)
                    const Text(
                      '开始',
                      style: TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  if (isEnd)
                    const Text(
                      '结束',
                      style: TextStyle(fontSize: 9, color: Colors.white),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
