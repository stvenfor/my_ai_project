import 'package:flutter/material.dart';

class BfuiAnimationHost extends StatefulWidget {
  const BfuiAnimationHost({super.key, required this.builder});

  final Widget Function(
    AnimationController controller,
    Animation<double> animation,
  ) builder;

  @override
  State<BfuiAnimationHost> createState() => _BfuiAnimationHostState();
}

class _BfuiAnimationHostState extends State<BfuiAnimationHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller, _animation);
  }
}

/// ui_view 等单组件预览页通用 Scaffold。
class BfuiComponentPreviewPage extends StatelessWidget {
  const BfuiComponentPreviewPage({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.childBuilder,
  });

  final String title;
  final Color backgroundColor;
  final Widget Function(
    AnimationController controller,
    Animation<double> animation,
  ) childBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: BfuiAnimationHost(
          builder: (controller, animation) =>
              childBuilder(controller, animation),
        ),
      ),
    );
  }
}

/// MyDiary / Training 等需要外部 AnimationController 的全屏页包装。
class BfuiAnimatedScreenPage extends StatelessWidget {
  const BfuiAnimatedScreenPage({super.key, required this.childBuilder});

  final Widget Function(AnimationController controller) childBuilder;

  @override
  Widget build(BuildContext context) {
    return BfuiAnimationHost(
      builder: (controller, animation) => childBuilder(controller),
    );
  }
}
