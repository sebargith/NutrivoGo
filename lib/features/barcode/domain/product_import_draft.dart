import '../../products/domain/product.dart';

enum ProductLookupStatus { found, notFound, incomplete }

class ProductImportDraft {
  const ProductImportDraft({
    required this.barcode,
    required this.name,
    this.brand,
    this.servingSize,
    this.servingUnit,
    this.baseUnit = BaseUnit.grams,
    this.caloriesPer100,
    this.proteinPer100,
    this.carbsPer100,
    this.fatPer100,
    this.sugarPer100,
    this.saturatedFatPer100,
    this.sodiumPer100,
    this.fiberPer100,
    this.packagePriceClp,
    this.packageQuantity,
    this.packageQuantityUnit,
    this.source = 'barcode',
  });

  final String barcode;
  final String name;
  final String? brand;
  final double? servingSize;
  final String? servingUnit;
  final BaseUnit baseUnit;
  final double? caloriesPer100;
  final double? proteinPer100;
  final double? carbsPer100;
  final double? fatPer100;
  final double? sugarPer100;
  final double? saturatedFatPer100;
  final double? sodiumPer100;
  final double? fiberPer100;
  final double? packagePriceClp;
  final double? packageQuantity;
  final String? packageQuantityUnit;
  final String source;

  bool get hasRequiredNutrition {
    return name.trim().isNotEmpty &&
        caloriesPer100 != null &&
        proteinPer100 != null &&
        carbsPer100 != null &&
        fatPer100 != null;
  }

  ProductImportDraft copyWith({
    String? barcode,
    String? name,
    String? brand,
    double? servingSize,
    String? servingUnit,
    BaseUnit? baseUnit,
    double? caloriesPer100,
    double? proteinPer100,
    double? carbsPer100,
    double? fatPer100,
    double? sugarPer100,
    double? saturatedFatPer100,
    double? sodiumPer100,
    double? fiberPer100,
    double? packagePriceClp,
    double? packageQuantity,
    String? packageQuantityUnit,
    String? source,
  }) {
    return ProductImportDraft(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      baseUnit: baseUnit ?? this.baseUnit,
      caloriesPer100: caloriesPer100 ?? this.caloriesPer100,
      proteinPer100: proteinPer100 ?? this.proteinPer100,
      carbsPer100: carbsPer100 ?? this.carbsPer100,
      fatPer100: fatPer100 ?? this.fatPer100,
      sugarPer100: sugarPer100 ?? this.sugarPer100,
      saturatedFatPer100: saturatedFatPer100 ?? this.saturatedFatPer100,
      sodiumPer100: sodiumPer100 ?? this.sodiumPer100,
      fiberPer100: fiberPer100 ?? this.fiberPer100,
      packagePriceClp: packagePriceClp ?? this.packagePriceClp,
      packageQuantity: packageQuantity ?? this.packageQuantity,
      packageQuantityUnit: packageQuantityUnit ?? this.packageQuantityUnit,
      source: source ?? this.source,
    );
  }
}

class ProductLookupResult {
  const ProductLookupResult({
    required this.status,
    required this.barcode,
    this.draft,
    this.message,
  });

  const ProductLookupResult.notFound(String barcode)
    : this(
        status: ProductLookupStatus.notFound,
        barcode: barcode,
        message: 'No product was found for this barcode.',
      );

  final ProductLookupStatus status;
  final String barcode;
  final ProductImportDraft? draft;
  final String? message;
}
