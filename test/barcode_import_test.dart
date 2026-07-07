import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/barcode/application/open_food_facts_client.dart';
import 'package:nutrivogo/features/barcode/application/product_import_saver.dart';
import 'package:nutrivogo/features/barcode/domain/product_import_draft.dart';
import 'package:nutrivogo/features/barcode/presentation/barcode_scan_screen.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/macro_calculator.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  final fixedNow = DateTime(2026, 7, 1, 12);

  Future<({AppDatabase database, NutrivoGoStore store})>
  createMemoryStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database, clock: () => fixedNow);
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  test('local barcode match finds saved product', () async {
    final (:store, :database) = await createMemoryStore();
    await store.addProduct(
      name: 'Leche',
      baseUnit: BaseUnit.milliliters,
      caloriesPer100: 42,
      proteinPer100: 3.4,
      carbsPer100: 5,
      fatPer100: 1,
      barcode: '7801234567890',
      source: 'barcode',
    );

    final match = store.findProductByBarcode(' 7801234567890 ');

    expect(match, isNotNull);
    expect(match!.name, 'Leche');
    final rows = await database.select(database.productRows).get();
    expect(rows.single.barcode, '7801234567890');
  });

  test('Open Food Facts found product parsing', () {
    final result = OpenFoodFactsParser.parse({
      'status': 1,
      'code': '7801234567890',
      'product': {
        'code': '7801234567890',
        'product_name_es': 'Yogur natural',
        'brands': 'Marca Chile',
        'serving_size': '125 g',
        'nutriments': {
          'energy-kcal_100g': 70,
          'proteins_100g': 4.5,
          'carbohydrates_100g': 9,
          'fat_100g': 2,
          'sugars_100g': 8,
          'saturated-fat_100g': 1.2,
          'sodium_100g': 0.05,
          'fiber_100g': 0.3,
        },
      },
    }, fallbackBarcode: '7801234567890');

    expect(result.status, ProductLookupStatus.found);
    expect(result.draft!.name, 'Yogur natural');
    expect(result.draft!.brand, 'Marca Chile');
    expect(result.draft!.servingSize, 125);
    expect(result.draft!.baseUnit, BaseUnit.grams);
    expect(result.draft!.caloriesPer100, 70);
    expect(result.draft!.sugarPer100, 8);
    expect(result.draft!.saturatedFatPer100, 1.2);
    expect(result.draft!.sodiumPer100, 0.05);
    expect(result.draft!.fiberPer100, 0.3);
  });

  test('Open Food Facts serving text stores grams for one portion', () async {
    final result = OpenFoodFactsParser.parse({
      'status': 1,
      'code': '7804444444444',
      'product': {
        'code': '7804444444444',
        'product_name_es': 'Postre porcion',
        'serving_size': '1 porcion (140 g)',
        'nutriments': {
          'energy-kcal_100g': 200,
          'proteins_100g': 8,
          'carbohydrates_100g': 20,
          'fat_100g': 6,
        },
      },
    }, fallbackBarcode: '7804444444444');

    expect(result.status, ProductLookupStatus.found);
    expect(result.draft!.servingSize, 140);
    expect(result.draft!.servingUnit, 'g');

    final fixture = await createMemoryStore();
    final product = await const ProductImportSaver().save(
      fixture.store,
      result.draft!,
    );

    final macros = const MacroCalculator().calculateFromProduct(
      product: product,
      quantity: 1,
      unit: 'serving',
    );

    expect(macros.calories, closeTo(280, 0.001));
    expect(macros.protein, closeTo(11.2, 0.001));
    expect(macros.carbs, closeTo(28, 0.001));
    expect(macros.fat, closeTo(8.4, 0.001));
  });

  test('Open Food Facts serving text without g or ml is not saved as 1g', () {
    final result = OpenFoodFactsParser.parse({
      'status': 1,
      'code': '7805555555555',
      'product': {
        'code': '7805555555555',
        'product_name_es': 'Producto sin gramos',
        'serving_size': '1 porcion',
        'nutriments': {
          'energy-kcal_100g': 200,
          'proteins_100g': 8,
          'carbohydrates_100g': 20,
          'fat_100g': 6,
        },
      },
    }, fallbackBarcode: '7805555555555');

    expect(result.status, ProductLookupStatus.found);
    expect(result.draft!.servingSize, isNull);
    expect(result.draft!.servingUnit, isNull);
  });

  test('Open Food Facts missing product fallback', () {
    final result = OpenFoodFactsParser.parse({
      'status': 0,
    }, fallbackBarcode: '0000000000000');

    expect(result.status, ProductLookupStatus.notFound);
    expect(result.draft, isNull);
    expect(result.barcode, '0000000000000');
  });

  test('incomplete nutrition data is editable import draft', () {
    final result = OpenFoodFactsParser.parse({
      'status': 1,
      'product': {
        'code': '7801111111111',
        'product_name': 'Snack incompleto',
        'nutriments': {'energy-kcal_100g': 120, 'proteins_100g': 3},
      },
    }, fallbackBarcode: '7801111111111');

    expect(result.status, ProductLookupStatus.incomplete);
    expect(result.draft, isNotNull);
    expect(result.draft!.carbsPer100, isNull);
    expect(result.draft!.fatPer100, isNull);
    expect(result.message, contains('incomplete'));
  });

  test('confirmed imported product saved locally', () async {
    final (:store, :database) = await createMemoryStore();
    final draft = ProductImportDraft(
      barcode: '7802222222222',
      name: 'Avena',
      brand: 'Sur',
      servingSize: 40,
      servingUnit: 'g',
      caloriesPer100: 380,
      proteinPer100: 13,
      carbsPer100: 62,
      fatPer100: 7,
      fiberPer100: 10,
    );

    final product = await const ProductImportSaver().save(store, draft);

    expect(product.barcode, '7802222222222');
    expect(product.source, 'barcode');
    expect(product.fiberPer100, 10);
    final rows = await database.select(database.productRows).get();
    expect(rows.single.barcode, '7802222222222');
    expect(rows.single.source, 'barcode');
  });

  test('confirmed Gemini product saved locally without barcode', () async {
    final (:store, :database) = await createMemoryStore();
    final product = await const ProductImportSaver().save(
      store,
      const ProductImportDraft(
        barcode: '',
        name: 'Plátano Gemini',
        caloriesPer100: 89,
        proteinPer100: 1.1,
        carbsPer100: 22.8,
        fatPer100: 0.3,
        source: 'gemini_generic',
      ),
    );

    expect(product.barcode, isNull);
    expect(product.source, 'gemini_generic');
    final rows = await database.select(database.productRows).get();
    expect(rows.single.barcode, isNull);
    expect(rows.single.source, 'gemini_generic');
  });

  test('imported product macro calculation uses core macros', () async {
    final fixture = await createMemoryStore();
    final product = await const ProductImportSaver().save(
      fixture.store,
      const ProductImportDraft(
        barcode: '7803333333333',
        name: 'Cereal',
        caloriesPer100: 400,
        proteinPer100: 10,
        carbsPer100: 70,
        fatPer100: 8,
      ),
    );

    final macros = const MacroCalculator().calculateFromProduct(
      product: product,
      quantity: 50,
      unit: 'g',
    );

    expect(macros.calories, closeTo(200, 0.001));
    expect(macros.protein, closeTo(5, 0.001));
    expect(macros.carbs, closeTo(35, 0.001));
    expect(macros.fat, closeTo(4, 0.001));
  });

  testWidgets('Windows unsupported scanner behavior', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BarcodeScanScreen(isScannerSupportedOverride: false),
      ),
    );

    expect(
      find.text('Escáner no soportado en esta plataforma'),
      findsOneWidget,
    );
    expect(find.text('Buscar código'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
