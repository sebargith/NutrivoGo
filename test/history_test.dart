import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/products/domain/product.dart';
import 'package:nutrivogo/shared/utils/calendar_date.dart';

void main() {
  final now = DateTime.utc(2026, 7, 13, 15);

  Future<({AppDatabase database, NutrivoGoStore store})> createStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database, clock: () => now);
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  Future<Product> addProduct(NutrivoGoStore store, {double? packagePriceClp}) {
    return store.addProduct(
      name: 'Avena',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 400,
      proteinPer100: 10,
      carbsPer100: 60,
      fatPer100: 8,
      packagePriceClp: packagePriceClp,
      packageQuantity: packagePriceClp == null ? null : 1000,
      packageQuantityUnit: packagePriceClp == null ? null : 'g',
    );
  }

  test(
    'new logs default to today and past dates persist as calendar dates',
    () async {
      final fixture = await createStore();
      final product = await addProduct(fixture.store);
      final past = DateTime(2026, 7, 10, 23, 30);

      await fixture.store.addLogItem(
        product: product,
        quantity: 100,
        unit: 'g',
        mealType: MealType.breakfast,
      );
      await fixture.store.addLogItem(
        product: product,
        quantity: 50,
        unit: 'g',
        mealType: MealType.afternoon,
        consumedOn: past,
      );

      expect(fixture.store.todaysLogItems, hasLength(1));
      expect(
        fixture.store.logItemsForDate(DateTime.utc(2026, 7, 10)),
        hasLength(1),
      );
      final rows = await fixture.database
          .select(fixture.database.logItemRows)
          .get();
      expect(
        rows.map((row) => row.consumedOn),
        contains(DateTime(2026, 7, 10)),
      );
      expect(
        rows.map((row) => row.consumedOn),
        contains(DateTime(2026, 7, 13)),
      );
    },
  );

  test('calendar date serialization does not shift across time zones', () {
    final localLateNight = DateTime(2026, 7, 10, 23, 45);
    final stored = calendarDateToStorage(localLateNight);

    expect(stored, '2026-07-10');
    expect(
      calendarDateFromStorage(stored, fallback: DateTime.utc(2000)),
      DateTime(2026, 7, 10),
    );
  });

  test(
    'daily weekly and monthly summaries use macro and cost snapshots',
    () async {
      final fixture = await createStore();
      final priced = await addProduct(fixture.store, packagePriceClp: 2000);
      final unknown = await addProduct(fixture.store);
      final july10 = DateTime.utc(2026, 7, 10);
      final july13 = DateTime.utc(2026, 7, 13);

      await fixture.store.addLogItem(
        product: priced,
        quantity: 100,
        unit: 'g',
        mealType: MealType.breakfast,
        consumedOn: july10,
      );
      await fixture.store.addLogItem(
        product: unknown,
        quantity: 50,
        unit: 'g',
        mealType: MealType.afternoon,
        consumedOn: july10,
      );
      await fixture.store.addLogItem(
        product: priced,
        quantity: 50,
        unit: 'g',
        mealType: MealType.dinner,
        consumedOn: july13,
      );

      final daily = fixture.store.summaryForDate(july10);
      expect(daily.totalMacros.calories, 600);
      expect(daily.knownCostTotalClp, 200);
      expect(daily.foodsWithoutPrice, 1);

      final weekly = fixture.store.summaryForRange(
        DateTime.utc(2026, 7, 6),
        DateTime.utc(2026, 7, 13),
      );
      expect(weekly.recordedDayCount, 1);
      expect(weekly.totalMacros.calories, 600);

      final monthly = fixture.store.summaryForRange(
        DateTime.utc(2026, 7),
        DateTime.utc(2026, 8),
      );
      expect(monthly.recordedDayCount, 2);
      expect(monthly.totalMacros.calories, 800);
      expect(monthly.knownCostTotalClp, 300);
      expect(monthly.averageKnownCostClp, 150);
      expect(monthly.foodsWithoutPrice, 1);
    },
  );

  test('deleted logs are excluded from history and daily totals', () async {
    final fixture = await createStore();
    final product = await addProduct(fixture.store, packagePriceClp: 1000);
    final item = await fixture.store.addLogItem(
      product: product,
      quantity: 100,
      unit: 'g',
      mealType: MealType.snack,
    );

    await fixture.store.removeLogItem(item.id);

    expect(fixture.store.logItemsForDate(now), isEmpty);
    expect(fixture.store.summaryForDate(now).recordedDayCount, 0);
  });

  test(
    'history keeps logged macro and cost snapshots after product edits',
    () async {
      final fixture = await createStore();
      final product = await addProduct(fixture.store, packagePriceClp: 1000);
      await fixture.store.addLogItem(
        product: product,
        quantity: 100,
        unit: 'g',
        mealType: MealType.lunch,
        consumedOn: DateTime.utc(2026, 7, 8),
      );

      await fixture.store.updateProduct(
        product,
        caloriesPer100: 1,
        packagePriceClp: 9000,
      );
      final history = fixture.store.summaryForDate(DateTime.utc(2026, 7, 8));

      expect(history.totalMacros.calories, 400);
      expect(history.knownCostTotalClp, 100);
    },
  );

  test('history meal grouping retains the established meal order', () async {
    final fixture = await createStore();
    final product = await addProduct(fixture.store);
    for (final meal in MealType.values) {
      await fixture.store.addLogItem(
        product: product,
        quantity: 10,
        unit: 'g',
        mealType: meal,
      );
    }

    expect(MealType.values.map((meal) => meal.label), [
      'Desayuno',
      'Almuerzo',
      'Tarde',
      'Cena',
      'Snack',
    ]);
    for (final meal in MealType.values) {
      expect(fixture.store.itemsForMeal(meal), hasLength(1));
    }
  });
}
