import '../../../../shared/finance_enums.dart';

class AiTransactionDraft {
  const AiTransactionDraft({
    this.type,
    this.amount,
    this.walletId,
    this.targetWalletId,
    this.categoryId,
    this.note,
    this.confidence = 0,
    this.reason = '',
    this.usedCloudAi = false,
  });

  final TransactionType? type;
  final int? amount;
  final String? walletId;
  final String? targetWalletId;
  final String? categoryId;
  final String? note;
  final double confidence;
  final String reason;
  final bool usedCloudAi;

  bool get hasMeaningfulSuggestion =>
      type != null ||
      amount != null ||
      walletId != null ||
      targetWalletId != null ||
      categoryId != null ||
      (note?.trim().isNotEmpty ?? false);
}
