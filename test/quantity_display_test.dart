import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/features/food_log/presentation/quantity_display.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  final product = Product(
    id: 'product-1',
    name: 'Yogurt',
    servingSize: 125,
    servingUnit: 'g',
    baseUnit: BaseUnit.grams,
    caloriesPer100: 80,
    proteinPer100: 4,
    carbsPer100: 12,
    fatPer100: 1.5,
    createdAt: DateTime.utc(2026, 7),
    updatedAt: DateTime.utc(2026, 7),
  );

  test('formats quantity unit labels clearly', () {
    expect(quantityUnitLabel('g'), 'gramos (g)');
    expect(quantityUnitLabel('ml'), 'mililitros (ml)');
    expect(quantityUnitLabel('serving'), 'porción(es)');
  });

  test('formats quantity helper text by selected unit', () {
    expect(quantityHelperText('g'), 'Ingresa los gramos que comiste.');
    expect(quantityHelperText('ml'), 'Ingresa los mililitros que consumiste.');
    expect(quantityHelperText('serving'), 'Ingresa cuántas porciones comiste.');
  });

  test('formats serving size display without ambiguous text', () {
    expect(servingSizeDisplay(product), '1 porción = 125 g');
  });
}
