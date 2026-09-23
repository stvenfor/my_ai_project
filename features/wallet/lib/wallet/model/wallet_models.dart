class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.balanceFen,
    required this.cards,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>? ?? const [];
    return WalletSummary(
      balance: json['balance']?.toString() ?? '0.00',
      balanceFen: (json['balance_fen'] as num?)?.toInt() ?? 0,
      cards: [
        for (final c in rawCards)
          if (c is Map<String, dynamic>) BankCard.fromJson(c),
      ],
    );
  }

  final String balance;
  final int balanceFen;
  final List<BankCard> cards;
}

class BankCard {
  const BankCard({
    required this.cardId,
    required this.bankName,
    required this.cardLast4,
    this.holderName = '',
    this.isDefault = false,
  });

  factory BankCard.fromJson(Map<String, dynamic> json) {
    return BankCard(
      cardId: (json['card_id'] as num?)?.toInt() ?? 0,
      bankName: json['bank_name']?.toString() ?? '',
      cardLast4: json['card_last4']?.toString() ?? '',
      holderName: json['holder_name']?.toString() ?? '',
      isDefault: json['is_default'] == true,
    );
  }

  final int cardId;
  final String bankName;
  final String cardLast4;
  final String holderName;
  final bool isDefault;

  String get display => '$bankName(****$cardLast4)';
}

class WalletLedgerEntry {
  const WalletLedgerEntry({
    required this.ledgerId,
    required this.deltaFen,
    required this.balanceFen,
    required this.reason,
    this.refId = '',
  });

  factory WalletLedgerEntry.fromJson(Map<String, dynamic> json) {
    return WalletLedgerEntry(
      ledgerId: (json['ledger_id'] as num?)?.toInt() ?? 0,
      deltaFen: (json['delta_fen'] as num?)?.toInt() ?? 0,
      balanceFen: (json['balance_fen'] as num?)?.toInt() ?? 0,
      reason: json['reason']?.toString() ?? '',
      refId: json['ref_id']?.toString() ?? '',
    );
  }

  final int ledgerId;
  final int deltaFen;
  final int balanceFen;
  final String reason;
  final String refId;

  String get deltaYuan {
    final neg = deltaFen < 0;
    final v = deltaFen.abs();
    final s = '${v ~/ 100}.${(v % 100).toString().padLeft(2, '0')}';
    return neg ? '-$s' : '+$s';
  }

  String get reasonLabel {
    switch (reason) {
      case 'recharge':
        return '充值';
      case 'mall_pay':
        return '商城支付';
      case 'mall_refund':
        return '商城退款入账';
      default:
        return reason;
    }
  }
}

class WalletRechargeResult {
  const WalletRechargeResult({
    required this.balance,
    required this.balanceFen,
    required this.deltaFen,
  });

  factory WalletRechargeResult.fromJson(Map<String, dynamic> json) {
    return WalletRechargeResult(
      balance: json['balance']?.toString() ?? '0.00',
      balanceFen: (json['balance_fen'] as num?)?.toInt() ?? 0,
      deltaFen: (json['delta_fen'] as num?)?.toInt() ?? 0,
    );
  }

  final String balance;
  final int balanceFen;
  final int deltaFen;
}
