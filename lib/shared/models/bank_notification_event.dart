class BankNotificationEvent {
  const BankNotificationEvent({
    required this.packageName,
    required this.postedAt,
    this.title,
    this.body,
    this.subText,
    this.bigText,
    this.summaryText,
    this.textLines,
  });

  final String packageName;
  final DateTime postedAt;
  final String? title;
  final String? body;
  final String? subText;
  final String? bigText;
  final String? summaryText;
  final String? textLines;

  factory BankNotificationEvent.fromJson(Map<Object?, Object?> json) {
    return BankNotificationEvent(
      packageName: json['packageName'] as String? ?? '',
      postedAt: DateTime.tryParse(json['postedAt'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      title: json['title'] as String?,
      body: json['body'] as String?,
      subText: json['subText'] as String?,
      bigText: json['bigText'] as String?,
      summaryText: json['summaryText'] as String?,
      textLines: json['textLines'] as String?,
    );
  }

  String get combinedText => [
        title?.trim(),
        body?.trim(),
        subText?.trim(),
        bigText?.trim(),
        summaryText?.trim(),
        textLines?.trim(),
        packageName.trim(),
      ].whereType<String>().where((item) => item.isNotEmpty).join(' ');

  String get sourceKey => [
        packageName.trim(),
        postedAt.toIso8601String(),
        title?.trim() ?? '',
        body?.trim() ?? '',
        subText?.trim() ?? '',
        bigText?.trim() ?? '',
        summaryText?.trim() ?? '',
        textLines?.trim() ?? '',
      ].join('|');
}
