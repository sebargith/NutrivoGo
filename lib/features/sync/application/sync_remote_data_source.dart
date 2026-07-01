import 'package:supabase/supabase.dart';

abstract class SyncRemoteDataSource {
  String? get currentUserId;

  String? get currentUserEmail;

  Future<List<Map<String, dynamic>>> fetchProducts(String userId);

  Future<List<Map<String, dynamic>>> fetchLogItems(String userId);

  Future<void> upsertProduct(Map<String, dynamic> row);

  Future<void> upsertLogItem(Map<String, dynamic> row);
}

class SupabaseSyncRemoteDataSource implements SyncRemoteDataSource {
  const SupabaseSyncRemoteDataSource({required this.client});

  final SupabaseClient client;

  @override
  String? get currentUserId => client.auth.currentUser?.id;

  @override
  String? get currentUserEmail => client.auth.currentUser?.email;

  @override
  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    final rows = await client.from('products').select().eq('user_id', userId);
    return [for (final row in rows) Map<String, dynamic>.from(row)];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLogItems(String userId) async {
    final rows = await client.from('log_items').select().eq('user_id', userId);
    return [for (final row in rows) Map<String, dynamic>.from(row)];
  }

  @override
  Future<void> upsertProduct(Map<String, dynamic> row) async {
    await client.from('products').upsert(row, onConflict: 'id');
  }

  @override
  Future<void> upsertLogItem(Map<String, dynamic> row) async {
    await client.from('log_items').upsert(row, onConflict: 'id');
  }
}
