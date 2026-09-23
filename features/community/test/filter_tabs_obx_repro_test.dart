import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Mirrors the fixed CommunityViewModel lifecycle: load in [onReady], not [onInit].
class _FeedVm extends GetxController {
  final feedTab = 'latest'.obs;
  final isLoading = false.obs;
  final posts = <String>[].obs;

  var loadCount = 0;

  @override
  void onReady() {
    super.onReady();
    loadCount++;
    isLoading.value = true;
    posts.assignAll(['a']);
    isLoading.value = false;
  }
}

class _FilterTabs extends StatefulWidget {
  const _FilterTabs();

  @override
  State<_FilterTabs> createState() => _FilterTabsState();
}

class _FilterTabsState extends State<_FilterTabs> {
  static const _labels = ['最新', '热门', '关注'];
  static const _keys = ['latest', 'hot', 'following'];

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<_FeedVm>();
    final selected = _keys.indexOf(vm.feedTab.value);
    final activeIndex = selected < 0 ? 0 : selected;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final active = index == activeIndex;
          return GestureDetector(
            onTap: () async {
              vm.feedTab.value = _keys[index];
              if (mounted) setState(() {});
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_labels[index]),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 20 : 0,
                  height: 2,
                  color: Colors.blue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    Get.find<_FeedVm>();
    return Column(
      children: [
        const _FilterTabs(),
        Expanded(
          child: Obx(() {
            final vm = Get.find<_FeedVm>();
            if (vm.isLoading.value && vm.posts.isEmpty) {
              return const Text('loading');
            }
            return Text('count=${vm.posts.length}', key: const Key('count'));
          }),
        ),
      ],
    );
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets('onReady load + StatefulFilterTabs opens without Obx build error',
      (tester) async {
    Get.lazyPut(_FeedVm.new, fenix: true);

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: _Page())));
    expect(tester.takeException(), isNull);

    await tester.pump(); // onReady post-frame
    expect(tester.takeException(), isNull);
    expect(Get.find<_FeedVm>().loadCount, 1);
    expect(find.byKey(const Key('count')), findsOneWidget);

    await tester.tap(find.text('热门'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(Get.find<_FeedVm>().feedTab.value, 'hot');
  });
}
