import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/food_cost_calculator.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 7, 12);
  const calculator = FoodCostCalculator();

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

  test('product can be saved without price', () async {
    final (:store, :database) = await createMemoryStore();

    final product = await store.addProduct(
      name: 'Arroz',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 130,
      proteinPer100: 2.7,
      carbsPer100: 28,
      fatPer100: 0.3,
    );

    expect(product.packagePriceClp, isNull);
    expect(calculator.costPer100(product), isNull);
    final row = (await database.select(database.productRows).get()).single;
    expect(row.packagePriceClp, isNull);
  });

  test('g product cost per 100 and serving are calculated correctly', () async {
    final fixture = await createMemoryStore();

    final product = await fixture.store.addProduct(
      name: 'Avena',
      baseUnit: BaseUnit.grams,
      servingSize: 60,
      servingUnit: 'g',
      caloriesPer100: 380,
      proteinPer100: 13,
      carbsPer100: 62,
      fatPer100: 7,
      packagePriceClp: 3000,
      packageQuantity: 1000,
      packageQuantityUnit: 'g',
    );

    expect(product.packagePriceClp, 3000);
    expect(product.packageQuantity, 1000);
    expect(calculator.costPer100(product), closeTo(300, 0.001));
    expect(calculator.costPerServing(product), closeTo(180, 0.001));
  });

  test('ml products calculate cost correctly', () async {
    final fixture = await createMemoryStore();

    final product = await fixture.store.addProduct(
      name: 'Leche',
      baseUnit: BaseUnit.milliliters,
      servingSize: 200,
      servingUnit: 'ml',
      caloriesPer100: 42,
      proteinPer100: 3.4,
      carbsPer100: 5,
      fatPer100: 1,
      packagePriceClp: 1200,
      packageQuantity: 1000,
      packageQuantityUnit: 'ml',
    );

    expect(calculator.costPer100(product), closeTo(120, 0.001));
    expect(calculator.costPerServing(product), closeTo(240, 0.001));
  });

  test('logging food stores cost snapshots', () async {
    final fixture = await createMemoryStore();
    final product = await fixture.store.addProduct(
      name: 'Avena',
      baseUnit: BaseUnit.grams,
      servingSize: 60,
      servingUnit: 'g',
      caloriesPer100: 380,
      proteinPer100: 13,
      carbsPer100: 62,
      fatPer100: 7,
      packagePriceClp: 3000,
      packageQuantity: 1000,
      packageQuantityUnit: 'g',
    );

    final item = await fixture.store.addLogItem(
      product: product,
      quantity: 120,
      unit: 'g',
      mealType: MealType.breakfast,
    );

    expect(item.costSnapshotClp, closeTo(360, 0.001));
    expect(item.costPer100SnapshotClp, closeTo(300, 0.001));
    expect(item.costPerServingSnapshotClp, closeTo(180, 0.001));
    final row =
        (await fixture.database.select(fixture.database.logItemRows).get())
            .single;
    expect(row.costSnapshotClp, closeTo(360, 0.001));
  });

  test('old logs without cost still load and do not crash totals', () async {
    final fixture = await createMemoryStore();
    final product = await fixture.store.addProduct(
      name: 'Pan',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 250,
      proteinPer100: 8,
      carbsPer100: 45,
      fatPer100: 3,
    );

    await fixture.store.addLogItem(
      product: product,
      quantity: 100,
      unit: 'g',
      mealType: MealType.breakfast,
    );

    expect(fixture.store.logItems.single.costSnapshotClp, isNull);
    expect(fixture.store.dailyCostClp, isNull);
    expect(fixture.store.hasUnknownDailyCosts, isTrue);
  });

  test(
    'changing product price later does not change old log cost snapshot',
    () async {
      final fixture = await createMemoryStore();
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
      await fixture.store.updateProduct(product, packagePriceClp: 6000);

      expect(
        fixture.store.logItems.single.costSnapshotClp,
        closeTo(360, 0.001),
      );
      expect(fixture.store.products.single.packagePriceClp, 6000);
    },
  );

  test('meal and daily total cost sum known log cost snapshots only', () async {
    final fixture = await createMemoryStore();
    final priced = await fixture.store.addProduct(
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
    final unknown = await fixture.store.addProduct(
      name: 'Té',
      baseUnit: BaseUnit.milliliters,
      caloriesPer100: 1,
      proteinPer100: 0,
      carbsPer100: 0,
      fatPer100: 0,
    );

    await fixture.store.addLogItem(
      product: priced,
      quantity: 120,
      unit: 'g',
      mealType: MealType.breakfast,
    );
    await fixture.store.addLogItem(
      product: unknown,
      quantity: 200,
      unit: 'ml',
      mealType: MealType.breakfast,
    );

    expect(fixture.store.costForMeal(MealType.breakfast), closeTo(360, 0.001));
    expect(fixture.store.dailyCostClp, closeTo(360, 0.001));
    expect(fixture.store.hasUnknownCostsForMeal(MealType.breakfast), isTrue);
    expect(fixture.store.hasUnknownDailyCosts, isTrue);
  });

  test(
    'meal-based product ranking prefers recurrent products for that meal',
    () async {
      var tick = 0;
      final fixture = await createMemoryStore(
        clock: () => fixedNow.add(Duration(minutes: tick++)),
      );
      final pan = await fixture.store.addProduct(
        name: 'Pan',
        baseUnit: BaseUnit.grams,
        caloriesPer100: 250,
        proteinPer100: 8,
        carbsPer100: 45,
        fatPer100: 3,
      );
      final huevo = await fixture.store.addProduct(
        name: 'Huevo',
        baseUnit: BaseUnit.grams,
        caloriesPer100: 155,
        proteinPer100: 13,
        carbsPer100: 1.1,
        fatPer100: 11,
      );
      final arroz = await fixture.store.addProduct(
        name: 'Arroz',
        baseUnit: BaseUnit.grams,
        caloriesPer100: 130,
        proteinPer100: 2.7,
        carbsPer100: 28,
        fatPer100: 0.3,
      );

      await fixture.store.addLogItem(
        product: pan,
        quantity: 50,
        unit: 'g',
        mealType: MealType.breakfast,
      );
      await fixture.store.addLogItem(
        product: pan,
        quantity: 50,
        unit: 'g',
        mealType: MealType.breakfast,
      );
      await fixture.store.addLogItem(
        product: huevo,
        quantity: 50,
        unit: 'g',
        mealType: MealType.breakfast,
      );
      await fixture.store.addLogItem(
        product: arroz,
        quantity: 100,
        unit: 'g',
        mealType: MealType.dinner,
      );

      expect(
        fixture.store
            .rankedProductsForMeal(mealType: MealType.breakfast)
            .map((product) => product.name)
            .take(2),
        ['Pan', 'Huevo'],
      );
      expect(
        fixture.store
            .rankedProductsForMeal(mealType: MealType.dinner)
            .first
            .name,
        'Arroz',
      );
      expect(
        fixture.store
            .rankedProductsForMeal(mealType: MealType.breakfast, query: 'arr')
            .map((product) => product.name),
        ['Arroz'],
      );
    },
  );
}
