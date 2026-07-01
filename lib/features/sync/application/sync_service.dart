import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/record_sync_status.dart';
import '../../food_log/application/nutrivo_go_store.dart';

enum SyncRunStatus { idle, syncing, success, failed }

class SyncService extends ChangeNotifier {
  SyncService({
    required this.client,
    required this.database,
    required this.store,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    unawaited(refreshPendingCount());
  }

  final SupabaseClient client;
  final AppDatabase database;
  final NutrivoGoStore store;
  final DateTime Function() _clock;

  SyncRunStatus _status = SyncRunStatus.idle;
  String? _message;
  DateTime? _lastSyncedAt;
  int _pendingCount = 0;

  SyncRunStatus get status => _status;

  String? get message => _message;

  DateTime? get lastSyncedAt => _lastSyncedAt;

  int get pendingCount => _pendingCount;

  bool get isSyncing => _status == SyncRunStatus.syncing;

  Future<void> refreshPendingCount() async {
    final productRows = await database.select(database.productRows).get();
    final logItemRows = await database.select(database.logItemRows).get();
    _pendingCount =
        productRows.where(_productNeedsSync).length +
        logItemRows.where(_logItemNeedsSync).length;
    notifyListeners();
  }

  Future<void> sync() async {
    final user = client.auth.currentUser;
    if (user == null) {
      _status = SyncRunStatus.failed;
      _message = 'Sign in before syncing.';
      notifyListeners();
      return;
    }

    _status = SyncRunStatus.syncing;
    _message = 'Syncing local changes.';
    notifyListeners();

    try {
      await _pullProducts(user.id);
      await _pullLogItems(user.id);
      await _pushProducts(user.id);
      await _pushLogItems(user.id);
      await store.load();
      await refreshPendingCount();
      _status = SyncRunStatus.success;
      _lastSyncedAt = _clock();
      _message = _pendingCount == 0
          ? 'Sync complete.'
          : 'Sync complete with $_pendingCount pending item(s).';
    } on Object catch (error) {
      await _markPendingAsFailed(user.id);
      await refreshPendingCount();
      _status = SyncRunStatus.failed;
      _message = 'Sync failed: $error';
    } finally {
      notifyListeners();
    }
  }

  Future<void> _pullProducts(String userId) async {
    final remoteRows = await client
        .from('products')
        .select()
        .eq('user_id', userId);

    for (final remote in remoteRows) {
      final row = Map<String, dynamic>.from(remote);
      final id = row['id'] as String;
      final local = await (database.select(
        database.productRows,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (local != null && !_sameOrUnownedUser(local.userId, userId)) {
        continue;
      }

      final remoteUpdatedAt = _readDate(row['updated_at']);
      final shouldApply =
          local == null ||
          !local.updatedAt.toUtc().isAfter(remoteUpdatedAt.toUtc());
      if (!shouldApply) {
        continue;
      }

      await database
          .into(database.productRows)
          .insertOnConflictUpdate(_productCompanionFromRemote(row, userId));
    }
  }

  Future<void> _pullLogItems(String userId) async {
    final remoteRows = await client
        .from('log_items')
        .select()
        .eq('user_id', userId);

    for (final remote in remoteRows) {
      final row = Map<String, dynamic>.from(remote);
      final id = row['id'] as String;
      final productId = row['product_id'] as String;
      final productExists =
          await (database.select(
            database.productRows,
          )..where((table) => table.id.equals(productId))).getSingleOrNull() !=
          null;
      if (!productExists) {
        continue;
      }

      final local = await (database.select(
        database.logItemRows,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (local != null && !_sameOrUnownedUser(local.userId, userId)) {
        continue;
      }

      final remoteUpdatedAt = _readDate(row['updated_at']);
      final shouldApply =
          local == null ||
          !local.updatedAt.toUtc().isAfter(remoteUpdatedAt.toUtc());
      if (!shouldApply) {
        continue;
      }

      await database
          .into(database.logItemRows)
          .insertOnConflictUpdate(_logItemCompanionFromRemote(row, userId));
    }
  }

  Future<void> _pushProducts(String userId) async {
    final rows = await database.select(database.productRows).get();
    for (final row in rows.where(
      (row) => _canPush(row.userId, userId) && _productNeedsSync(row),
    )) {
      await client
          .from('products')
          .upsert(_productRemoteMap(row, userId), onConflict: 'id');
      await (database.update(
        database.productRows,
      )..where((table) => table.id.equals(row.id))).write(
        ProductRowsCompanion(
          userId: Value(userId),
          syncStatus: Value(RecordSyncStatus.synced.storageValue),
          lastSyncedAt: Value(_clock()),
        ),
      );
    }
  }

  Future<void> _pushLogItems(String userId) async {
    final rows = await database.select(database.logItemRows).get();
    for (final row in rows.where(
      (row) => _canPush(row.userId, userId) && _logItemNeedsSync(row),
    )) {
      await client
          .from('log_items')
          .upsert(_logItemRemoteMap(row, userId), onConflict: 'id');
      await (database.update(
        database.logItemRows,
      )..where((table) => table.id.equals(row.id))).write(
        LogItemRowsCompanion(
          userId: Value(userId),
          syncStatus: Value(RecordSyncStatus.synced.storageValue),
          lastSyncedAt: Value(_clock()),
        ),
      );
    }
  }

  Future<void> _markPendingAsFailed(String userId) async {
    final products = await database.select(database.productRows).get();
    for (final row in products.where(
      (row) => _canPush(row.userId, userId) && _productNeedsSync(row),
    )) {
      await (database.update(
        database.productRows,
      )..where((table) => table.id.equals(row.id))).write(
        ProductRowsCompanion(
          syncStatus: Value(RecordSyncStatus.failed.storageValue),
        ),
      );
    }

    final logItems = await database.select(database.logItemRows).get();
    for (final row in logItems.where(
      (row) => _canPush(row.userId, userId) && _logItemNeedsSync(row),
    )) {
      await (database.update(
        database.logItemRows,
      )..where((table) => table.id.equals(row.id))).write(
        LogItemRowsCompanion(
          syncStatus: Value(RecordSyncStatus.failed.storageValue),
        ),
      );
    }
  }

  ProductRowsCompanion _productCompanionFromRemote(
    Map<String, dynamic> row,
    String userId,
  ) {
    final now = _clock();
    return ProductRowsCompanion(
      id: Value(row['id'] as String),
      userId: Value(userId),
      name: Value(row['name'] as String),
      brand: Value(row['brand'] as String?),
      servingSize: Value((row['serving_size'] as num?)?.toDouble()),
      servingUnit: Value(row['serving_unit'] as String?),
      baseUnit: Value(row['base_unit'] as String),
      caloriesPer100: Value((row['calories_per_100'] as num).toDouble()),
      proteinPer100: Value((row['protein_per_100'] as num).toDouble()),
      carbsPer100: Value((row['carbs_per_100'] as num).toDouble()),
      fatPer100: Value((row['fat_per_100'] as num).toDouble()),
      createdAt: Value(_readDate(row['created_at'])),
      updatedAt: Value(_readDate(row['updated_at'])),
      deletedAt: Value(_readNullableDate(row['deleted_at'])),
      syncStatus: Value(RecordSyncStatus.synced.storageValue),
      lastSyncedAt: Value(now),
    );
  }

  LogItemRowsCompanion _logItemCompanionFromRemote(
    Map<String, dynamic> row,
    String userId,
  ) {
    final now = _clock();
    return LogItemRowsCompanion(
      id: Value(row['id'] as String),
      userId: Value(userId),
      productId: Value(row['product_id'] as String),
      mealType: Value(row['meal_type'] as String),
      quantity: Value((row['quantity'] as num).toDouble()),
      unit: Value(row['unit'] as String),
      calories: Value((row['calories'] as num).toDouble()),
      protein: Value((row['protein'] as num).toDouble()),
      carbs: Value((row['carbs'] as num).toDouble()),
      fat: Value((row['fat'] as num).toDouble()),
      createdAt: Value(_readDate(row['created_at'])),
      updatedAt: Value(_readDate(row['updated_at'])),
      deletedAt: Value(_readNullableDate(row['deleted_at'])),
      syncStatus: Value(RecordSyncStatus.synced.storageValue),
      lastSyncedAt: Value(now),
    );
  }

  Map<String, dynamic> _productRemoteMap(ProductRow row, String userId) {
    return {
      'id': row.id,
      'user_id': userId,
      'name': row.name,
      'brand': row.brand,
      'serving_size': row.servingSize,
      'serving_unit': row.servingUnit,
      'base_unit': row.baseUnit,
      'calories_per_100': row.caloriesPer100,
      'protein_per_100': row.proteinPer100,
      'carbs_per_100': row.carbsPer100,
      'fat_per_100': row.fatPer100,
      'created_at': _toIso(row.createdAt),
      'updated_at': _toIso(row.updatedAt),
      'deleted_at': _toIsoOrNull(row.deletedAt),
    };
  }

  Map<String, dynamic> _logItemRemoteMap(LogItemRow row, String userId) {
    return {
      'id': row.id,
      'user_id': userId,
      'product_id': row.productId,
      'meal_type': row.mealType,
      'quantity': row.quantity,
      'unit': row.unit,
      'calories': row.calories,
      'protein': row.protein,
      'carbs': row.carbs,
      'fat': row.fat,
      'created_at': _toIso(row.createdAt),
      'updated_at': _toIso(row.updatedAt),
      'deleted_at': _toIsoOrNull(row.deletedAt),
    };
  }

  bool _productNeedsSync(ProductRow row) {
    return row.syncStatus != RecordSyncStatus.synced.storageValue ||
        row.userId == null;
  }

  bool _logItemNeedsSync(LogItemRow row) {
    return row.syncStatus != RecordSyncStatus.synced.storageValue ||
        row.userId == null;
  }

  bool _canPush(String? rowUserId, String currentUserId) {
    return rowUserId == null || rowUserId == currentUserId;
  }

  bool _sameOrUnownedUser(String? rowUserId, String currentUserId) {
    return rowUserId == null || rowUserId == currentUserId;
  }

  DateTime _readDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    throw FormatException('Expected a timestamp, got $value');
  }

  DateTime? _readNullableDate(Object? value) {
    if (value == null) {
      return null;
    }
    return _readDate(value);
  }

  String _toIso(DateTime value) {
    return value.toUtc().toIso8601String();
  }

  String? _toIsoOrNull(DateTime? value) {
    if (value == null) {
      return null;
    }
    return _toIso(value);
  }
}
