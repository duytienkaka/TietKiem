import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client_provider.dart';

final authSessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.read(supabaseClientProvider);
  final controller = StreamController<Session?>.broadcast();

  controller.add(client.auth.currentSession);
  final subscription = client.auth.onAuthStateChange.listen((event) {
    controller.add(event.session);
  });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});
