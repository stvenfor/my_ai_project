import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_wallet/wallet/api/wallet_api.dart';
import 'package:module_wallet/wallet/model/wallet_models.dart';

class WalletController extends GetxController {
  WalletController({WalletApi? api}) : _api = api ?? WalletApi();

  final WalletApi _api;

  final summary = Rxn<WalletSummary>();
  final ledger = <WalletLedgerEntry>[].obs;
  final loading = true.obs;
  final acting = false.obs;
  final errorMessage = ''.obs;

  final amountCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final last4Ctrl = TextEditingController();

  /// 1 支付宝 2 微信 3 银行卡
  final rechargeChannel = 1.obs;
  final selectedCardId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    bankNameCtrl.dispose();
    last4Ctrl.dispose();
    super.onClose();
  }

  Future<void> refreshAll() async {
    loading.value = true;
    errorMessage.value = '';
    try {
      summary.value = await _api.fetchSummary();
      ledger.assignAll(await _api.fetchLedger());
      final cards = summary.value?.cards ?? const <BankCard>[];
      final def = cards.where((c) => c.isDefault).toList();
      if (def.isNotEmpty) {
        selectedCardId.value = def.first.cardId;
      } else if (cards.isNotEmpty) {
        selectedCardId.value = cards.first.cardId;
      }
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message.isEmpty ? '加载失败' : e.message;
    } catch (_) {
      errorMessage.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> recharge() async {
    if (acting.value) return;
    final amount = amountCtrl.text.trim();
    if (amount.isEmpty) {
      UiKitInitializer.toast('请输入金额');
      return;
    }
    acting.value = true;
    try {
      final ch = rechargeChannel.value;
      await _api.recharge(
        amount: amount,
        channel: ch,
        cardId: ch == 3 ? selectedCardId.value : null,
      );
      amountCtrl.clear();
      UiKitInitializer.toast('充值成功');
      await refreshAll();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '充值失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('充值失败');
    } finally {
      acting.value = false;
    }
  }

  Future<void> bindCard() async {
    if (acting.value) return;
    final bank = bankNameCtrl.text.trim();
    final last4 = last4Ctrl.text.trim();
    if (bank.isEmpty || last4.length != 4) {
      UiKitInitializer.toast('请填写银行名与卡号后四位');
      return;
    }
    acting.value = true;
    try {
      await _api.bindCard(bankName: bank, cardLast4: last4);
      bankNameCtrl.clear();
      last4Ctrl.clear();
      UiKitInitializer.toast('绑卡成功');
      await refreshAll();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '绑卡失败' : e.message);
    } catch (_) {
      UiKitInitializer.toast('绑卡失败');
    } finally {
      acting.value = false;
    }
  }

  Future<void> setDefault(int cardId) async {
    try {
      await _api.setDefaultCard(cardId);
      await refreshAll();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '设置失败' : e.message);
    }
  }

  Future<void> deleteCard(int cardId) async {
    try {
      await _api.deleteCard(cardId);
      await refreshAll();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '删除失败' : e.message);
    }
  }
}
