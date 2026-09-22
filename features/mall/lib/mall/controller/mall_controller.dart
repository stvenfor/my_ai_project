import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_mall/mall/api/mall_api.dart';
import 'package:module_mall/mall/model/mall_product_model.dart';
import 'package:module_mall/mall/repository/mall_repository.dart';
import 'package:wys_router/src/route/route_path.dart';

class MallController extends GetxController {
  MallController({MallRepository? repository})
      : _repository = repository ?? MallRepository();

  final MallRepository _repository;

  final products = <MallProductCardModel>[].obs;
  final loading = true.obs;
  final loadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  final categoryIndex = 0.obs;
  final filterIndex = 1.obs; // 默认「热兑」对齐参考图
  final searchHint = '视频会员卡'.obs;

  static const categories = [
    '推荐',
    '0元起兑',
    '国庆季',
    '钻铂专享',
    '数码家电',
    '生活好物',
  ];

  static const filters = ['积分', '热兑', '上新', '筛选'];

  int _page = 0;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }

  void selectCategory(int index) {
    if (categoryIndex.value == index) return;
    categoryIndex.value = index;
    UiKitInitializer.toast('${categories[index]}（筛选开发中）');
  }

  void selectFilter(int index) {
    if (filterIndex.value == index) return;
    filterIndex.value = index;
    UiKitInitializer.toast('${filters[index]}（筛选开发中）');
  }

  void onSearchTap() {
    UiKitInitializer.toast('搜索「${searchHint.value}」（开发中）');
  }

  void onFloatTap(String label) {
    UiKitInitializer.toast('$label（开发中）');
  }

  Future<void> loadFirstPage() async {
    loading.value = true;
    errorMessage.value = '';
    _page = 0;
    hasMore.value = true;
    try {
      final page = await _repository.fetchPage(page: 1);
      products.assignAll(page.list);
      _page = 1;
      hasMore.value = page.hasMore;
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message.isEmpty ? '加载失败' : e.message;
      products.clear();
      UiKitInitializer.toast(errorMessage.value);
    } catch (e) {
      errorMessage.value = e.toString();
      products.clear();
      UiKitInitializer.toast('加载商品失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || loadingMore.value || loading.value) return;
    loadingMore.value = true;
    try {
      final next = _page + 1;
      final page = await _repository.fetchPage(page: next);
      products.addAll(page.list);
      _page = next;
      hasMore.value = page.hasMore;
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '加载更多失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('加载更多失败');
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> onRefresh() => loadFirstPage();

  void onProductTap(MallProductCardModel item) {
    Get.toNamed(RoutePath.mallDetail, arguments: item.id);
  }

  static const pageSize = MallApi.pageSize;
}
