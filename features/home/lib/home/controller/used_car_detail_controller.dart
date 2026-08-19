import 'package:get/get.dart';
import 'package:module_home/home/repository/transaction_repository.dart';
import 'package:module_home/home/model/transaction_model.dart';

class UsedCarDetailController extends GetxController {
  UsedCarDetailController({TransactionRepository? repository})
      : _repository = repository ?? Get.find<TransactionRepository>();

  final TransactionRepository _repository;

  final transaction = Rxn<TransactionModel>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final int transactionId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      transactionId = args;
    } else if (args is String) {
      transactionId = int.tryParse(args) ?? 0;
    } else {
      transactionId = 0;
    }
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (transactionId <= 0) {
      errorMessage.value = '无效的记录 ID';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      transaction.value = await _repository.fetchById(transactionId);
    } catch (error) {
      errorMessage.value = formatTransactionLoadError(error);
    } finally {
      isLoading.value = false;
    }
  }
}
