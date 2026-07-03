import '../../products/domain/product.dart';

enum OcrNutritionBasis { per100g, per100ml, perServing, unknown }

class OcrNutritionValues {
  const OcrNutritionValues({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.sugar,
    this.saturatedFat,
    this.sodium,
    this.fiber,
  });

  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? sugar;
  final double? saturatedFat;
  final double? sodium;
  final double? fiber;
}

class NutritionLabelOcrDraft {
  const NutritionLabelOcrDraft({
    required this.rawText,
    this.name = 'Scanned product',
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
    this.detectedBasis = OcrNutritionBasis.unknown,
    this.perServingValues,
    this.normalizedFromServing = false,
  });

  final String rawText;
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
  final OcrNutritionBasis detectedBasis;
  final OcrNutritionValues? perServingValues;
  final bool normalizedFromServing;

  bool get hasRequiredNutrition {
    return name.trim().isNotEmpty &&
        caloriesPer100 != null &&
        proteinPer100 != null &&
        carbsPer100 != null &&
        fatPer100 != null;
  }

  List<String> get missingRequiredFields {
    return [
      if (caloriesPer100 == null) 'Energía / Calorías',
      if (proteinPer100 == null) 'Proteínas',
      if (carbsPer100 == null) 'Carbohidratos',
      if (fatPer100 == null) 'Grasas',
    ];
  }

  String get basisLabel {
    return switch (detectedBasis) {
      OcrNutritionBasis.per100g => 'Por 100 g',
      OcrNutritionBasis.per100ml => 'Por 100 ml',
      OcrNutritionBasis.perServing => 'Por porción',
      OcrNutritionBasis.unknown => 'No detectado',
    };
  }

  String get reviewMessage {
    if (normalizedFromServing) {
      return 'OCR found per-serving values and normalized them using the serving size. Review the per-100 values before saving.';
    }
    if (detectedBasis == OcrNutritionBasis.perServing) {
      return 'OCR found per-serving values only. Fill or normalize the per-100 values before saving.';
    }
    if (!hasRequiredNutrition) {
      return 'OCR found incomplete nutrition data. Fill the missing values before saving.';
    }
    return 'Review OCR results before saving. Nothing is saved until you confirm.';
  }

  NutritionLabelOcrDraft copyWith({
    String? rawText,
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
    OcrNutritionBasis? detectedBasis,
    OcrNutritionValues? perServingValues,
    bool? normalizedFromServing,
  }) {
    return NutritionLabelOcrDraft(
      rawText: rawText ?? this.rawText,
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
      detectedBasis: detectedBasis ?? this.detectedBasis,
      perServingValues: perServingValues ?? this.perServingValues,
      normalizedFromServing:
          normalizedFromServing ?? this.normalizedFromServing,
    );
  }
}
