import '../../products/domain/product.dart';
import 'macro_snapshot.dart';

class MacroCalculator {
  const MacroCalculator();

  MacroSnapshot calculateFromProduct({
    required Product product,
    required double quantity,
    required String unit,
  }) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be greater than 0');
    }

    final baseQuantity = quantityInBaseUnit(
      product: product,
      quantity: quantity,
      unit: unit,
    );

    return MacroSnapshot(
      calories: product.caloriesPer100 * baseQuantity / 100,
      protein: product.proteinPer100 * baseQuantity / 100,
      carbs: product.carbsPer100 * baseQuantity / 100,
      fat: product.fatPer100 * baseQuantity / 100,
    );
  }

  double quantityInBaseUnit({
    required Product product,
    required double quantity,
    required String unit,
  }) {
    final normalizedUnit = unit.trim().toLowerCase();
    if (normalizedUnit == product.baseUnit.label) {
      return quantity;
    }

    if (normalizedUnit == 'serving' || normalizedUnit == 'servings') {
      final servingSize = product.servingSize;
      if (servingSize == null || servingSize <= 0) {
        throw ArgumentError('Product needs a serving size to log servings.');
      }
      return quantity * servingSize;
    }

    if (normalizedUnit == 'unit' ||
        normalizedUnit == 'units' ||
        normalizedUnit == 'unidad' ||
        normalizedUnit == 'unidades') {
      final baseQuantityPerUnit = product.baseQuantityPerUnit;
      if (baseQuantityPerUnit == null || baseQuantityPerUnit <= 0) {
        throw ArgumentError(
          'Product needs a serving size and units per serving to log units.',
        );
      }
      return quantity * baseQuantityPerUnit;
    }

    throw ArgumentError.value(unit, 'unit', 'Unsupported unit for product.');
  }
}
