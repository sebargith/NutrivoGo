import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

import '../../products/domain/product.dart';
import '../domain/nutrition_label_ocr_draft.dart';

enum AiLabelExtractionProgress { uploading, analyzing }

abstract class NutritionLabelAiExtractionClient {
  Future<NutritionLabelOcrDraft> analyze({
    required NutritionLabelOcrDraft currentDraft,
    void Function(AiLabelExtractionProgress progress)? onProgress,
  });
}

class SupabaseNutritionLabelAiExtractionClient
    implements NutritionLabelAiExtractionClient {
  SupabaseNutritionLabelAiExtractionClient({required this.client});

  final SupabaseClient client;
  final NutritionLabelAiResponseMapper _mapper =
      const NutritionLabelAiResponseMapper();

  @override
  Future<NutritionLabelOcrDraft> analyze({
    required NutritionLabelOcrDraft currentDraft,
    void Function(AiLabelExtractionProgress progress)? onProgress,
  }) async {
    final imagePath = currentDraft.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      throw StateError('No captured label image is available for AI analysis.');
    }

    onProgress?.call(AiLabelExtractionProgress.uploading);
    final imageBytes = await File(imagePath).readAsBytes();
    final imageBase64 = base64Encode(imageBytes);

    onProgress?.call(AiLabelExtractionProgress.analyzing);
    final response = await client.functions.invoke(
      'analyze-nutrition-label',
      body: {
        'image_base64': imageBase64,
        'mime_type': _mimeTypeFor(imagePath),
        'ocr_text': currentDraft.rawText,
        'current_values': _mapper.toJson(currentDraft),
      },
    );

    final data = response.data;
    if (data is! Map) {
      throw const FormatException(
        'AI function returned an unexpected response.',
      );
    }
    final result = data['result'] ?? data;
    if (result is! Map) {
      throw const FormatException('AI extraction result was missing.');
    }
    return _mapper.fromJson(
      Map<String, dynamic>.from(result),
      currentDraft: currentDraft,
    );
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}

class NutritionLabelAiResponseMapper {
  const NutritionLabelAiResponseMapper();

  NutritionLabelOcrDraft fromJson(
    Map<String, dynamic> json, {
    required NutritionLabelOcrDraft currentDraft,
  }) {
    final basis = _basisFromJson(json['basis']);
    final values = _valuesFromJson(json);
    final perServing = _valuesFromJson(_asMap(json['per_serving']));
    final confidence = _number(json['confidence']);
    final warnings = _warnings(json['warnings']);

    if (confidence != null && confidence < 0.6) {
      warnings.add('AI confidence is low. Review every value before saving.');
    }
    warnings.add('AI extraction can be wrong. Review before saving.');

    final servingSize =
        _number(json['serving_size']) ?? currentDraft.servingSize;
    final servingUnit =
        _string(json['serving_unit']) ?? currentDraft.servingUnit;
    final baseUnit = switch (basis) {
      OcrNutritionBasis.per100ml => BaseUnit.milliliters,
      _ => servingUnit == 'ml' ? BaseUnit.milliliters : currentDraft.baseUnit,
    };

    if (basis == OcrNutritionBasis.perServing) {
      if (!_hasAny(perServing)) {
        warnings.add(
          'AI detected per-serving basis but did not return per-serving values.',
        );
      } else {
        warnings.add(
          'AI returned per-serving values only. Fill or normalize per-100 values before saving.',
        );
      }
      return currentDraft.copyWith(
        name: _string(json['product_name']) ?? currentDraft.name,
        brand: _string(json['brand']) ?? currentDraft.brand,
        servingSize: servingSize,
        servingUnit: servingUnit,
        baseUnit: baseUnit,
        detectedBasis: basis,
        perServingValues: _hasAny(perServing) ? perServing : null,
        normalizedFromServing: false,
        warnings: warnings,
        confidence: confidence,
      );
    }

    return NutritionLabelOcrDraft(
      rawText: currentDraft.rawText,
      imagePath: currentDraft.imagePath,
      name: _string(json['product_name']) ?? currentDraft.name,
      brand: _string(json['brand']) ?? currentDraft.brand,
      servingSize: servingSize,
      servingUnit: servingUnit,
      baseUnit: baseUnit,
      caloriesPer100: values.calories ?? currentDraft.caloriesPer100,
      proteinPer100: values.protein ?? currentDraft.proteinPer100,
      carbsPer100: values.carbs ?? currentDraft.carbsPer100,
      fatPer100: values.fat ?? currentDraft.fatPer100,
      sugarPer100: values.sugar ?? currentDraft.sugarPer100,
      saturatedFatPer100:
          values.saturatedFat ?? currentDraft.saturatedFatPer100,
      sodiumPer100: values.sodium ?? currentDraft.sodiumPer100,
      fiberPer100: values.fiber ?? currentDraft.fiberPer100,
      detectedBasis: basis,
      perServingValues: _hasAny(perServing) ? perServing : null,
      normalizedFromServing: false,
      warnings: warnings,
      confidence: confidence,
    );
  }

  Map<String, dynamic> toJson(NutritionLabelOcrDraft draft) {
    return {
      'product_name': draft.name,
      'brand': draft.brand,
      'serving_size': draft.servingSize,
      'serving_unit': draft.servingUnit,
      'basis': _basisToJson(draft.detectedBasis),
      'calories_kcal': draft.caloriesPer100,
      'protein_g': draft.proteinPer100,
      'carbs_g': draft.carbsPer100,
      'fat_g': draft.fatPer100,
      'sugar_g': draft.sugarPer100,
      'saturated_fat_g': draft.saturatedFatPer100,
      'sodium_mg': draft.sodiumPer100,
      'fiber_g': draft.fiberPer100,
      'confidence': draft.confidence,
      'warnings': draft.warnings,
    };
  }

  OcrNutritionValues _valuesFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OcrNutritionValues();
    }
    return OcrNutritionValues(
      calories: _number(json['calories_kcal']),
      protein: _number(json['protein_g']),
      carbs: _number(json['carbs_g']),
      fat: _number(json['fat_g']),
      sugar: _number(json['sugar_g']),
      saturatedFat: _number(json['saturated_fat_g']),
      sodium: _number(json['sodium_mg']),
      fiber: _number(json['fiber_g']),
    );
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  bool _hasAny(OcrNutritionValues values) {
    return values.calories != null ||
        values.protein != null ||
        values.carbs != null ||
        values.fat != null ||
        values.sugar != null ||
        values.saturatedFat != null ||
        values.sodium != null ||
        values.fiber != null;
  }

  OcrNutritionBasis _basisFromJson(Object? value) {
    return switch (_string(value)) {
      'per_100g' => OcrNutritionBasis.per100g,
      'per_100ml' => OcrNutritionBasis.per100ml,
      'per_serving' => OcrNutritionBasis.perServing,
      _ => OcrNutritionBasis.unknown,
    };
  }

  String _basisToJson(OcrNutritionBasis basis) {
    return switch (basis) {
      OcrNutritionBasis.per100g => 'per_100g',
      OcrNutritionBasis.per100ml => 'per_100ml',
      OcrNutritionBasis.perServing => 'per_serving',
      OcrNutritionBasis.unknown => 'unknown',
    };
  }

  String? _string(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  double? _number(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }

  List<String> _warnings(Object? value) {
    if (value is List) {
      return value
          .map((warning) => warning.toString().trim())
          .where((warning) => warning.isNotEmpty)
          .toList();
    }
    return <String>[];
  }
}

class NutritionLabelAiEnhancer {
  const NutritionLabelAiEnhancer({required this.client});

  final NutritionLabelAiExtractionClient client;

  Future<NutritionLabelAiEnhancementResult> analyzeOrKeep({
    required NutritionLabelOcrDraft currentDraft,
    void Function(AiLabelExtractionProgress progress)? onProgress,
  }) async {
    try {
      final draft = await client.analyze(
        currentDraft: currentDraft,
        onProgress: onProgress,
      );
      return NutritionLabelAiEnhancementResult.success(draft);
    } on Object catch (error) {
      return NutritionLabelAiEnhancementResult.failure(currentDraft, error);
    }
  }
}

class NutritionLabelAiEnhancementResult {
  const NutritionLabelAiEnhancementResult._({
    required this.draft,
    required this.isSuccess,
    this.error,
  });

  const NutritionLabelAiEnhancementResult.success(NutritionLabelOcrDraft draft)
    : this._(draft: draft, isSuccess: true);

  const NutritionLabelAiEnhancementResult.failure(
    NutritionLabelOcrDraft draft,
    Object error,
  ) : this._(draft: draft, isSuccess: false, error: error);

  final NutritionLabelOcrDraft draft;
  final bool isSuccess;
  final Object? error;
}
