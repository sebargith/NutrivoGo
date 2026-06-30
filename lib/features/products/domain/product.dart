enum BaseUnit {
  grams('g'),
  milliliters('ml');

  const BaseUnit(this.label);

  final String label;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.baseUnit,
    required this.caloriesPer100,
    required this.proteinPer100,
    required this.carbsPer100,
    required this.fatPer100,
    this.brand,
    this.servingSize,
    this.servingUnit,
  });

  final String id;
  final String name;
  final String? brand;
  final double? servingSize;
  final String? servingUnit;
  final BaseUnit baseUnit;
  final double caloriesPer100;
  final double proteinPer100;
  final double carbsPer100;
  final double fatPer100;

  String get displayName {
    final trimmedBrand = brand?.trim();
    if (trimmedBrand == null || trimmedBrand.isEmpty) {
      return name;
    }
    return '$name, $trimmedBrand';
  }

  String get baseUnitLabel => baseUnit.label;

  String? get servingLabel {
    if (servingSize == null) {
      return null;
    }
    final unit = servingUnit?.trim().isNotEmpty == true
        ? servingUnit!.trim()
        : baseUnit.label;
    return '${_formatAmount(servingSize!)} $unit';
  }

  static String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
