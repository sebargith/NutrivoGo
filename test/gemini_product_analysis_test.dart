import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/features/gemini/domain/gemini_product_analysis.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  test('maps generic Gemini JSON into a product draft', () {
    final analysis = GeminiProductAnalysis.fromJson({
      'status': 'ok',
      'source_mode': 'generic_food',
      'product': {
        'name': 'Plátano',
        'basis': 'per_100g',
        'base_unit': 'g',
        'calories_kcal': 89,
        'protein_g': '1,1',
        'carbs_g': 22.8,
        'fat_g': 0.3,
        'sugar_g': 12.2,
        'fiber_g': 2.6,
      },
      'confidence': 'medium',
      'warnings': ['Valores aproximados'],
      'assumptions': ['Alimento crudo común'],
      'explanation': 'Valores aproximados por 100 g.',
    });

    expect(analysis.status, GeminiProductStatus.ok);
    expect(analysis.sourceMode, GeminiProductMode.genericFood);
    expect(analysis.basis, GeminiNutritionBasis.per100g);
    expect(analysis.hasUsableDraft, isTrue);
    expect(analysis.draft!.name, 'Plátano');
    expect(analysis.draft!.source, 'gemini_generic');
    expect(analysis.draft!.baseUnit, BaseUnit.grams);
    expect(analysis.draft!.caloriesPer100, 89);
    expect(analysis.draft!.proteinPer100, 1.1);
    expect(analysis.draft!.carbsPer100, 22.8);
    expect(analysis.draft!.fatPer100, 0.3);
    expect(analysis.draft!.sugarPer100, 12.2);
    expect(analysis.draft!.fiberPer100, 2.6);
  });

  test('maps label Gemini JSON into gemini_label source', () {
    final analysis = GeminiProductAnalysis.fromJson({
      'status': 'ok',
      'source_mode': 'nutrition_label_image',
      'product': {
        'name': 'Yogur natural',
        'brand': 'Marca',
        'serving_size': 140,
        'serving_unit': 'g',
        'basis': 'per_100g',
        'calories_kcal': 65,
        'protein_g': 8.8,
        'carbs_g': 5.9,
        'fat_g': 0.7,
        'saturated_fat_g': 0.4,
        'sodium_mg': 65,
      },
      'confidence': 'high',
      'warnings': <String>[],
      'assumptions': <String>[],
      'explanation': 'Etiqueta chilena detectada.',
    });

    expect(analysis.sourceLabel, 'Gemini etiqueta');
    expect(analysis.draft!.source, 'gemini_label');
    expect(analysis.draft!.servingSize, 140);
    expect(analysis.draft!.saturatedFatPer100, 0.4);
    expect(analysis.draft!.sodiumPer100, 65);
  });

  test('generic Gemini output with unknown basis still maps as per 100g', () {
    final analysis = GeminiProductAnalysis.fromJson({
      'status': 'ok',
      'source_mode': 'generic_food',
      'product': {
        'name': 'plátano',
        'basis': 'unknown',
        'calories_kcal': 89,
        'protein_g': 1.1,
        'carbs_g': 22.8,
        'fat_g': 0.3,
      },
      'confidence': 'low',
      'warnings': <String>[],
      'assumptions': ['Values are approximate common nutrition.'],
      'explanation': 'Valores nutricionales aproximados para un plátano crudo.',
    });

    expect(analysis.basis, GeminiNutritionBasis.per100g);
    expect(analysis.hasUsableDraft, isTrue);
    expect(analysis.draft!.caloriesPer100, 89);
    expect(analysis.draft!.proteinPer100, 1.1);
    expect(analysis.draft!.carbsPer100, 22.8);
    expect(analysis.draft!.fatPer100, 0.3);
  });

  test('generic Gemini output without basis still maps as per 100g', () {
    final analysis = GeminiProductAnalysis.fromJson({
      'status': 'ok',
      'source_mode': 'generic_food',
      'product': {
        'name': 'arroz cocido',
        'base_unit': 'g',
        'calories_kcal': 130,
        'protein_g': 2.7,
        'carbs_g': 28,
        'fat_g': 0.3,
      },
      'confidence': 'low',
      'warnings': <String>[],
      'assumptions': <String>[],
      'explanation': 'Valores aproximados por 100 g.',
    });

    expect(analysis.basis, GeminiNutritionBasis.per100g);
    expect(analysis.hasUsableDraft, isTrue);
    expect(analysis.draft!.caloriesPer100, 130);
    expect(analysis.draft!.proteinPer100, 2.7);
    expect(analysis.draft!.carbsPer100, 28);
    expect(analysis.draft!.fatPer100, 0.3);
  });

  test('per-serving-only Gemini output does not become per-100 values', () {
    final analysis = GeminiProductAnalysis.fromJson({
      'status': 'ok',
      'source_mode': 'nutrition_label_image',
      'product': {
        'name': 'Producto por porción',
        'serving_size': 140,
        'serving_unit': 'g',
        'basis': 'per_serving',
        'calories_kcal': 91,
        'protein_g': 12.3,
        'carbs_g': 8.3,
        'fat_g': 1,
      },
      'confidence': 'low',
      'warnings': ['Solo se detectaron valores por porción'],
      'assumptions': <String>[],
      'explanation': 'Revisar y normalizar antes de guardar.',
    });

    expect(analysis.basis, GeminiNutritionBasis.perServing);
    expect(analysis.hasDraft, isTrue);
    expect(analysis.hasUsableDraft, isFalse);
    expect(analysis.draft!.caloriesPer100, isNull);
    expect(analysis.draft!.proteinPer100, isNull);
    expect(
      analysis.warnings,
      contains('Solo se detectaron valores por porción'),
    );
  });

  test('missing product fields produce an editable but incomplete draft', () {
    final analysis = GeminiProductAnalysis.fromJson({
      'status': 'uncertain',
      'source_mode': 'generic_food',
      'product': {
        'name': 'Alimento incompleto',
        'basis': 'per_100g',
        'calories_kcal': 100,
      },
      'confidence': 'low',
      'warnings': ['Faltan macros'],
      'assumptions': <String>[],
      'explanation': '',
    });

    expect(analysis.hasDraft, isTrue);
    expect(analysis.hasUsableDraft, isFalse);
    expect(analysis.draft!.caloriesPer100, 100);
    expect(analysis.draft!.proteinPer100, isNull);
  });
}
