class ScannedAccountQr {
  const ScannedAccountQr({
    required this.rawValue,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.paymentNote,
  });

  final String rawValue;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final String? paymentNote;
}
