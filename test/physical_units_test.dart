import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/food_cost_calculator.dart';
import 'package:nutrivogo/features/food_log/domain/macro_calculator.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/food_log/presentation/quantity_display.dart';
import 'package:nutrivogo/features/gemini/domain/gemini_product_analysis.dart';
import 'package:nutrivogo/features/ocr/application/nutrition_label_ocr_parser.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 10, 12);
  const macroCalculator = MacroCalculator();
  const costCalculator = FoodCostCalculator();

  Product packagedProduct() {
    return Product(
      id: 'yogurt-pack',
      name: 'Yogur',
      baseUnit: BaseUnit.grams,
      servingSize: 100,
      servingUnit: 'g',
      unitsPerServing: 6,
      servingsPerPackage: 4.5,
      packagePriceClp: 2000,
      caloriesPer100: 200,
      proteinPer100: 8,
      carbsPer100: 20,
      fatPer100: 4,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  test('derives physical unit and package quantities', () {
    final product = packagedProduct();

    expect(product.baseQuantityPerUnit, closeTo(100 / 6, 0.00001));
    expect(product.estimatedPackageQuantity, 450);
    expect(product.totalUnitsPerPackage, 27);
    expect(product.effectivePackageQuantity, 450);
    expect(costCalculator.costPerServing(product), closeTo(2000 / 4.5, 0.001));
    expect(costCalculator.costPerUnit(product), closeTo(2000 / 27, 0.001));
  });

  test('units, servings, and grams produce equivalent macros and cost', () {
    final product = packagedProduct();

    final grams = macroCalculator.calculateFromProduct(
      product: product,
      quantity: 50,
      unit: 'g',
    );
    final units = macroCalculator.calculateFromProduct(
      product: product,
      quantity: 3,
      unit: 'unit',
    );
    final halfServing = macroCalculator.calculateFromProduct(
      product: product,
      quantity: 0.5,
      unit: 'serving',
    );

    expect(units.calories, closeTo(grams.calories, 0.0001));
    expect(halfServing.calories, closeTo(grams.calories, 0.0001));
    expect(
      costCalculator.calculateLogCost(
        product: product,
        quantity: 3,
        unit: 'unit',
      ),
      closeTo(
        costCalculator.calculateLogCost(
          product: product,
          quantity: 50,
          unit: 'g',
        )!,
        0.0001,
      ),
    );
  });

  test('unit labels and log display preserve entered and base quantities', () {
    expect(quantityUnitLabel('unit'), 'unidad(es)');
    expect(quantityHelperText('unit'), 'Ingresa cuántas unidades comiste.');
    expect(
      loggedQuantityDisplay(
        quantity: 3,
        unit: 'unit',
        baseQuantity: 50,
        baseUnit: 'g',
        useSpanishDecimals: true,
      ),
      '3 unidades · 50 g',
    );
  });

  test('saves and reloads a unit-based log with snapshots', () async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database, clock: () => fixedNow);
    await store.ready;
    addTearDown(database.close);

    final product = await store.addProduct(
      name: 'Yogur',
      baseUnit: BaseUnit.grams,
      servingSize: 100,
      servingUnit: 'g',
      unitsPerServing: 6,
      servingsPerPackage: 4.5,
      packagePriceClp: 2000,
      caloriesPer100: 200,
      proteinPer100: 8,
      carbsPer100: 20,
      fatPer100: 4,
    );
    final item = await store.addLogItem(
      product: product,
      quantity: 3,
      unit: 'unit',
      mealType: MealType.snack,
    );

    expect(item.quantity, 3);
    expect(item.unit, 'unit');
    expect(item.baseQuantitySnapshot, closeTo(50, 0.0001));
    expect(item.unitsPerServingSnapshot, 6);
    expect(item.macros.calories, 100);
    final row = (await database.select(database.logItemRows).get()).single;
    expect(row.unit, 'unit');
    expect(row.baseQuantitySnapshot, closeTo(50, 0.0001));
  });

  test('parses Chilean unit and package serving fields', () {
    const rawText = '''
INFORMACION NUTRICIONAL
Porción: 6 unidades (100 g)
Porciones por envase: 4,5
Energía (kcal)
Proteínas (g)
Grasa total (g)
Carbohidratos (g)
100 g
200
8
4
20
''';

    final draft = const NutritionLabelOcrParser().parse(rawText);

    expect(draft.servingSize, 100);
    expect(draft.servingUnit, 'g');
    expect(draft.unitsPerServing, 6);
    expect(draft.servingsPerPackage, 4.5);
    expect(draft.caloriesPer100, 200);
    expect(draft.proteinPer100, 8);
    expect(draft.fatPer100, 4);
  });

  test('reconstructs the real Chilean yogurt OCR columns', () {
    const rawText = '''
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
65
8,8
0,7
0,4
0,2
0
0
5,1
5,9
5,9
0
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
''';

    final draft = const NutritionLabelOcrParser().parse(rawText);

    expect(draft.servingSize, 140);
    expect(draft.servingUnit, 'g');
    expect(draft.servingsPerPackage, 1);
    expect(draft.caloriesPer100, 65);
    expect(draft.proteinPer100, 8.8);
    expect(draft.fatPer100, 0.7);
    expect(draft.saturatedFatPer100, 0.4);
    expect(draft.carbsPer100, 5.9);
    expect(draft.sugarPer100, 5.9);
    expect(draft.sodiumPer100, 65);
    expect(draft.perServingValues?.calories, 91);
    expect(draft.perServingValues?.protein, 12.3);
    expect(draft.perServingValues?.fat, 1);
    expect(draft.perServingValues?.saturatedFat, 0.6);
    expect(draft.perServingValues?.carbs, 8.3);
    expect(draft.perServingValues?.sugar, 8.3);
    expect(draft.perServingValues?.sodium, 91);
    expect(draft.warnings, isNotEmpty);
  });

  test('does not interpret OCR nutrition units as physical unit counts', () {
    const rawText = '''
INFORMACION NUTRICIONAL
Porción: 6 unidades
Proteínas (9)
Grasa total (g)
Grasa poliinsat. (9)
Azúcares totales (a)
''';

    final draft = const NutritionLabelOcrParser().parse(rawText);

    expect(draft.unitsPerServing, 6);
    expect(draft.unitsPerServing, isNot(9));
  });

  test('maps Gemini physical unit fields into an editable draft', () {
    final analysis = GeminiProductAnalysis.fromJson({
      'status': 'ok',
      'source_mode': 'generic_food',
      'confidence': 'medium',
      'warnings': <String>[],
      'assumptions': <String>[],
      'explanation': 'Estimación',
      'product': {
        'name': 'Huevo',
        'base_unit': 'g',
        'basis': 'per_100g',
        'serving_size': 50,
        'serving_unit': 'g',
        'units_per_serving': 1,
        'servings_per_package': null,
        'calories_per_100': 143,
        'protein_per_100': 12.6,
        'carbs_per_100': 0.7,
        'fat_per_100': 9.5,
      },
    });

    expect(analysis.draft?.unitsPerServing, 1);
    expect(analysis.draft?.servingsPerPackage, isNull);
    expect(analysis.draft?.proteinPer100, 12.6);
  });
}
