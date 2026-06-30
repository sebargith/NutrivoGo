import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/macro_calculator.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  const calculator = MacroCalculator();

  const yogurt = Product(
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
  );

  test('calculates macros from grams', () {
    final snapshot = calculator.calculateFromProduct(
      product: yogurt,
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
      product: yogurt,
      quantity: 2,
      unit: 'serving',
    );

    expect(snapshot.calories, closeTo(200.6, 0.001));
    expect(snapshot.protein, closeTo(34, 0.001));
    expect(snapshot.carbs, closeTo(12.24, 0.001));
    expect(snapshot.fat, closeTo(1.36, 0.001));
  });

  test('aggregates daily totals from logged macro snapshots', () {
    final store = NutrivoGoStore();
    final product = store.addProduct(
      name: 'Rice',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 130,
      proteinPer100: 2.7,
      carbsPer100: 28,
      fatPer100: 0.3,
    );

    store.addLogItem(
      product: product,
      quantity: 100,
      unit: 'g',
      mealType: MealType.lunch,
    );
    store.addLogItem(
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
}
