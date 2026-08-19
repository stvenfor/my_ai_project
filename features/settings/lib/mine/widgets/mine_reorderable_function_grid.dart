import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
import 'package:module_settings/mine/widgets/mine_function_card_widget.dart';

class MineReorderableFunctionGrid extends StatefulWidget {
  const MineReorderableFunctionGrid({
    super.key,
    required this.items,
    required this.onReorder,
    required this.onItemTap,
  });

  final List<MineFunctionItem> items;
  final Future<void> Function(int fromIndex, int toIndex) onReorder;
  final void Function(MineFunctionItem item) onItemTap;

  @override
  State<MineReorderableFunctionGrid> createState() =>
      _MineReorderableFunctionGridState();
}

class _MineReorderableFunctionGridState extends State<MineReorderableFunctionGrid> {
  static const _horizontalPadding = 16.0;
  static const _crossAxisSpacing = 12.0;
  static const _childAspectRatio = 0.92;

  int? _draggingIndex;

  int _crossAxisCount(double width) {
    if (width >= 840) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  Size _cellSize(double width) {
    final count = _crossAxisCount(width);
    final cellWidth =
        (width - _horizontalPadding * 2 - _crossAxisSpacing * (count - 1)) /
            count;
    return Size(cellWidth, cellWidth / _childAspectRatio);
  }

  void _setDraggingIndex(int? index) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _draggingIndex == index) return;
      setState(() => _draggingIndex = index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cellSize = _cellSize(width);
        final crossAxisCount = _crossAxisCount(width);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: _crossAxisSpacing,
            childAspectRatio: _childAspectRatio,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isDragging = _draggingIndex == index;

            return DragTarget<int>(
              onWillAcceptWithDetails: (details) => details.data != index,
              onAcceptWithDetails: (details) async {
                _setDraggingIndex(null);
                await widget.onReorder(details.data, index);
              },
              builder: (context, candidateData, rejectedData) {
                final highlighted =
                    candidateData.isNotEmpty && _draggingIndex != index;

                return LongPressDraggable<int>(
                  data: index,
                  dragAnchorStrategy: childDragAnchorStrategy,
                  maxSimultaneousDrags: 1,
                  onDragStarted: () => _setDraggingIndex(index),
                  onDragEnd: (_) => _setDraggingIndex(null),
                  feedback: Material(
                    color: Colors.transparent,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(MineTheme.radiusMd),
                    child: SizedBox(
                      width: cellSize.width,
                      height: cellSize.height,
                      child: Transform.scale(
                        scale: 0.94,
                        child: Opacity(
                          opacity: 0.92,
                          child: MineFunctionCardWidget(
                            item: item,
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _buildCardShell(
                      item: item,
                      highlighted: false,
                      isDragging: true,
                    ),
                  ),
                  child: _buildCardShell(
                    item: item,
                    highlighted: highlighted,
                    isDragging: isDragging,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCardShell({
    required MineFunctionItem item,
    required bool highlighted,
    required bool isDragging,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MineTheme.radiusMd),
        border: highlighted
            ? Border.all(color: MineTheme.accent, width: 1.5)
            : null,
      ),
      child: IgnorePointer(
        ignoring: isDragging,
        child: MineFunctionCardWidget(
          item: item,
          onTap: () => widget.onItemTap(item),
        ),
      ),
    );
  }
}
