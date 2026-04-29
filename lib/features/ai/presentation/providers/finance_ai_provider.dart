import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_preferences_provider.dart';
import '../../data/services/finance_ai_service.dart';

final financeAiServiceProvider = Provider<FinanceAiService>((ref) {
  final preferences = ref.watch(appPreferencesProvider).valueOrNull;
  return FinanceAiService(
    enabled: preferences?.aiAssistantEnabled ?? false,
    apiKey: preferences?.openAiApiKey,
  );
});
