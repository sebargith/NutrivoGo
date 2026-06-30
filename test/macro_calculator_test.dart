import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/macro_calculator.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/products/domain/product.dart';
import 'package:path/path.dart' as p;

void main() {
  const calculator = MacroCalculator();
  final fixedNow = DateTime(2026, 6, 30, 12);

  Product yogurt() {
    return Product(
      id: 'greek-yogurt',
      name: 'Greek Yogurt',
      brand: 'Plain',
      servingSize: 170,
      servingUnit: 'g',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 59,
      proteinPer100: 10,
      carbsPer100: 3.6,
      fatPer100: 0.4,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  Future<({AppDatabase database, NutrivoGoStore store})> createMemoryStore({
    DateTime Function()? clock,
  }) async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(
      database: database,
      clock: clock ?? () => fixedNow,
    );
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  test('calculates macros from grams', () {
    final snapshot = calculator.calculateFromProduct(
      product: yogurt(),
      quantity: 250,
      unit: 'g',
    );

    expect(snapshot.calories, closeTo(147.5, 0.001));
    expect(snapshot.protein, closeTo(25, 0.001));
    expect(snapshot.carbs, closeTo(9, 0.001));
    expect(snapshot.fat, closeTo(1, 0.001));
  });

  test('calculates macros from servings', () {
    final snapshot = calculator.calculateFromProduct(
      product: yogurt(),
      quantity: 2,
      unit: 'serving',
    );

    expect(snapshot.calories, closeTo(200.6, 0.001));
    expect(snapshot.protein, closeTo(34, 0.001));
    expect(snapshot.carbs, closeTo(12.24, 0.001));
    expect(snapshot.fat, closeTo(1.36, 0.001));
  });

  test('saves a product', () async {
    final (:store, :database) = await createMemoryStore();

    final product = await store.addProduct(
      name: 'Rice',
      brand: 'Kitchen',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 130,
      proteinPer100: 2.7,
      carbsPer100: 28,
      fatPer100: 0.3,
    );

    expect(store.products, hasLength(1));
    expect(store.products.single.id, product.id);
    expect(store.products.single.brand, 'Kitchen');

    final rows = await database.select(database.productRows).get();
    expect(rows, hasLength(1));
    expect(rows.single.name, 'Rice');
  });

  test('loads products after app restart', () async {
    final tempDir = await Directory.systemTemp.createTemp('nutrivogo_test_');
    addTearDown(() => tempDir.delete(recursive: true));
    final dbFile = File(p.join(tempDir.path, 'restart.sqlite'));

    final firstDatabase = AppDatabase.connect(NativeDatabase(dbFile));
    final firstStore = NutrivoGoStore(
      database: firstDatabase,
      clock: () => fixedNow,
    );
    await firstStore.ready;
    await firstStore.addProduct(
      name: 'Milk',
      baseUnit: BaseUnit.milliliters,
      caloriesPer100: 42,
      proteinPer100: 3.4,
      carbsPer100: 5,
      fatPer100: 1,
    );
    await firstDatabase.close();

    final secondDatabase = AppDatabase.connect(NativeDatabase(dbFile));
    addTearDown(secondDatabase.close);
    final secondStore = NutrivoGoStore(
      database: secondDatabase,
      clock: () => fixedNow,
    );
    await secondStore.ready;

    expect(secondStore.products, hasLength(1));
    expect(secondStore.products.single.name, 'Milk');
    expect(secondStore.products.single.baseUnit, BaseUnit.milliliters);
  });

  test('saves a log item', () async {
    final fixture = await createMemoryStore();
    final store = fixture.store;
    final product = await store.addProduct(
      name: 'Rice',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 130,
      proteinPer100: 2.7,
      carbsPer100: 28,
      fatPer100: 0.3,
    );

    final item = await store.addLogItem(
      product: product,
      quantity: 100,
      unit: 'g',
      mealType: MealType.lunch,
    );

    expect(store.logItems, hasLength(1));
    expect(store.logItems.single.id, item.id);
    expect(store.logItems.single.macros.calories, closeTo(130, 0.001));
  });

  test('aggregates daily totals from logged macro snapshots', () async {
    final fixture = await createMemoryStore();
    final store = fixture.store;
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
      quantity: 100,
      unit: 'g',
      mealType: MealType.lunch,
    );
    await store.addLogItem(
      product: product,
      quantity: 50,
      unit: 'g',
      mealType: MealType.dinner,
    );

    expect(store.dailyTotals.calories, closeTo(195, 0.001));
    expect(store.dailyTotals.protein, closeTo(4.05, 0.001));
    expect(store.dailyTotals.carbs, closeTo(42, 0.001));
    expect(store.dailyTotals.fat, closeTo(0.45, 0.001));
  });

  test('product edit does not change old log item macro snapshots', () async {
    final fixture = await createMemoryStore();
    final store = fixture.store;
    final product = await store.addProduct(
      name: 'Yogurt',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 100,
      proteinPer100: 10,
      carbsPer100: 5,
      fatPer100: 1,
    );

    await store.addLogItem(
      product: product,
      quantity: 200,
      unit: 'g',
      mealType: MealType.breakfast,
    );
    await store.updateProduct(product, caloriesPer100: 250, proteinPer100: 20);

    expect(store.products.single.caloriesPer100, 250);
    expect(store.logItems.single.macros.calories, closeTo(200, 0.001));
    expect(store.logItems.single.macros.protein, closeTo(20, 0.001));
  });

  test('recent products are based on logged items', () async {
    var tick = 0;
    final fixture = await createMemoryStore(
      clock: () => fixedNow.add(Duration(minutes: tick++)),
    );
    final store = fixture.store;
    final rice = await store.addProduct(
      name: 'Rice',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 130,
      proteinPer100: 2.7,
      carbsPer100: 28,
      fatPer100: 0.3,
    );
    final milk = await store.addProduct(
      name: 'Milk',
      baseUnit: BaseUnit.milliliters,
      caloriesPer100: 42,
      proteinPer100: 3.4,
      carbsPer100: 5,
      fatPer100: 1,
    );

    await store.addLogItem(
      product: rice,
      quantity: 100,
      unit: 'g',
      mealType: MealType.lunch,
    );
    await store.addLogItem(
      product: milk,
      quantity: 250,
      unit: 'ml',
      mealType: MealType.snack,
    );

    expect(store.recentProducts.map((product) => product.name), [
      'Milk',
      'Rice',
    ]);
  });

  test(
    'soft-deleted products are hidden but logged snapshots remain',
    () async {
      final fixture = await createMemoryStore();
      final store = fixture.store;
      final product = await store.addProduct(
        name: 'Toast',
        baseUnit: BaseUnit.grams,
        caloriesPer100: 250,
        proteinPer100: 8,
        carbsPer100: 45,
        fatPer100: 4,
      );
      await store.addLogItem(
        product: product,
        quantity: 50,
        unit: 'g',
        mealType: MealType.breakfast,
      );

      await store.deleteProduct(product.id);

      expect(store.products, isEmpty);
      expect(store.logItems.single.product.name, 'Toast');
      expect(store.logItems.single.macros.calories, closeTo(125, 0.001));
    },
  );
}
