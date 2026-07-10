import '../../../core/sync/record_sync_status.dart';

enum BaseUnit {
  grams('g'),
  milliliters('ml');

  const BaseUnit(this.label);

  final String label;

  static BaseUnit fromLabel(String label) {
    return BaseUnit.values.firstWhere(
      (unit) => unit.label == label,
      orElse: () => throw ArgumentError.value(label, 'label', 'Unknown unit'),
    );
  }
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
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.servingSize,
    this.servingUnit,
    this.deletedAt,
    this.userId,
    this.syncStatus = RecordSyncStatus.pending,
    this.lastSyncedAt,
    this.barcode,
    this.source,
    this.sugarPer100,
    this.saturatedFatPer100,
    this.sodiumPer100,
    this.fiberPer100,
    this.packagePriceClp,
    this.packageQuantity,
    this.packageQuantityUnit,
    this.unitsPerServing,
    this.servingsPerPackage,
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;
  final RecordSyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final String? barcode;
  final String? source;
  final double? sugarPer100;
  final double? saturatedFatPer100;
  final double? sodiumPer100;
  final double? fiberPer100;
  final double? packagePriceClp;
  final double? packageQuantity;
  final String? packageQuantityUnit;
  final double? unitsPerServing;
  final double? servingsPerPackage;

  double? get baseQuantityPerUnit {
    final size = servingSize;
    final units = unitsPerServing;
    if (size == null || size <= 0 || units == null || units <= 0) {
      return null;
    }
    return size / units;
  }

  double? get estimatedPackageQuantity {
    final size = servingSize;
    final servings = servingsPerPackage;
    if (size == null || size <= 0 || servings == null || servings <= 0) {
      return null;
    }
    return size * servings;
  }

  double? get totalUnitsPerPackage {
    final units = unitsPerServing;
    final servings = servingsPerPackage;
    if (units == null || units <= 0 || servings == null || servings <= 0) {
      return null;
    }
    return units * servings;
  }

  double? get effectivePackageQuantity {
    final stored = packageQuantity;
    if (stored != null && stored > 0) {
      return stored;
    }
    return estimatedPackageQuantity;
  }

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

  Product copyWith({
    String? name,
    String? brand,
    double? servingSize,
    String? servingUnit,
    BaseUnit? baseUnit,
    double? caloriesPer100,
    double? proteinPer100,
    double? carbsPer100,
    double? fatPer100,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? userId,
    RecordSyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? barcode,
    String? source,
    double? sugarPer100,
    double? saturatedFatPer100,
    double? sodiumPer100,
    double? fiberPer100,
    double? packagePriceClp,
    double? packageQuantity,
    String? packageQuantityUnit,
    double? unitsPerServing,
    double? servingsPerPackage,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      baseUnit: baseUnit ?? this.baseUnit,
      caloriesPer100: caloriesPer100 ?? this.caloriesPer100,
      proteinPer100: proteinPer100 ?? this.proteinPer100,
      carbsPer100: carbsPer100 ?? this.carbsPer100,
      fatPer100: fatPer100 ?? this.fatPer100,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      barcode: barcode ?? this.barcode,
      source: source ?? this.source,
      sugarPer100: sugarPer100 ?? this.sugarPer100,
      saturatedFatPer100: saturatedFatPer100 ?? this.saturatedFatPer100,
      sodiumPer100: sodiumPer100 ?? this.sodiumPer100,
      fiberPer100: fiberPer100 ?? this.fiberPer100,
      packagePriceClp: packagePriceClp ?? this.packagePriceClp,
      packageQuantity: packageQuantity ?? this.packageQuantity,
      packageQuantityUnit: packageQuantityUnit ?? this.packageQuantityUnit,
      unitsPerServing: unitsPerServing ?? this.unitsPerServing,
      servingsPerPackage: servingsPerPackage ?? this.servingsPerPackage,
    );
  }
}
