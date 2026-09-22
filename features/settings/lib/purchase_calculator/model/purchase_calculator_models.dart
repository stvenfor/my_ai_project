/// 购车计算器 API 模型（服务端报价为准）。
class FinanceProduct {
  const FinanceProduct({
    required this.id,
    required this.name,
    required this.annualRatePercent,
    required this.allowedTermsMonths,
    required this.minDownPaymentPercent,
    required this.oneTimeFee,
    required this.subsidyType,
    this.subsidyRateCutPercent = 0,
    this.subsidyAmountCut = 0,
    required this.compulsoryInsurance,
    required this.commercialRatePercent,
  });

  factory FinanceProduct.fromJson(Map<String, dynamic> json) {
    final terms = (json['allowed_terms_months'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const <int>[];
    return FinanceProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      annualRatePercent: (json['annual_rate_percent'] as num?)?.toDouble() ?? 0,
      allowedTermsMonths: terms,
      minDownPaymentPercent:
          (json['min_down_payment_percent'] as num?)?.toDouble() ?? 0,
      oneTimeFee: (json['one_time_fee'] as num?)?.toDouble() ?? 0,
      subsidyType: (json['subsidy_type'] as num?)?.toInt() ?? 0,
      subsidyRateCutPercent:
          (json['subsidy_rate_cut_percent'] as num?)?.toDouble() ?? 0,
      subsidyAmountCut: (json['subsidy_amount_cut'] as num?)?.toDouble() ?? 0,
      compulsoryInsurance:
          (json['compulsory_insurance'] as num?)?.toDouble() ?? 0,
      commercialRatePercent:
          (json['commercial_rate_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  final int id;
  final String name;
  final double annualRatePercent;
  final List<int> allowedTermsMonths;
  final double minDownPaymentPercent;
  final double oneTimeFee;
  final int subsidyType;
  final double subsidyRateCutPercent;
  final double subsidyAmountCut;
  final double compulsoryInsurance;
  final double commercialRatePercent;
}

class PurchaseQuoteLine {
  const PurchaseQuoteLine({
    required this.code,
    required this.label,
    required this.amount,
  });

  factory PurchaseQuoteLine.fromJson(Map<String, dynamic> json) {
    return PurchaseQuoteLine(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  final String code;
  final String label;
  final double amount;
}

class PurchaseQuote {
  const PurchaseQuote({
    required this.mode,
    this.productId,
    this.productName = '',
    required this.barePrice,
    required this.taxablePrice,
    this.downPayment = 0,
    this.loanAmount = 0,
    this.termMonths = 0,
    this.effectiveAnnualRate = 0,
    this.monthlyPayment = 0,
    this.totalInterest = 0,
    this.totalRepayment = 0,
    required this.initialPayment,
    required this.totalDue,
    required this.lines,
  });

  factory PurchaseQuote.fromJson(Map<String, dynamic> json) {
    final lines = (json['lines'] as List?)
            ?.whereType<Map>()
            .map((e) => PurchaseQuoteLine.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        const <PurchaseQuoteLine>[];
    return PurchaseQuote(
      mode: json['mode']?.toString() ?? '',
      productId: (json['product_id'] as num?)?.toInt(),
      productName: json['product_name']?.toString() ?? '',
      barePrice: (json['bare_price'] as num?)?.toDouble() ?? 0,
      taxablePrice: (json['taxable_price'] as num?)?.toDouble() ?? 0,
      downPayment: (json['down_payment'] as num?)?.toDouble() ?? 0,
      loanAmount: (json['loan_amount'] as num?)?.toDouble() ?? 0,
      termMonths: (json['term_months'] as num?)?.toInt() ?? 0,
      effectiveAnnualRate:
          (json['effective_annual_rate_percent'] as num?)?.toDouble() ?? 0,
      monthlyPayment: (json['monthly_payment'] as num?)?.toDouble() ?? 0,
      totalInterest: (json['total_interest'] as num?)?.toDouble() ?? 0,
      totalRepayment: (json['total_repayment'] as num?)?.toDouble() ?? 0,
      initialPayment: (json['initial_payment'] as num?)?.toDouble() ?? 0,
      totalDue: (json['total_due'] as num?)?.toDouble() ?? 0,
      lines: lines,
    );
  }

  final String mode;
  final int? productId;
  final String productName;
  final double barePrice;
  final double taxablePrice;
  final double downPayment;
  final double loanAmount;
  final int termMonths;
  final double effectiveAnnualRate;
  final double monthlyPayment;
  final double totalInterest;
  final double totalRepayment;
  final double initialPayment;
  final double totalDue;
  final List<PurchaseQuoteLine> lines;
}
