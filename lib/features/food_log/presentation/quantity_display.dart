import '../../../shared/utils/macro_formatters.dart';
import '../../products/domain/product.dart';

String quantityUnitLabel(String unit) {
  return switch (unit) {
    'g' => 'grams (g)',
    'ml' => 'milliliters (ml)',
    'serving' => 'serving(s)',
    _ => unit,
  };
}

String quantityHelperText(String unit) {
  return switch (unit) {
    'g' => 'Enter the grams you ate.',
    'ml' => 'Enter the milliliters you consumed.',
    'serving' => 'Enter how many servings you ate.',
    _ => 'Enter the amount you ate.',
  };
}

String? servingSizeDisplay(Product product) {
  final size = product.servingSize;
  final unit = product.servingUnit;
  if (size == null || unit == null || unit.trim().isEmpty) {
    return null;
  }
  return '1 serving = ${formatQuantity(size)} $unit';
}
