import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 6, 12);

  Future<({AppDatabase database, NutrivoGoStore store})>
  createMemoryStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database, clock: () => fixedNow);
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  test('MealType labels are Spanish Chilean labels', () {
    expect(MealType.breakfast.label, 'Desayuno');
    expect(MealType.lunch.label, 'Almuerzo');
    expect(MealType.afternoon.label, 'Tarde');
    expect(MealType.dinner.label, 'Cena');
    expect(MealType.snack.label, 'Snack');
  });

  test('MealType order is Desayuno Almuerzo Tarde Cena Snack', () {
    expect(MealType.values.map((meal) => meal.label), [
      'Desayuno',
      'Almuerzo',
      'Tarde',
      'Cena',
      'Snack',
    ]);
  });

  test('existing stored meal values deserialize correctly', () {
    expect(MealType.fromStorage('breakfast'), MealType.breakfast);
    expect(MealType.fromStorage('lunch'), MealType.lunch);
    expect(MealType.fromStorage('dinner'), MealType.dinner);
    expect(MealType.fromStorage('snack'), MealType.snack);
  });

  test('afternoon serializes and deserializes correctly', () {
    expect(MealType.afternoon.storageValue, 'afternoon');
    expect(MealType.fromStorage('afternoon'), MealType.afternoon);
  });

  test('unknown stored meal values do not crash loading', () {
    expect(MealType.fromStorage('late-night'), MealType.snack);
  });

  test('adding a log item to Tarde works and counts in daily totals', () async {
    final fixture = await createMemoryStore();
    final product = await fixture.store.addProduct(
      name: 'Yogurt',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 100,
      proteinPer100: 10,
      carbsPer100: 5,
      fatPer100: 1,
    );

    final item = await fixture.store.addLogItem(
      product: product,
      quantity: 150,
      unit: 'g',
      mealType: MealType.afternoon,
    );

    expect(item.mealType, MealType.afternoon);
    expect(fixture.store.itemsForMeal(MealType.afternoon), hasLength(1));
    expect(fixture.store.dailyTotals.calories, closeTo(150, 0.001));
    final rows = await fixture.database
        .select(fixture.database.logItemRows)
        .get();
    expect(rows.single.mealType, 'afternoon');
  });

  test(
    'existing breakfast lunch dinner snack rows load with Spanish labels',
    () async {
      final fixture = await createMemoryStore();
      final product = await fixture.store.addProduct(
        name: 'Rice',
        baseUnit: BaseUnit.grams,
        caloriesPer100: 130,
        proteinPer100: 2.7,
        carbsPer100: 28,
        fatPer100: 0.3,
      );

      for (final mealType in [
        MealType.breakfast,
        MealType.lunch,
        MealType.dinner,
        MealType.snack,
      ]) {
        await fixture.database
            .into(fixture.database.logItemRows)
            .insert(
              LogItemRowsCompanion(
                id: Value('log-${mealType.storageValue}'),
                productId: Value(product.id),
                mealType: Value(mealType.storageValue),
                quantity: const Value(100),
                unit: const Value('g'),
                calories: const Value(130),
                protein: const Value(2.7),
                carbs: const Value(28),
                fat: const Value(0.3),
                createdAt: Value(fixedNow),
                updatedAt: Value(fixedNow),
              ),
            );
      }

      await fixture.store.load();

      expect(fixture.store.logItems.map((item) => item.mealType.label), [
        'Desayuno',
        'Almuerzo',
        'Cena',
        'Snack',
      ]);
    },
  );
}
