class MonthlySpendingSummary {
  const MonthlySpendingSummary({
    required this.headline,
    required this.summary,
    required this.bullets,
    this.usedCloudAi = false,
  });

  final String headline;
  final String summary;
  final List<String> bullets;
  final bool usedCloudAi;
}
