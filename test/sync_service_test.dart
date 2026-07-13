import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/core/sync/record_sync_status.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/ocr_reports/domain/ocr_image_saving_mode.dart';
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

  Future<void> addOcrReport(NutrivoGoStore store) {
    return store.addOcrScanReport(
      rawOcrText: 'INFORMACION NUTRICIONAL',
      parsedJson: const {'calories_per_100': 65},
      correctedJson: const {'calories_per_100': 66},
      detectedBasis: 'per_100g',
      parserWarnings: const ['warning'],
      platform: 'android',
      productName: 'OCR yogurt',
      wasParserCorrect: false,
      userFeedback: 'Calories corrected.',
      imagePathLocal: 'C:/temp/ocr-yogurt.jpg',
    );
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

  test('sync pushes Tarde meal type as afternoon', () async {
    final fixture = await createFixture();
    final product = await fixture.store.addProduct(
      name: 'Yogurt',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 100,
      proteinPer100: 10,
      carbsPer100: 5,
      fatPer100: 1,
    );
    await fixture.store.addLogItem(
      product: product,
      quantity: 150,
      unit: 'g',
      mealType: MealType.afternoon,
    );

    await fixture.syncService.sync();

    expect(fixture.remote.logItems.values.single['meal_type'], 'afternoon');
  });

  test('sync preserves consumed_on as a timezone-safe calendar date', () async {
    final fixture = await createFixture();
    final product = await fixture.store.addProduct(
      name: 'Yogurt',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 100,
      proteinPer100: 10,
      carbsPer100: 5,
      fatPer100: 1,
    );
    await fixture.store.addLogItem(
      product: product,
      quantity: 150,
      unit: 'g',
      mealType: MealType.afternoon,
      consumedOn: DateTime(2026, 6, 30, 23, 30),
    );

    await fixture.syncService.sync();

    expect(fixture.remote.logItems.values.single['consumed_on'], '2026-06-30');
  });

  test('sync pushes product cost fields and log cost snapshots', () async {
    final fixture = await createFixture();
    final product = await fixture.store.addProduct(
      name: 'Avena',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 380,
      proteinPer100: 13,
      carbsPer100: 62,
      fatPer100: 7,
      packagePriceClp: 3000,
      packageQuantity: 1000,
      packageQuantityUnit: 'g',
    );
    await fixture.store.addLogItem(
      product: product,
      quantity: 120,
      unit: 'g',
      mealType: MealType.breakfast,
    );

    await fixture.syncService.sync();

    final remoteProduct = fixture.remote.products.values.single;
    expect(remoteProduct['package_price_clp'], 3000);
    expect(remoteProduct['package_quantity'], 1000);
    expect(remoteProduct['package_quantity_unit'], 'g');
    final remoteLog = fixture.remote.logItems.values.single;
    expect(remoteLog['cost_snapshot_clp'], closeTo(360, 0.001));
    expect(remoteLog['cost_per_100_snapshot_clp'], closeTo(300, 0.001));
    expect(remoteLog['cost_per_serving_snapshot_clp'], isNull);
    expect(remoteLog['package_price_snapshot_clp'], 3000);
    expect(remoteLog['package_quantity_snapshot'], 1000);
  });

  test(
    'sync pushes and pulls optional physical unit fields and snapshots',
    () async {
      final fixture = await createFixture();
      final product = await fixture.store.addProduct(
        name: 'Yogur por unidades',
        baseUnit: BaseUnit.grams,
        servingSize: 100,
        servingUnit: 'g',
        unitsPerServing: 6,
        servingsPerPackage: 4.5,
        packagePriceClp: 2000,
        caloriesPer100: 200,
        proteinPer100: 8,
        carbsPer100: 20,
        fatPer100: 4,
      );
      await fixture.store.addLogItem(
        product: product,
        quantity: 3,
        unit: 'unit',
        mealType: MealType.snack,
      );

      await fixture.syncService.sync();

      final remoteProduct = fixture.remote.products.values.single;
      expect(remoteProduct['units_per_serving'], 6);
      expect(remoteProduct['servings_per_package'], 4.5);
      final remoteLog = fixture.remote.logItems.values.single;
      expect(remoteLog['unit'], 'unit');
      expect(remoteLog['base_quantity_snapshot'], closeTo(50, 0.0001));
      expect(remoteLog['units_per_serving_snapshot'], 6);

      final pullFixture = await createFixture();
      pullFixture.remote.products['remote-unit-product'] = _remoteProductRow(
        id: 'remote-unit-product',
        userId: 'user-1',
        name: 'Yogur remoto',
        updatedAt: fixedNow,
        servingSize: 100,
        servingUnit: 'g',
        unitsPerServing: 6,
        servingsPerPackage: 4.5,
      );
      pullFixture.remote.logItems['remote-unit-log'] = _remoteLogItemRow(
        id: 'remote-unit-log',
        userId: 'user-1',
        productId: 'remote-unit-product',
        mealType: 'snack',
        updatedAt: fixedNow,
        quantity: 3,
        unit: 'unit',
        baseQuantitySnapshot: 50,
        servingSizeSnapshot: 100,
        unitsPerServingSnapshot: 6,
        baseQuantityPerUnitSnapshot: 100 / 6,
      );

      await pullFixture.syncService.sync();

      expect(pullFixture.store.products.single.unitsPerServing, 6);
      expect(pullFixture.store.products.single.servingsPerPackage, 4.5);
      expect(pullFixture.store.logItems.single.unit, 'unit');
      expect(pullFixture.store.logItems.single.baseQuantitySnapshot, 50);
    },
  );

  test('sync pushes Gemini generic product source', () async {
    final fixture = await createFixture();
    await fixture.store.addProduct(
      name: 'Plátano Gemini',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 89,
      proteinPer100: 1.1,
      carbsPer100: 22.8,
      fatPer100: 0.3,
      source: 'gemini_generic',
    );

    await fixture.syncService.sync();

    expect(fixture.remote.products.values.single['source'], 'gemini_generic');
  });

  test('sync pulls Gemini label product source', () async {
    final fixture = await createFixture();
    fixture.remote.products['remote-gemini-label'] = _remoteProductRow(
      id: 'remote-gemini-label',
      userId: 'user-1',
      name: 'Yogur Gemini',
      updatedAt: fixedNow,
      source: 'gemini_label',
    );

    await fixture.syncService.sync();

    expect(fixture.store.products.single.source, 'gemini_label');
  });

  test('prevents duplicate OCR report rows when syncing repeatedly', () async {
    final fixture = await createFixture();
    await addOcrReport(fixture.store);
    await fixture.syncService.refreshPendingCount();

    await fixture.syncService.sync();
    await fixture.syncService.sync();

    expect(fixture.remote.ocrScanReports, hasLength(1));
    expect(fixture.remote.ocrReportUpsertCount, 1);
    expect(fixture.syncService.pendingOcrReportCount, 0);
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

  test('OCR report remains pending when sync fails', () async {
    final fixture = await createFixture();
    await addOcrReport(fixture.store);
    fixture.remote.failUpserts = true;

    await fixture.syncService.sync();

    final rows = await fixture.database
        .select(fixture.database.ocrScanReportRows)
        .get();
    expect(rows.single.syncStatus, RecordSyncStatus.pending.storageValue);
    expect(fixture.syncService.pendingOcrReportCount, 1);
    expect(fixture.syncService.status, SyncRunStatus.failed);
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

  test('pulls remote OCR reports', () async {
    final fixture = await createFixture();
    fixture.remote.ocrScanReports['remote-ocr-1'] = _remoteOcrReportRow(
      id: 'remote-ocr-1',
      userId: 'user-1',
      updatedAt: fixedNow,
    );

    await fixture.syncService.sync();

    expect(fixture.store.ocrScanReports, hasLength(1));
    expect(fixture.store.ocrScanReports.single.rawOcrText, contains('OCR'));
    expect(fixture.syncService.pendingOcrReportCount, 0);
  });

  test('pulls remote Tarde log item as afternoon meal type', () async {
    final fixture = await createFixture();
    fixture.remote.products['remote-product-afternoon'] = _remoteProductRow(
      id: 'remote-product-afternoon',
      userId: 'user-1',
      name: 'Remote yogurt',
      updatedAt: fixedNow,
    );
    fixture.remote.logItems['remote-log-afternoon'] = _remoteLogItemRow(
      id: 'remote-log-afternoon',
      userId: 'user-1',
      productId: 'remote-product-afternoon',
      mealType: 'afternoon',
      updatedAt: fixedNow,
    );

    await fixture.syncService.sync();

    final afternoonItems = fixture.store.itemsForMeal(MealType.afternoon);
    expect(afternoonItems, hasLength(1));
    expect(afternoonItems.single.mealType.label, 'Tarde');
  });

  test('pulls remote product and log cost fields', () async {
    final fixture = await createFixture();
    fixture.remote.products['remote-cost-product'] = _remoteProductRow(
      id: 'remote-cost-product',
      userId: 'user-1',
      name: 'Remote oats',
      updatedAt: fixedNow,
      packagePriceClp: 3000,
      packageQuantity: 1000,
      packageQuantityUnit: 'g',
    );
    fixture.remote.logItems['remote-cost-log'] = _remoteLogItemRow(
      id: 'remote-cost-log',
      userId: 'user-1',
      productId: 'remote-cost-product',
      mealType: 'breakfast',
      updatedAt: fixedNow,
      costSnapshotClp: 360,
      costPer100SnapshotClp: 300,
      packagePriceSnapshotClp: 3000,
      packageQuantitySnapshot: 1000,
    );

    await fixture.syncService.sync();

    expect(fixture.store.products.single.packagePriceClp, 3000);
    expect(fixture.store.products.single.packageQuantity, 1000);
    expect(fixture.store.logItems.single.costSnapshotClp, 360);
    expect(fixture.store.dailyCostClp, 360);
  });

  test('image upload failure does not block OCR report sync', () async {
    final fixture = await createFixture();
    await fixture.store.setOcrImageSavingMode(OcrImageSavingMode.always);
    await addOcrReport(fixture.store);
    fixture.remote.failImageUploads = true;

    await fixture.syncService.sync();

    expect(fixture.remote.ocrScanReports, hasLength(1));
    final remoteRow = fixture.remote.ocrScanReports.values.single;
    expect(remoteRow['image_saved'], isFalse);
    expect(remoteRow['image_storage_path'], isNull);
    expect(fixture.syncService.status, SyncRunStatus.synced);
    expect(fixture.syncService.pendingOcrReportCount, 0);
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

  test('Supabase migration has RLS and storage policies for OCR reports', () {
    final migration = File(
      'supabase/migrations/003_create_ocr_scan_reports.sql',
    ).readAsStringSync();

    expect(
      migration,
      contains('alter table public.ocr_scan_reports enable row level security'),
    );
    expect(migration, contains('Users can read their OCR scan reports'));
    expect(migration, contains('Users can insert their OCR scan reports'));
    expect(migration, contains('Users can update their OCR scan reports'));
    expect(migration, contains('Users can delete their OCR scan reports'));
    expect(migration, contains('ocr-debug-images'));
    expect(migration, contains('Users can read their OCR debug images'));
    expect(migration, contains('Users can upload their OCR debug images'));
  });

  test('Supabase migration allows afternoon meal type', () {
    final migration = File(
      'supabase/migrations/005_allow_afternoon_meal_type.sql',
    ).readAsStringSync();

    expect(
      migration,
      contains('drop constraint if exists log_items_meal_type_check'),
    );
    expect(migration, contains("'afternoon'"));
    expect(
      migration,
      contains(
        "meal_type in ('breakfast', 'lunch', 'afternoon', 'dinner', 'snack')",
      ),
    );
  });

  test('Supabase migration adds food cost fields', () {
    final migration = File(
      'supabase/migrations/006_add_food_cost_fields.sql',
    ).readAsStringSync();

    expect(migration, contains('package_price_clp'));
    expect(migration, contains('package_quantity'));
    expect(migration, contains('cost_snapshot_clp'));
    expect(migration, contains('cost_per_100_snapshot_clp'));
    expect(migration, contains('grant select, insert, update, delete'));
    expect(migration, contains('public.products, public.log_items'));
  });

  test('Supabase migration adds optional physical unit fields', () {
    final migration = File(
      'supabase/migrations/007_add_product_physical_units.sql',
    ).readAsStringSync();
    expect(migration, contains('units_per_serving'));
    expect(migration, contains('servings_per_package'));
    expect(migration, contains('base_quantity_snapshot'));
    expect(migration, contains('units_per_serving_snapshot'));
    expect(migration, contains('grant select, insert, update, delete'));
  });

  test('Supabase migration adds a date-only consumed_on field and index', () {
    final migration = File(
      'supabase/migrations/008_add_log_consumed_on.sql',
    ).readAsStringSync();
    expect(migration, contains('consumed_on date'));
    expect(migration, contains('alter column consumed_on set not null'));
    expect(migration, contains('log_items_user_consumed_on_idx'));
  });
}

Map<String, dynamic> _remoteProductRow({
  required String id,
  required String userId,
  required String name,
  required DateTime updatedAt,
  double? packagePriceClp,
  double? packageQuantity,
  String? packageQuantityUnit,
  String? source,
  double? servingSize,
  String? servingUnit,
  double? unitsPerServing,
  double? servingsPerPackage,
}) {
  return {
    'id': id,
    'user_id': userId,
    'name': name,
    'brand': null,
    'serving_size': servingSize,
    'serving_unit': servingUnit,
    'base_unit': 'g',
    'calories_per_100': 52,
    'protein_per_100': 0.3,
    'carbs_per_100': 14,
    'fat_per_100': 0.2,
    'created_at': updatedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': null,
    'barcode': null,
    'source': source,
    'sugar_per_100': null,
    'saturated_fat_per_100': null,
    'sodium_per_100': null,
    'fiber_per_100': null,
    'package_price_clp': packagePriceClp,
    'package_quantity': packageQuantity,
    'package_quantity_unit': packageQuantityUnit,
    'units_per_serving': unitsPerServing,
    'servings_per_package': servingsPerPackage,
  };
}

Map<String, dynamic> _remoteLogItemRow({
  required String id,
  required String userId,
  required String productId,
  required String mealType,
  required DateTime updatedAt,
  double? costSnapshotClp,
  double? costPer100SnapshotClp,
  double? costPerServingSnapshotClp,
  double? packagePriceSnapshotClp,
  double? packageQuantitySnapshot,
  double quantity = 100,
  String unit = 'g',
  double? baseQuantitySnapshot,
  double? servingSizeSnapshot,
  double? unitsPerServingSnapshot,
  double? baseQuantityPerUnitSnapshot,
  String? consumedOn,
}) {
  return {
    'id': id,
    'user_id': userId,
    'product_id': productId,
    'meal_type': mealType,
    'quantity': quantity,
    'unit': unit,
    'calories': 52,
    'protein': 0.3,
    'carbs': 14,
    'fat': 0.2,
    'created_at': updatedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'consumed_on': consumedOn,
    'deleted_at': null,
    'cost_snapshot_clp': costSnapshotClp,
    'cost_per_100_snapshot_clp': costPer100SnapshotClp,
    'cost_per_serving_snapshot_clp': costPerServingSnapshotClp,
    'package_price_snapshot_clp': packagePriceSnapshotClp,
    'package_quantity_snapshot': packageQuantitySnapshot,
    'base_quantity_snapshot': baseQuantitySnapshot,
    'serving_size_snapshot': servingSizeSnapshot,
    'units_per_serving_snapshot': unitsPerServingSnapshot,
    'base_quantity_per_unit_snapshot': baseQuantityPerUnitSnapshot,
  };
}

Map<String, dynamic> _remoteOcrReportRow({
  required String id,
  required String userId,
  required DateTime updatedAt,
}) {
  return {
    'id': id,
    'user_id': userId,
    'raw_ocr_text': 'REMOTE OCR TEXT',
    'parsed_json': {'calories_per_100': 65},
    'corrected_json': {'calories_per_100': 66},
    'detected_basis': 'per_100g',
    'parser_warnings': ['warning'],
    'parser_confidence': null,
    'was_parser_correct': false,
    'user_feedback': 'Remote correction.',
    'product_id': null,
    'product_name': 'Remote OCR yogurt',
    'barcode': null,
    'source': 'ocr',
    'platform': 'android',
    'app_version': '1.0.0+1',
    'image_saved': false,
    'image_storage_path': null,
    'image_crop_storage_path': null,
    'image_path_local': null,
    'created_at': updatedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': null,
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
  bool failImageUploads = false;
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
    if (failImageUploads) {
      throw const SocketException('image upload offline');
    }
    return OcrReportImageUploadResult(
      storagePath: '$userId/$reportId/original.jpg',
    );
  }
}
