import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/macro_calculator.dart';
import 'package:nutrivogo/features/ocr/application/nutrition_label_ocr_parser.dart';
import 'package:nutrivogo/features/ocr/application/ocr_product_import_saver.dart';
import 'package:nutrivogo/features/ocr/domain/nutrition_label_ocr_draft.dart';
import 'package:nutrivogo/features/ocr/presentation/ocr_scan_screen.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  const parser = NutritionLabelOcrParser();
  final fixedNow = DateTime(2026, 7, 3, 12);

  Future<({AppDatabase database, NutrivoGoStore store})>
  createMemoryStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database, clock: () => fixedNow);
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  test('Spanish label parsing reads Chile-friendly nutrient names', () {
    final draft = parser.parse('''
Información nutricional
Porción: 30 g
Por 100 g
Energía 390 kcal
Proteínas 12 g
Hidratos de carbono 62 g
Azúcares 7 g
Lípidos totales 8 g
Grasas saturadas 2,5 g
Sodio 320 mg
Fibra dietética 9 g
''');

    expect(draft.detectedBasis, OcrNutritionBasis.per100g);
    expect(draft.servingSize, 30);
    expect(draft.servingUnit, 'g');
    expect(draft.caloriesPer100, 390);
    expect(draft.proteinPer100, 12);
    expect(draft.carbsPer100, 62);
    expect(draft.fatPer100, 8);
    expect(draft.sugarPer100, 7);
    expect(draft.saturatedFatPer100, 2.5);
    expect(draft.sodiumPer100, 320);
    expect(draft.fiberPer100, 9);
  });

  test('per-100g parsing prefers per-100 column over serving column', () {
    final draft = parser.parse('''
Porción 30 g
Por 100 g Por porción
Energía 400 kcal 120 kcal
Proteínas 10 g 3 g
Carbohidratos 70 g 21 g
Grasas 8 g 2,4 g
''');

    expect(draft.detectedBasis, OcrNutritionBasis.per100g);
    expect(draft.baseUnit, BaseUnit.grams);
    expect(draft.caloriesPer100, 400);
    expect(draft.proteinPer100, 10);
    expect(draft.carbsPer100, 70);
    expect(draft.fatPer100, 8);
  });

  test('per-100ml parsing sets milliliter base unit', () {
    final draft = parser.parse('''
Información nutricional
Porción 200 ml
Por 100 ml
Calorías 45 kcal
Proteínas 3,2 g
Carbohidratos 5 g
Grasas 1,5 g
Azúcares 4,8 g
Sodio 55 mg
''');

    expect(draft.detectedBasis, OcrNutritionBasis.per100ml);
    expect(draft.baseUnit, BaseUnit.milliliters);
    expect(draft.servingSize, 200);
    expect(draft.servingUnit, 'ml');
    expect(draft.caloriesPer100, 45);
    expect(draft.proteinPer100, 3.2);
    expect(draft.carbsPer100, 5);
    expect(draft.fatPer100, 1.5);
  });

  test('reconstructs real Chilean yogurt OCR table with vertical columns', () {
    final draft = parser.parse('''
INFORMACION NUTRICIONAL
Porción: 1 envase (140 g)
Porciones por envase: 1
Energía (kcal)
Proteínas (9)
Grasa total (g)
Grasa saturada (g)
Grasa monoinsat. (g)
Grasa poliinsat. (9)
Ac. Grasos Trans (9)
Colesterol (mg)
H. de C. Disp. (g)
Azúcares totales (a)
Azúcar (Sacarosa) (g)
Lactosa (9)
Sodio (mg)
Calcio (mg)
100 g
Dosis de edulcorantes:
Sucalosa (ng)
65
8,8
0,7
0,4
0,2
0
5,1
5,9
5,9
0,1
65
100
1 Pordón
91
20
12,3
1
0,6
0.3
0
1,1
8,3
8,3
0
0,1
91
)% en relación a la Dosis Diaria Recomendad
1896()
100 g 1Pocón
sleva (Esteviol equivalentes) (ng) 2
LDA (ngesta Diaria Admisibe: Sucralosa 0-15
pu kg de peso coporal. Esteva 0-4 mg por g &
peso iorporal lexpresado como esteviol.
28
''');

    expect(draft.detectedBasis, OcrNutritionBasis.per100g);
    expect(draft.servingSize, 140);
    expect(draft.servingUnit, 'g');
    expect(draft.caloriesPer100, 65);
    expect(draft.proteinPer100, 8.8);
    expect(draft.fatPer100, 0.7);
    expect(draft.saturatedFatPer100, 0.4);
    expect(draft.carbsPer100, 5.9);
    expect(draft.sugarPer100, 5.9);
    expect(draft.sodiumPer100, 65);
    expect(draft.fiberPer100, isNull);
    expect(draft.perServingValues?.calories, 91);
    expect(draft.perServingValues?.protein, 12.3);
    expect(draft.perServingValues?.fat, 1);
    expect(draft.perServingValues?.saturatedFat, 0.6);
    expect(draft.perServingValues?.carbs, 8.3);
    expect(draft.perServingValues?.sugar, 8.3);
    expect(draft.perServingValues?.sodium, 91);
    expect(draft.warnings, isNotEmpty);
    expect(draft.warnings.join(' '), contains('reconstructed OCR table'));
  });

  test('per-serving fallback normalizes values when serving size exists', () {
    final draft = parser.parse('''
Información nutricional
Porción: 40 g
Por porción
Energía 160 kcal
Proteínas 4 g
Carbohidratos 28 g
Grasas 4 g
Azúcares 6 g
Sodio 120 mg
Fibra 2 g
''');

    expect(draft.detectedBasis, OcrNutritionBasis.perServing);
    expect(draft.normalizedFromServing, isTrue);
    expect(draft.perServingValues?.calories, 160);
    expect(draft.caloriesPer100, closeTo(400, 0.001));
    expect(draft.proteinPer100, closeTo(10, 0.001));
    expect(draft.carbsPer100, closeTo(70, 0.001));
    expect(draft.fatPer100, closeTo(10, 0.001));
  });

  test('missing or incomplete OCR data remains editable', () {
    final draft = parser.parse('''
Por 100 g
Energía 250 kcal
Proteínas 5 g
''');

    expect(draft.hasRequiredNutrition, isFalse);
    expect(draft.missingRequiredFields, contains('Carbohidratos'));
    expect(draft.missingRequiredFields, contains('Grasas'));
    expect(draft.reviewMessage, contains('incompletos'));
  });

  test('confirmed OCR product saved locally', () async {
    final (:store, :database) = await createMemoryStore();
    const draft = NutritionLabelOcrDraft(
      rawText: 'Por 100 g',
      name: 'Granola OCR',
      brand: 'Casa',
      servingSize: 50,
      servingUnit: 'g',
      caloriesPer100: 420,
      proteinPer100: 11,
      carbsPer100: 64,
      fatPer100: 12,
      fiberPer100: 8,
    );

    final product = await const OcrProductImportSaver().save(store, draft);

    expect(product.source, 'ocr');
    expect(product.barcode, isNull);
    expect(product.fiberPer100, 8);
    final rows = await database.select(database.productRows).get();
    expect(rows.single.source, 'ocr');
    expect(rows.single.syncStatus, 'pending');
  });

  test('confirmed Gemini label product saves gemini_label source', () async {
    final (:store, :database) = await createMemoryStore();
    const draft = NutritionLabelOcrDraft(
      rawText: 'Por 100 g',
      name: 'Yogur Gemini',
      caloriesPer100: 65,
      proteinPer100: 8.8,
      carbsPer100: 5.9,
      fatPer100: 0.7,
      source: 'gemini_label',
    );

    final product = await const OcrProductImportSaver().save(store, draft);

    expect(product.source, 'gemini_label');
    final productRows = await database.select(database.productRows).get();
    expect(productRows.single.source, 'gemini_label');
    final reportRows = await database.select(database.ocrScanReportRows).get();
    expect(reportRows.single.source, 'gemini_label');
  });

  test('OCR product macro calculation uses saved per-100 values', () async {
    final fixture = await createMemoryStore();
    final product = await const OcrProductImportSaver().save(
      fixture.store,
      const NutritionLabelOcrDraft(
        rawText: 'Por 100 g',
        name: 'Cereal OCR',
        caloriesPer100: 380,
        proteinPer100: 8,
        carbsPer100: 72,
        fatPer100: 6,
      ),
    );

    final macros = const MacroCalculator().calculateFromProduct(
      product: product,
      quantity: 50,
      unit: 'g',
    );

    expect(macros.calories, closeTo(190, 0.001));
    expect(macros.protein, closeTo(4, 0.001));
    expect(macros.carbs, closeTo(36, 0.001));
    expect(macros.fat, closeTo(3, 0.001));
  });

  testWidgets('Windows unsupported OCR behavior', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: OcrScanScreen(isScannerSupportedOverride: false)),
    );

    expect(
      find.text('Nutrition label OCR is not supported on this platform'),
      findsOneWidget,
    );
    expect(find.text('Create manually'), findsOneWidget);
  });
}
