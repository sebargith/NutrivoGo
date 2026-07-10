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
    final normalized = value?.trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
    final alias = switch (normalized) {
      'per100g' || 'per_100_g' || '100g' || '100_g' => 'per_100g',
      'per100ml' || 'per_100_ml' || '100ml' || '100_ml' => 'per_100ml',
      'serving' ||
      'per_serving' ||
      'por_serving' ||
      'por_porcion' => 'per_serving',
      _ => normalized,
    };
    return GeminiNutritionBasis.values.firstWhere(
      (basis) => basis.storageValue == alias,
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
    final basis = _basisFromJson(productJson, json, mode);
    return GeminiProductAnalysis(
      status: GeminiProductStatus.fromStorage(
        json['status'] as String? ?? 'error',
      ),
      sourceMode: mode,
      basis: basis,
      confidence: json['confidence'] as String? ?? 'low',
      warnings: _stringList(json['warnings']),
      assumptions: _stringList(json['assumptions']),
      explanation: json['explanation'] as String? ?? '',
      draft: productJson == null
          ? null
          : _draftFromJson(productJson, mode, basis),
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
    GeminiNutritionBasis basis,
  ) {
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
        basis == GeminiNutritionBasis.per100ml ||
        (mode == GeminiProductMode.genericFood &&
            basis == GeminiNutritionBasis.unknown);

    return ProductImportDraft(
      barcode: json['barcode'] as String? ?? '',
      name: json['name'] as String? ?? 'Producto Gemini',
      brand: json['brand'] as String?,
      baseUnit: baseUnit,
      servingSize: servingSize,
      servingUnit: servingSize == null
          ? null
          : (json['serving_unit'] as String? ?? baseUnit.label),
      unitsPerServing: _number(json['units_per_serving']),
      servingsPerPackage: _number(json['servings_per_package']),
      caloriesPer100: _per100Number(
        json,
        explicitKeys: const [
          'calories_per_100',
          'calories_kcal_per_100',
          'energy_kcal_per_100',
          'kcal_per_100',
        ],
        basisKeys: const ['calories_kcal', 'calories', 'energy_kcal', 'kcal'],
        valuesArePer100: valuesArePer100,
      ),
      proteinPer100: _per100Number(
        json,
        explicitKeys: const ['protein_per_100', 'protein_g_per_100'],
        basisKeys: const ['protein_g', 'proteins', 'protein', 'proteinas'],
        valuesArePer100: valuesArePer100,
      ),
      carbsPer100: _per100Number(
        json,
        explicitKeys: const [
          'carbs_per_100',
          'carbohydrate_per_100',
          'carbohydrates_per_100',
          'carbs_g_per_100',
        ],
        basisKeys: const [
          'carbs_g',
          'carbohydrates_g',
          'carbs',
          'carbohydrates',
          'carbohidratos',
          'hidratos_de_carbono',
        ],
        valuesArePer100: valuesArePer100,
      ),
      fatPer100: _per100Number(
        json,
        explicitKeys: const [
          'fat_per_100',
          'fat_g_per_100',
          'total_fat_per_100',
        ],
        basisKeys: const ['fat_g', 'fat', 'total_fat', 'grasa_total', 'grasas'],
        valuesArePer100: valuesArePer100,
      ),
      saturatedFatPer100: _per100Number(
        json,
        explicitKeys: const [
          'saturated_fat_per_100',
          'saturated_fat_g_per_100',
        ],
        basisKeys: const [
          'saturated_fat_g',
          'saturated_fat',
          'grasa_saturada',
          'grasas_saturadas',
        ],
        valuesArePer100: valuesArePer100,
      ),
      sugarPer100: _per100Number(
        json,
        explicitKeys: const [
          'sugar_per_100',
          'sugars_per_100',
          'sugar_g_per_100',
        ],
        basisKeys: const ['sugar_g', 'sugars_g', 'sugar', 'sugars', 'azucares'],
        valuesArePer100: valuesArePer100,
      ),
      sodiumPer100: _per100Number(
        json,
        explicitKeys: const ['sodium_per_100', 'sodium_mg_per_100'],
        basisKeys: const ['sodium_mg', 'sodium', 'sodio'],
        valuesArePer100: valuesArePer100,
      ),
      fiberPer100: _per100Number(
        json,
        explicitKeys: const [
          'fiber_per_100',
          'fibre_per_100',
          'fiber_g_per_100',
        ],
        basisKeys: const ['fiber_g', 'fibre_g', 'fiber', 'fibre', 'fibra'],
        valuesArePer100: valuesArePer100,
      ),
      source: source,
    );
  }

  static GeminiNutritionBasis _basisFromJson(
    Map<String, dynamic>? productJson,
    Map<String, dynamic> rootJson,
    GeminiProductMode mode,
  ) {
    final parsed = GeminiNutritionBasis.fromStorage(
      productJson?['basis'] as String? ?? rootJson['basis'] as String?,
    );
    if (parsed != GeminiNutritionBasis.unknown ||
        mode != GeminiProductMode.genericFood) {
      return parsed;
    }
    final baseUnit = productJson?['base_unit'] as String?;
    return baseUnit == 'ml'
        ? GeminiNutritionBasis.per100ml
        : GeminiNutritionBasis.per100g;
  }

  static double? _per100Number(
    Map<String, dynamic> json, {
    required List<String> explicitKeys,
    required List<String> basisKeys,
    required bool valuesArePer100,
  }) {
    final sources = _nutritionSources(json);
    final explicitValue = _firstNumber(sources, explicitKeys);
    if (explicitValue != null) {
      return explicitValue;
    }
    if (!valuesArePer100) {
      return null;
    }
    return _firstNumber(sources, basisKeys);
  }

  static double? _firstNumber(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    final normalizedKeys = keys.map(_normalizeKey).toSet();
    for (final source in sources) {
      for (final entry in source.entries) {
        if (normalizedKeys.contains(_normalizeKey(entry.key))) {
          final value = _number(entry.value);
          if (value != null) {
            return value;
          }
        }
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> _nutritionSources(
    Map<String, dynamic> json,
  ) {
    const nestedKeys = [
      'nutrition',
      'nutrients',
      'nutrients_per_100g',
      'nutrients_per_100ml',
      'per_100g',
      'per_100ml',
      'per100',
      'per100g',
      'per100ml',
    ];
    return [
      json,
      for (final key in nestedKeys)
        if (json[key] is Map<String, dynamic>)
          json[key] as Map<String, dynamic>,
    ];
  }

  static String _normalizeKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(RegExp(r'[\s\-.]+'), '_');
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
