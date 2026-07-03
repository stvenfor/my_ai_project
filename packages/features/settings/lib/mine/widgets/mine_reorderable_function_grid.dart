import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';
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
  static const _crossAxisCount = 2;
  static const _horizontalPadding = 16.0;
  static const _crossAxisSpacing = 12.0;
  static const _childAspectRatio = 1.05;

  int? _draggingIndex;

  Size _cellSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cellWidth =
        (width - _horizontalPadding * 2 - _crossAxisSpacing) / _crossAxisCount;
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
    final cellSize = _cellSize(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
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
                borderRadius: BorderRadius.circular(12),
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
  }

  Widget _buildCardShell({
    required MineFunctionItem item,
    required bool highlighted,
    required bool isDragging,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: highlighted
            ? Border.all(color: const Color(0xFF1B82D2), width: 1.5)
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
