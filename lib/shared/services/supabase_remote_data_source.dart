import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/supabase_client_provider.dart';

final supabaseRemoteDataSourceProvider = Provider<SupabaseRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRemoteDataSource(client);
});

class SupabaseRemoteDataSource {
  SupabaseRemoteDataSource(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  RealtimeChannel subscribeTable({
    required String channelKey,
    required String table,
    required void Function(PostgresChangePayload payload) onChange,
    String? filterColumn,
    String? filterValue,
  }) {
    final channel = _client.channel(channelKey);
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      filter: filterColumn == null || filterValue == null
          ? null
          : PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: filterColumn,
              value: filterValue,
            ),
      callback: onChange,
    );
    channel.subscribe();
    return channel;
  }

  Future<List<Map<String, dynamic>>> fetchWallets() async {
    final response = await _client
        .from('wallets')
        .select('id,name,type,balance,color,icon,created_at,updated_at,deleted_at')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchWalletMembers(String walletId) async {
    final response = await _client
        .from('wallet_members')
        .select('id,wallet_id,user_id,role,created_at')
        .eq('wallet_id', walletId);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchCategories(String walletId) async {
    final response = await _client
        .from('categories')
        .select()
        .eq('wallet_id', walletId)
        .order('updated_at', ascending: true);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchBudgets(String walletId) async {
    final response = await _client
        .from('budgets')
        .select()
        .eq('wallet_id', walletId)
        .order('updated_at', ascending: true);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchTransactionsForWallet(String walletId) async {
    final source = await _client
        .from('transactions')
        .select()
        .eq('wallet_id', walletId)
        .order('updated_at', ascending: true);
    final target = await _client
        .from('transactions')
        .select()
        .eq('target_wallet_id', walletId)
        .order('updated_at', ascending: true);

    final merged = <String, Map<String, dynamic>>{};
    for (final row in (source as List<dynamic>).cast<Map<String, dynamic>>()) {
      merged[row['id'] as String] = row;
    }
    for (final row in (target as List<dynamic>).cast<Map<String, dynamic>>()) {
      merged[row['id'] as String] = row;
    }
    return merged.values.toList()
      ..sort(
        (a, b) => DateTime.parse(a['updated_at'] as String)
            .compareTo(DateTime.parse(b['updated_at'] as String)),
      );
  }

  Future<void> upsert({
    required String table,
    required Map<String, dynamic> payload,
  }) {
    return _client.from(table).upsert(payload);
  }

  Future<void> inviteUserToWallet({
    required String walletId,
    required String email,
    String role = 'editor',
  }) {
    return _client.rpc(
      'invite_user_to_wallet',
      params: {
        'target_wallet_id': walletId,
        'member_email': email.trim().toLowerCase(),
        'member_role': role,
      },
    );
  }
}
