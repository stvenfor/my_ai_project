import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/purchase_calculator/api/purchase_calculator_api.dart';
import 'package:module_settings/purchase_calculator/model/purchase_calculator_models.dart';

class PurchaseCalculatorController extends GetxController {
  PurchaseCalculatorController({PurchaseCalculatorApi? api})
      : _api = api ?? PurchaseCalculatorApi();

  final PurchaseCalculatorApi _api;

  final barePriceCtrl = TextEditingController(text: '100000');
  final taxablePriceCtrl = TextEditingController();
  final downPaymentCtrl = TextEditingController(text: '30000');

  final products = <FinanceProduct>[].obs;
  final loadingProducts = false.obs;
  final quoting = false.obs;
  final mode = 'cash'.obs;
  final disableCommercial = false.obs;
  final selectedProductId = RxnInt();
  final selectedTermMonths = RxnInt();
  final quote = Rxn<PurchaseQuote>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  @override
  void onClose() {
    barePriceCtrl.dispose();
    taxablePriceCtrl.dispose();
    downPaymentCtrl.dispose();
    super.onClose();
  }

  Future<void> loadProducts() async {
    loadingProducts.value = true;
    errorMessage.value = '';
    try {
      final list = await _api.listProducts();
      products.assignAll(list);
      if (list.isNotEmpty && selectedProductId.value == null) {
        selectedProductId.value = list.first.id;
        final terms = list.first.allowedTermsMonths;
        if (terms.isNotEmpty) {
          selectedTermMonths.value = terms.contains(36) ? 36 : terms.first;
        }
      }
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message;
      products.clear();
    } catch (_) {
      errorMessage.value = '加载金融产品失败';
      products.clear();
    } finally {
      loadingProducts.value = false;
    }
  }

  FinanceProduct? get selectedProduct {
    final id = selectedProductId.value;
    if (id == null) return null;
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  void setMode(String m) {
    mode.value = m;
    quote.value = null;
    errorMessage.value = '';
  }

  void selectProduct(int id) {
    selectedProductId.value = id;
    final p = selectedProduct;
    final terms = p?.allowedTermsMonths ?? const <int>[];
    if (terms.isNotEmpty &&
        (selectedTermMonths.value == null ||
            !terms.contains(selectedTermMonths.value))) {
      selectedTermMonths.value = terms.contains(36) ? 36 : terms.first;
    }
    quote.value = null;
  }

  Future<void> submitQuote() async {
    final bare = double.tryParse(barePriceCtrl.text.trim());
    if (bare == null || bare <= 0) {
      errorMessage.value = '请输入有效裸车价';
      quote.value = null;
      return;
    }
    double? taxable;
    final taxRaw = taxablePriceCtrl.text.trim();
    if (taxRaw.isNotEmpty) {
      taxable = double.tryParse(taxRaw);
      if (taxable == null || taxable <= 0) {
        errorMessage.value = '计税价格无效';
        quote.value = null;
        return;
      }
    }

    quoting.value = true;
    errorMessage.value = '';
    quote.value = null;
    try {
      if (mode.value == 'cash') {
        quote.value = await _api.quote(
          mode: 'cash',
          barePrice: bare,
          taxablePrice: taxable,
          productId: selectedProductId.value,
          disableCommercial: disableCommercial.value,
        );
      } else {
        final pid = selectedProductId.value;
        if (pid == null) {
          errorMessage.value = '请选择金融产品';
          return;
        }
        final down = double.tryParse(downPaymentCtrl.text.trim());
        if (down == null || down < 0) {
          errorMessage.value = '请输入有效首付';
          return;
        }
        final term = selectedTermMonths.value;
        if (term == null) {
          errorMessage.value = '请选择贷款期数';
          return;
        }
        quote.value = await _api.quote(
          mode: 'loan',
          barePrice: bare,
          taxablePrice: taxable,
          productId: pid,
          downPayment: down,
          termMonths: term,
          disableCommercial: disableCommercial.value,
        );
      }
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message;
      quote.value = null;
      UiKitInitializer.toastError(e.message);
    } catch (_) {
      errorMessage.value = '报价失败';
      quote.value = null;
      UiKitInitializer.toastError('报价失败');
    } finally {
      quoting.value = false;
    }
  }
}
