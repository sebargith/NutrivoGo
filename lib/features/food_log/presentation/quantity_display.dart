import '../../../shared/utils/macro_formatters.dart';
import '../../products/domain/product.dart';

String quantityUnitLabel(String unit) {
  return switch (unit) {
    'g' => 'gramos (g)',
    'ml' => 'mililitros (ml)',
    'serving' => 'porción(es)',
    _ => unit,
  };
}

String quantityHelperText(String unit) {
  return switch (unit) {
    'g' => 'Ingresa los gramos que comiste.',
    'ml' => 'Ingresa los mililitros que consumiste.',
    'serving' => 'Ingresa cuántas porciones comiste.',
    _ => 'Ingresa la cantidad consumida.',
  };
}

String? servingSizeDisplay(Product product) {
  final size = product.servingSize;
  final unit = product.servingUnit;
  if (size == null || unit == null || unit.trim().isEmpty) {
    return null;
  }
  return '1 porción = ${formatQuantity(size)} $unit';
}
