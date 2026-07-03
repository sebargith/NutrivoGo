import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/record_sync_status.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import 'sync_remote_data_source.dart';

enum SyncRunStatus {
  notLoggedIn,
  idle,
  syncing,
  synced,
  failed,
  offlinePending,
}

class SyncService extends ChangeNotifier {
  SyncService({
    required this.remote,
    required this.database,
    required this.store,
    DateTime Function()? clock,
    this._autoSyncDebounce = const Duration(seconds: 2),
    this._autoSyncEnabled = true,
    this._remoteSyncInterval = const Duration(seconds: 30),
  }) : _clock = clock ?? DateTime.now,
       _lastSeenLocalChangeVersion = store.localChangeVersion {
    store.addListener(_handleStoreChanged);
    unawaited(handleAuthChanged());
  }

  factory SyncService.withSupabaseClient({
    required SupabaseClient client,
    required AppDatabase database,
    required NutrivoGoStore store,
    DateTime Function()? clock,
    Duration autoSyncDebounce = const Duration(seconds: 2),
    bool autoSyncEnabled = true,
    Duration remoteSyncInterval = const Duration(seconds: 30),
  }) {
    return SyncService(
      remote: SupabaseSyncRemoteDataSource(client: client),
      database: database,
      store: store,
      clock: clock,
      autoSyncDebounce: autoSyncDebounce,
      autoSyncEnabled: autoSyncEnabled,
      remoteSyncInterval: remoteSyncInterval,
    );
  }

  final SyncRemoteDataSource remote;
  final AppDatabase database;
  final NutrivoGoStore store;
  final DateTime Function() _clock;
  final Duration _autoSyncDebounce;
  final bool _autoSyncEnabled;
  final Duration _remoteSyncInterval;

  SyncRunStatus _status = SyncRunStatus.notLoggedIn;
  String? _message;
  String? _lastError;
  DateTime? _lastSuccessfulSyncAt;
  int _pendingProductCount = 0;
  int _pendingLogItemCount = 0;
  bool _disposed = false;
  Timer? _autoSyncTimer;
  Timer? _remoteSyncTimer;
  Future<void>? _runningSync;
  int _lastSeenLocalChangeVersion;

  SyncRunStatus get status => _status;

  String? get message => _message;

  String? get lastError => _lastError;

  DateTime? get lastSuccessfulSyncAt => _lastSuccessfulSyncAt;

  DateTime? get lastSyncedAt => _lastSuccessfulSyncAt;

  int get pendingProductCount => _pendingProductCount;

  int get pendingLogItemCount => _pendingLogItemCount;

  int get pendingCount => _pendingProductCount + _pendingLogItemCount;

  bool get isSyncing => _status == SyncRunStatus.syncing;

  Future<void> waitForIdle() {
    return _runningSync ?? Future<void>.value();
  }

  Future<void> handleAuthChanged() async {
    final currentUserId = remote.currentUserId;
    final userChanged = store.activeUserId != currentUserId;
    await store.setActiveUserId(currentUserId);
    if (userChanged && !isSyncing) {
      _lastError = null;
      _message = currentUserId == null
          ? 'Logged out. Local data remains on this device.'
          : null;
      _status = currentUserId == null
          ? SyncRunStatus.notLoggedIn
          : SyncRunStatus.idle;
    }
    await refreshPendingCount();
    if (currentUserId == null) {
      _stopAutomaticSync();
      return;
    }
    _startRemoteSyncPolling();
    if (userChanged) {
      _scheduleAutoSync(delay: Duration.zero);
    }
  }

  Future<void> refreshPendingCount() async {
    final currentUserId = remote.currentUserId;
    final productRows = await database.select(database.productRows).get();
    final logItemRows = await database.select(database.logItemRows).get();

    _pendingProductCount = productRows
        .where(
          (row) =>
              _canManageRow(row.userId, currentUserId) &&
              _productNeedsSync(row),
        )
        .length;
    _pendingLogItemCount = logItemRows
        .where(
          (row) =>
              _canManageRow(row.userId, currentUserId) &&
              _logItemNeedsSync(row),
        )
        .length;

    if (!isSyncing && _status != SyncRunStatus.failed) {
      _statusForIdleAuthState();
    }
    _notifyIfAlive();
  }

  Future<void> sync() async {
    if (isSyncing) {
      return waitForIdle();
    }
    final run = _sync();
    _runningSync = run.whenComplete(() => _runningSync = null);
    return _runningSync!;
  }

  Future<void> _sync() async {
    _autoSyncTimer?.cancel();

    final userId = remote.currentUserId;
    if (userId == null) {
      _status = SyncRunStatus.notLoggedIn;
      _message = 'Log in to sync local changes.';
      _lastError = null;
      _notifyIfAlive();
      return;
    }

    _status = SyncRunStatus.syncing;
    _message = 'Syncing changes.';
    _lastError = null;
    _notifyIfAlive();

    try {
      await _pullProducts(userId);
      await _pullLogItems(userId);
      await _pushProducts(userId);
      await _pushLogItems(userId);
      await store.load();
      await refreshPendingCount();
      _lastSuccessfulSyncAt = _clock();
      _lastError = null;
      _status = pendingCount == 0
          ? SyncRunStatus.synced
          : SyncRunStatus.offlinePending;
      _message = pendingCount == 0
          ? 'Sync complete.'
          : 'Sync complete with $pendingCount pending item(s).';
    } on Object catch (error) {
      await refreshPendingCount();
      _status = SyncRunStatus.failed;
      _lastError = _describeSyncError(error);
      _message = _lastError;
    } finally {
      _notifyIfAlive();
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _autoSyncTimer?.cancel();
    _remoteSyncTimer?.cancel();
    store.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void syncWhenAppResumes() {
    if (remote.currentUserId == null || isSyncing) {
      return;
    }
    _scheduleAutoSync(delay: Duration.zero);
  }

  Future<void> _pullProducts(String userId) async {
    final remoteRows = await remote.fetchProducts(userId);

    for (final row in remoteRows) {
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
    final remoteRows = await remote.fetchLogItems(userId);

    for (final row in remoteRows) {
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
      await remote.upsertProduct(_productRemoteMap(row, userId));
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
      await remote.upsertLogItem(_logItemRemoteMap(row, userId));
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
      barcode: Value(row['barcode'] as String?),
      source: Value(row['source'] as String?),
      sugarPer100: Value((row['sugar_per_100'] as num?)?.toDouble()),
      saturatedFatPer100: Value(
        (row['saturated_fat_per_100'] as num?)?.toDouble(),
      ),
      sodiumPer100: Value((row['sodium_per_100'] as num?)?.toDouble()),
      fiberPer100: Value((row['fiber_per_100'] as num?)?.toDouble()),
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
      'barcode': row.barcode,
      'source': row.source,
      'sugar_per_100': row.sugarPer100,
      'saturated_fat_per_100': row.saturatedFatPer100,
      'sodium_per_100': row.sodiumPer100,
      'fiber_per_100': row.fiberPer100,
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

  void _handleStoreChanged() {
    unawaited(refreshPendingCount());
    if (store.localChangeVersion == _lastSeenLocalChangeVersion) {
      return;
    }
    _lastSeenLocalChangeVersion = store.localChangeVersion;
    _scheduleAutoSync();
  }

  void _scheduleAutoSync({Duration? delay}) {
    if (!_autoSyncEnabled || remote.currentUserId == null || isSyncing) {
      return;
    }
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer(delay ?? _autoSyncDebounce, () {
      if (_disposed || isSyncing || remote.currentUserId == null) {
        return;
      }
      unawaited(sync());
    });
  }

  void _startRemoteSyncPolling() {
    if (!_autoSyncEnabled ||
        _remoteSyncInterval <= Duration.zero ||
        remote.currentUserId == null ||
        _remoteSyncTimer != null) {
      return;
    }
    _remoteSyncTimer = Timer.periodic(_remoteSyncInterval, (_) {
      if (_disposed || isSyncing || remote.currentUserId == null) {
        return;
      }
      unawaited(sync());
    });
  }

  void _stopAutomaticSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    _remoteSyncTimer?.cancel();
    _remoteSyncTimer = null;
  }

  void _statusForIdleAuthState() {
    if (remote.currentUserId == null) {
      _status = SyncRunStatus.notLoggedIn;
      return;
    }
    if (pendingCount > 0) {
      _status = SyncRunStatus.offlinePending;
      return;
    }
    _status = _lastSuccessfulSyncAt == null
        ? SyncRunStatus.idle
        : SyncRunStatus.synced;
  }

  bool _productNeedsSync(ProductRow row) {
    return row.syncStatus != RecordSyncStatus.synced.storageValue ||
        row.userId == null;
  }

  bool _logItemNeedsSync(LogItemRow row) {
    return row.syncStatus != RecordSyncStatus.synced.storageValue ||
        row.userId == null;
  }

  bool _canManageRow(String? rowUserId, String? currentUserId) {
    if (currentUserId == null) {
      return rowUserId == null;
    }
    return rowUserId == null || rowUserId == currentUserId;
  }

  bool _canPush(String? rowUserId, String currentUserId) {
    return rowUserId == null || rowUserId == currentUserId;
  }

  bool _sameOrUnownedUser(String? rowUserId, String currentUserId) {
    return rowUserId == null || rowUserId == currentUserId;
  }

  String _describeSyncError(Object error) {
    if (error is PostgrestException) {
      final details = error.details == null ? '' : ' ${error.details}';
      final hint = error.hint == null ? '' : ' Hint: ${error.hint}';
      return 'Supabase rejected the sync: ${error.message}.$details$hint';
    }
    if (error is AuthException) {
      return 'Authentication failed: ${error.message}';
    }
    if (error is SocketException) {
      return 'Network unavailable. Your local changes are still pending.';
    }
    if (error is TimeoutException) {
      return 'Sync timed out. Your local changes are still pending.';
    }
    if (error is FormatException) {
      return 'Remote data format was unexpected: ${error.message}';
    }
    return 'Sync failed. Your local changes are still pending. $error';
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

  void _notifyIfAlive() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
