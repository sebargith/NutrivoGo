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

  Future<_Fixture> createFixture({String? userId = 'user-1'}) async {
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
    );
    await syncService.handleAuthChanged();

    addTearDown(syncService.dispose);
    addTearDown(database.close);
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
  int productUpsertCount = 0;
  int logItemUpsertCount = 0;
  final products = <String, Map<String, dynamic>>{};
  final logItems = <String, Map<String, dynamic>>{};

  @override
  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    return [
      for (final row in products.values)
        if (row['user_id'] == userId) Map<String, dynamic>.from(row),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLogItems(String userId) async {
    return [
      for (final row in logItems.values)
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
}
