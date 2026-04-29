import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_session_provider.dart';
import 'app_preferences_provider.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();

  ref.listen(authSessionProvider, (_, _) => notifier.refresh());
  ref.listen(appPreferencesProvider, (_, _) => notifier.refresh());

  ref.onDispose(notifier.dispose);
  return notifier;
});
