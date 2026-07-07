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
    this.warnings = const <String>[],
    this.parserConfidence,
    this.imagePathLocal,
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
  final List<String> warnings;
  final double? parserConfidence;
  final String? imagePathLocal;

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

  String get basisStorageValue {
    return switch (detectedBasis) {
      OcrNutritionBasis.per100g => 'per_100g',
      OcrNutritionBasis.per100ml => 'per_100ml',
      OcrNutritionBasis.perServing => 'per_serving',
      OcrNutritionBasis.unknown => 'unknown',
    };
  }

  Map<String, Object?> toReportJson({String source = 'ocr'}) {
    return {
      'name': name,
      'brand': brand,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'base_unit': baseUnit.label,
      'basis': basisStorageValue,
      'calories_per_100': caloriesPer100,
      'protein_per_100': proteinPer100,
      'carbs_per_100': carbsPer100,
      'fat_per_100': fatPer100,
      'saturated_fat_per_100': saturatedFatPer100,
      'sugar_per_100': sugarPer100,
      'sodium_per_100': sodiumPer100,
      'fiber_per_100': fiberPer100,
      'per_serving': perServingValues?.toReportJson(),
      'normalized_from_serving': normalizedFromServing,
      'warnings': warnings,
      'confidence': parserConfidence,
      'source': source,
    };
  }

  String get reviewMessage {
    if (normalizedFromServing) {
      return 'OCR encontró valores por porción y los normalizo usando el tamaño de porción. Revisa los valores por 100 antes de guardar.';
    }
    if (detectedBasis == OcrNutritionBasis.perServing) {
      return 'OCR encontró solo valores por porción. Completa o normaliza los valores por 100 antes de guardar.';
    }
    if (!hasRequiredNutrition) {
      return 'OCR encontró datos nutricionales incompletos. Completa los valores faltantes antes de guardar.';
    }
    return 'Revisa los resultados OCR antes de guardar. Nada se guarda hasta que confirmes.';
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
    List<String>? warnings,
    double? parserConfidence,
    String? imagePathLocal,
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
      warnings: warnings ?? this.warnings,
      parserConfidence: parserConfidence ?? this.parserConfidence,
      imagePathLocal: imagePathLocal ?? this.imagePathLocal,
    );
  }
}

extension OcrNutritionValuesReportJson on OcrNutritionValues {
  Map<String, Object?> toReportJson() {
    return {
      'calories_kcal': calories,
      'protein_g': protein,
      'carbs_g': carbs,
      'fat_g': fat,
      'sugar_g': sugar,
      'saturated_fat_g': saturatedFat,
      'sodium_mg': sodium,
      'fiber_g': fiber,
    };
  }
}
