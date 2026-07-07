import '../../barcode/domain/product_import_draft.dart';
import '../../products/domain/product.dart';

enum GeminiProductMode {
  genericFood('generic_food'),
  nutritionLabelImage('nutrition_label_image');

  const GeminiProductMode(this.storageValue);

  final String storageValue;

  static GeminiProductMode fromStorage(String value) {
    return GeminiProductMode.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => GeminiProductMode.genericFood,
    );
  }
}

enum GeminiProductStatus {
  ok('ok'),
  notFound('not_found'),
  uncertain('uncertain'),
  error('error');

  const GeminiProductStatus(this.storageValue);

  final String storageValue;

  static GeminiProductStatus fromStorage(String value) {
    return GeminiProductStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => GeminiProductStatus.error,
    );
  }
}

enum GeminiNutritionBasis {
  per100g('per_100g'),
  per100ml('per_100ml'),
  perServing('per_serving'),
  unknown('unknown');

  const GeminiNutritionBasis(this.storageValue);

  final String storageValue;

  static GeminiNutritionBasis fromStorage(String? value) {
    return GeminiNutritionBasis.values.firstWhere(
      (basis) => basis.storageValue == value,
      orElse: () => GeminiNutritionBasis.unknown,
    );
  }
}

class GeminiProductAnalysis {
  const GeminiProductAnalysis({
    required this.status,
    required this.sourceMode,
    required this.basis,
    required this.confidence,
    required this.warnings,
    required this.assumptions,
    required this.explanation,
    this.draft,
  });

  factory GeminiProductAnalysis.fromJson(Map<String, dynamic> json) {
    final mode = GeminiProductMode.fromStorage(
      json['source_mode'] as String? ?? 'generic_food',
    );
    final product = json['product'];
    final productJson = product is Map<String, dynamic> ? product : null;
    return GeminiProductAnalysis(
      status: GeminiProductStatus.fromStorage(
        json['status'] as String? ?? 'error',
      ),
      sourceMode: mode,
      basis: GeminiNutritionBasis.fromStorage(
        productJson?['basis'] as String? ?? json['basis'] as String?,
      ),
      confidence: json['confidence'] as String? ?? 'low',
      warnings: _stringList(json['warnings']),
      assumptions: _stringList(json['assumptions']),
      explanation: json['explanation'] as String? ?? '',
      draft: productJson == null ? null : _draftFromJson(productJson, mode),
    );
  }

  final GeminiProductStatus status;
  final GeminiProductMode sourceMode;
  final GeminiNutritionBasis basis;
  final ProductImportDraft? draft;
  final String confidence;
  final List<String> warnings;
  final List<String> assumptions;
  final String explanation;

  bool get hasDraft => draft != null;

  bool get hasUsableDraft {
    return status == GeminiProductStatus.ok &&
        draft?.hasRequiredNutrition == true;
  }

  String get sourceLabel {
    return switch (sourceMode) {
      GeminiProductMode.genericFood => 'Gemini alimento genérico',
      GeminiProductMode.nutritionLabelImage => 'Gemini etiqueta',
    };
  }

  String get sourceValue {
    return switch (sourceMode) {
      GeminiProductMode.genericFood => 'gemini_generic',
      GeminiProductMode.nutritionLabelImage => 'gemini_label',
    };
  }

  static ProductImportDraft _draftFromJson(
    Map<String, dynamic> json,
    GeminiProductMode mode,
  ) {
    final basis = GeminiNutritionBasis.fromStorage(json['basis'] as String?);
    final source = switch (mode) {
      GeminiProductMode.genericFood => 'gemini_generic',
      GeminiProductMode.nutritionLabelImage => 'gemini_label',
    };
    final baseUnitLabel = json['base_unit'] as String? ?? 'g';
    final baseUnit =
        baseUnitLabel == 'ml' || basis == GeminiNutritionBasis.per100ml
        ? BaseUnit.milliliters
        : BaseUnit.grams;
    final servingSize = _number(json['serving_size']);
    final valuesArePer100 =
        basis == GeminiNutritionBasis.per100g ||
        basis == GeminiNutritionBasis.per100ml;

    return ProductImportDraft(
      barcode: json['barcode'] as String? ?? '',
      name: json['name'] as String? ?? 'Producto Gemini',
      brand: json['brand'] as String?,
      baseUnit: baseUnit,
      servingSize: servingSize,
      servingUnit: servingSize == null
          ? null
          : (json['serving_unit'] as String? ?? baseUnit.label),
      caloriesPer100: _per100Number(
        json,
        explicitKey: 'calories_per_100',
        basisKey: 'calories_kcal',
        valuesArePer100: valuesArePer100,
      ),
      proteinPer100: _per100Number(
        json,
        explicitKey: 'protein_per_100',
        basisKey: 'protein_g',
        valuesArePer100: valuesArePer100,
      ),
      carbsPer100: _per100Number(
        json,
        explicitKey: 'carbs_per_100',
        basisKey: 'carbs_g',
        valuesArePer100: valuesArePer100,
      ),
      fatPer100: _per100Number(
        json,
        explicitKey: 'fat_per_100',
        basisKey: 'fat_g',
        valuesArePer100: valuesArePer100,
      ),
      saturatedFatPer100: _per100Number(
        json,
        explicitKey: 'saturated_fat_per_100',
        basisKey: 'saturated_fat_g',
        valuesArePer100: valuesArePer100,
      ),
      sugarPer100: _per100Number(
        json,
        explicitKey: 'sugar_per_100',
        basisKey: 'sugar_g',
        valuesArePer100: valuesArePer100,
      ),
      sodiumPer100: _per100Number(
        json,
        explicitKey: 'sodium_per_100',
        basisKey: 'sodium_mg',
        valuesArePer100: valuesArePer100,
      ),
      fiberPer100: _per100Number(
        json,
        explicitKey: 'fiber_per_100',
        basisKey: 'fiber_g',
        valuesArePer100: valuesArePer100,
      ),
      source: source,
    );
  }

  static double? _per100Number(
    Map<String, dynamic> json, {
    required String explicitKey,
    required String basisKey,
    required bool valuesArePer100,
  }) {
    final explicitValue = _number(json[explicitKey]);
    if (explicitValue != null) {
      return explicitValue;
    }
    if (!valuesArePer100) {
      return null;
    }
    return _number(json[basisKey]);
  }

  static double? _number(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return [
      for (final item in value)
        if (item != null && item.toString().trim().isNotEmpty)
          item.toString().trim(),
    ];
  }
}
