import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/core/sync/record_sync_status.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/products/domain/product.dart';
import 'package:nutrivogo/features/sync/application/sync_remote_data_source.dart';
import 'package:nutrivogo/features/sync/application/sync_service.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 1, 12);

  Future<_Fixture> createFixture({
    String? userId = 'user-1',
    Duration autoSyncDebounce = const Duration(seconds: 2),
    bool autoSyncEnabled = false,
    Duration remoteSyncInterval = const Duration(seconds: 30),
  }) async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database, clock: () => fixedNow);
    await store.ready;
    final remote = _FakeSyncRemoteDataSource(
      currentUserId: userId,
      currentUserEmail: userId == null ? null : '$userId@example.com',
    );
    final syncService = SyncService(
      remote: remote,
      database: database,
      store: store,
      clock: () => fixedNow,
      autoSyncDebounce: autoSyncDebounce,
      autoSyncEnabled: autoSyncEnabled,
      remoteSyncInterval: remoteSyncInterval,
    );
    await syncService.handleAuthChanged();

    addTearDown(() async {
      syncService.dispose();
      await syncService.waitForIdle();
      await database.close();
    });
    return _Fixture(
      database: database,
      store: store,
      remote: remote,
      syncService: syncService,
    );
  }

  Future<Product> addProductAndLog(NutrivoGoStore store) async {
    final product = await store.addProduct(
      name: 'Rice',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 130,
      proteinPer100: 2.7,
      carbsPer100: 28,
      fatPer100: 0.3,
    );
    await store.addLogItem(
      product: product,
      quantity: 150,
      unit: 'g',
      mealType: MealType.lunch,
    );
    return product;
  }

  test('prevents duplicate remote rows when syncing repeatedly', () async {
    final fixture = await createFixture();
    await addProductAndLog(fixture.store);
    await fixture.syncService.refreshPendingCount();

    await fixture.syncService.sync();
    await fixture.syncService.sync();

    expect(fixture.remote.products, hasLength(1));
    expect(fixture.remote.logItems, hasLength(1));
    expect(fixture.remote.productUpsertCount, 1);
    expect(fixture.remote.logItemUpsertCount, 1);
    expect(fixture.syncService.status, SyncRunStatus.synced);
  });

  test('failed sync does not delete local data', () async {
    final fixture = await createFixture();
    await addProductAndLog(fixture.store);
    fixture.remote.failUpserts = true;

    await fixture.syncService.sync();

    final productRows = await fixture.database
        .select(fixture.database.productRows)
        .get();
    final logRows = await fixture.database
        .select(fixture.database.logItemRows)
        .get();
    expect(productRows, hasLength(1));
    expect(logRows, hasLength(1));
    expect(fixture.store.products, hasLength(1));
    expect(fixture.store.logItems, hasLength(1));
    expect(fixture.syncService.status, SyncRunStatus.failed);
  });

  test('product and log remain pending when sync fails', () async {
    final fixture = await createFixture();
    await addProductAndLog(fixture.store);
    fixture.remote.failUpserts = true;

    await fixture.syncService.sync();

    final productRows = await fixture.database
        .select(fixture.database.productRows)
        .get();
    final logRows = await fixture.database
        .select(fixture.database.logItemRows)
        .get();
    expect(
      productRows.single.syncStatus,
      RecordSyncStatus.pending.storageValue,
    );
    expect(logRows.single.syncStatus, RecordSyncStatus.pending.storageValue);
    expect(fixture.syncService.pendingProductCount, 1);
    expect(fixture.syncService.pendingLogItemCount, 1);
    expect(fixture.syncService.lastError, contains('pending'));
  });

  test('logout hides synced user data without deleting local rows', () async {
    final fixture = await createFixture();
    await addProductAndLog(fixture.store);
    await fixture.syncService.sync();

    fixture.remote.currentUserId = null;
    fixture.remote.currentUserEmail = null;
    await fixture.syncService.handleAuthChanged();

    final productRows = await fixture.database
        .select(fixture.database.productRows)
        .get();
    final logRows = await fixture.database
        .select(fixture.database.logItemRows)
        .get();
    expect(productRows, hasLength(1));
    expect(logRows, hasLength(1));
    expect(fixture.store.products, isEmpty);
    expect(fixture.store.logItems, isEmpty);
    expect(fixture.syncService.status, SyncRunStatus.notLoggedIn);
  });

  test('login as a different user does not show another user data', () async {
    final fixture = await createFixture();
    await addProductAndLog(fixture.store);
    await fixture.syncService.sync();

    fixture.remote.currentUserId = 'user-2';
    fixture.remote.currentUserEmail = 'user-2@example.com';
    await fixture.syncService.handleAuthChanged();

    expect(fixture.store.activeUserId, 'user-2');
    expect(fixture.store.products, isEmpty);
    expect(fixture.store.logItems, isEmpty);
  });

  test('sync state transitions from pending to syncing to synced', () async {
    final fixture = await createFixture();
    await fixture.store.addProduct(
      name: 'Milk',
      baseUnit: BaseUnit.milliliters,
      caloriesPer100: 42,
      proteinPer100: 3.4,
      carbsPer100: 5,
      fatPer100: 1,
    );
    await fixture.syncService.refreshPendingCount();

    expect(fixture.syncService.status, SyncRunStatus.offlinePending);

    final syncFuture = fixture.syncService.sync();
    expect(fixture.syncService.status, SyncRunStatus.syncing);
    await syncFuture;

    expect(fixture.syncService.status, SyncRunStatus.synced);
    expect(fixture.syncService.lastSuccessfulSyncAt, fixedNow);
    expect(fixture.syncService.pendingCount, 0);
  });

  test('auto-syncs product and log item after local changes', () async {
    final fixture = await createFixture(
      autoSyncDebounce: const Duration(milliseconds: 50),
      autoSyncEnabled: true,
    );

    await addProductAndLog(fixture.store);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(fixture.remote.products, hasLength(1));
    expect(fixture.remote.logItems, hasLength(1));
    expect(fixture.syncService.status, SyncRunStatus.synced);
    expect(fixture.syncService.pendingCount, 0);
  });

  test('auto-sync debounce combines fast local changes', () async {
    final fixture = await createFixture(
      autoSyncDebounce: const Duration(milliseconds: 80),
      autoSyncEnabled: true,
    );

    await fixture.store.addProduct(
      name: 'Milk',
      baseUnit: BaseUnit.milliliters,
      caloriesPer100: 42,
      proteinPer100: 3.4,
      carbsPer100: 5,
      fatPer100: 1,
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await fixture.store.addProduct(
      name: 'Bread',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 250,
      proteinPer100: 8,
      carbsPer100: 45,
      fatPer100: 3,
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(fixture.remote.fetchProductsCount, lessThanOrEqualTo(2));
    expect(fixture.remote.productUpsertCount, 2);
    expect(fixture.syncService.pendingProductCount, 0);
  });

  test('failed auto-sync keeps local records pending', () async {
    final fixture = await createFixture(
      autoSyncDebounce: const Duration(milliseconds: 50),
      autoSyncEnabled: true,
    );
    fixture.remote.failUpserts = true;

    await fixture.store.addProduct(
      name: 'Oats',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 389,
      proteinPer100: 16.9,
      carbsPer100: 66.3,
      fatPer100: 6.9,
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final productRows = await fixture.database
        .select(fixture.database.productRows)
        .get();
    expect(
      productRows.single.syncStatus,
      RecordSyncStatus.pending.storageValue,
    );
    expect(fixture.syncService.status, SyncRunStatus.failed);
    expect(fixture.syncService.pendingProductCount, 1);
  });

  test('remote polling pulls changes made on another device', () async {
    final fixture = await createFixture(
      autoSyncEnabled: true,
      remoteSyncInterval: const Duration(milliseconds: 50),
    );
    fixture.remote.products['remote-product-1'] = _remoteProductRow(
      id: 'remote-product-1',
      userId: 'user-1',
      name: 'Remote apple',
      updatedAt: fixedNow,
    );

    await Future<void>.delayed(const Duration(milliseconds: 150));
    fixture.syncService.dispose();
    await fixture.syncService.waitForIdle();

    expect(fixture.store.products, hasLength(1));
    expect(fixture.store.products.single.name, 'Remote apple');
    expect(fixture.syncService.status, SyncRunStatus.synced);
  });

  test('app resume pulls remote changes immediately', () async {
    final fixture = await createFixture(autoSyncEnabled: true);
    fixture.remote.products['remote-product-2'] = _remoteProductRow(
      id: 'remote-product-2',
      userId: 'user-1',
      name: 'Phone yogurt',
      updatedAt: fixedNow,
    );

    fixture.syncService.syncWhenAppResumes();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(fixture.store.products, hasLength(1));
    expect(fixture.store.products.single.name, 'Phone yogurt');
  });

  test('Supabase migration has RLS policies for products and log items', () {
    final migration = File(
      'supabase/migrations/001_create_products_and_log_items.sql',
    ).readAsStringSync();

    expect(
      migration,
      contains('alter table public.products enable row level security'),
    );
    expect(
      migration,
      contains('alter table public.log_items enable row level security'),
    );
    expect(migration, contains('Users can read their products'));
    expect(migration, contains('Users can insert their products'));
    expect(migration, contains('Users can update their products'));
    expect(migration, contains('Users can delete their products'));
    expect(migration, contains('Users can read their log items'));
    expect(migration, contains('Users can insert their log items'));
    expect(migration, contains('Users can update their log items'));
    expect(migration, contains('Users can delete their log items'));
  });
}

Map<String, dynamic> _remoteProductRow({
  required String id,
  required String userId,
  required String name,
  required DateTime updatedAt,
}) {
  return {
    'id': id,
    'user_id': userId,
    'name': name,
    'brand': null,
    'serving_size': null,
    'serving_unit': null,
    'base_unit': 'g',
    'calories_per_100': 52,
    'protein_per_100': 0.3,
    'carbs_per_100': 14,
    'fat_per_100': 0.2,
    'created_at': updatedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': null,
    'barcode': null,
    'source': null,
    'sugar_per_100': null,
    'saturated_fat_per_100': null,
    'sodium_per_100': null,
    'fiber_per_100': null,
  };
}

class _Fixture {
  const _Fixture({
    required this.database,
    required this.store,
    required this.remote,
    required this.syncService,
  });

  final AppDatabase database;
  final NutrivoGoStore store;
  final _FakeSyncRemoteDataSource remote;
  final SyncService syncService;
}

class _FakeSyncRemoteDataSource implements SyncRemoteDataSource {
  _FakeSyncRemoteDataSource({this.currentUserId, this.currentUserEmail});

  @override
  String? currentUserId;

  @override
  String? currentUserEmail;

  bool failUpserts = false;
  int fetchProductsCount = 0;
  int fetchLogItemsCount = 0;
  int fetchOcrReportsCount = 0;
  int productUpsertCount = 0;
  int logItemUpsertCount = 0;
  int ocrReportUpsertCount = 0;
  final products = <String, Map<String, dynamic>>{};
  final logItems = <String, Map<String, dynamic>>{};
  final ocrScanReports = <String, Map<String, dynamic>>{};

  @override
  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    fetchProductsCount += 1;
    return [
      for (final row in products.values)
        if (row['user_id'] == userId) Map<String, dynamic>.from(row),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLogItems(String userId) async {
    fetchLogItemsCount += 1;
    return [
      for (final row in logItems.values)
        if (row['user_id'] == userId) Map<String, dynamic>.from(row),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchOcrScanReports(String userId) async {
    fetchOcrReportsCount += 1;
    return [
      for (final row in ocrScanReports.values)
        if (row['user_id'] == userId) Map<String, dynamic>.from(row),
    ];
  }

  @override
  Future<void> upsertProduct(Map<String, dynamic> row) async {
    if (failUpserts) {
      throw const SocketException('offline');
    }
    productUpsertCount += 1;
    products[row['id'] as String] = Map<String, dynamic>.from(row);
  }

  @override
  Future<void> upsertLogItem(Map<String, dynamic> row) async {
    if (failUpserts) {
      throw const SocketException('offline');
    }
    logItemUpsertCount += 1;
    logItems[row['id'] as String] = Map<String, dynamic>.from(row);
  }

  @override
  Future<void> upsertOcrScanReport(Map<String, dynamic> row) async {
    if (failUpserts) {
      throw const SocketException('offline');
    }
    ocrReportUpsertCount += 1;
    ocrScanReports[row['id'] as String] = Map<String, dynamic>.from(row);
  }

  @override
  Future<OcrReportImageUploadResult?> uploadOcrReportImage({
    required String userId,
    required String reportId,
    required String imagePathLocal,
  }) async {
    return OcrReportImageUploadResult(
      storagePath: '$userId/$reportId/original.jpg',
    );
  }
}
