class ScannedBillQr {
  const ScannedBillQr({
    required this.rawValue,
    this.amount,
    this.merchant,
    this.note,
  });

  final String rawValue;
  final int? amount;
  final String? merchant;
  final String? note;

  String? get composedNote {
    final values = [merchant, note]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (values.isEmpty) {
      return null;
    }
    return values.join(' • ');
  }
}
