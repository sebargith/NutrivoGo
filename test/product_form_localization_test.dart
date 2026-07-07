import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/barcode/domain/product_import_draft.dart';
import 'package:nutrivogo/features/barcode/presentation/product_import_confirmation_screen.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/ocr/domain/nutrition_label_ocr_draft.dart';
import 'package:nutrivogo/features/ocr/presentation/ocr_product_confirmation_screen.dart';
import 'package:nutrivogo/features/products/presentation/create_product_screen.dart';

void main() {
  Future<({AppDatabase database, NutrivoGoStore store})>
  createMemoryStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database);
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  Future<void> enterTextInField(
    WidgetTester tester,
    String label,
    String value,
  ) async {
    final field = find.ancestor(
      of: find.text(label),
      matching: find.byType(TextFormField),
    );
    expect(field, findsOneWidget);
    await tester.enterText(field, value);
  }

  testWidgets('product form shows serving size in g and nutrient units', (
    tester,
  ) async {
    final fixture = await createMemoryStore();

    await tester.pumpWidget(
      MaterialApp(home: CreateProductScreen(store: fixture.store)),
    );

    expect(find.text('Crear producto'), findsOneWidget);
    expect(find.text('Nombre del producto'), findsOneWidget);
    expect(find.text('Marca'), findsOneWidget);
    expect(find.text('Código de barras'), findsOneWidget);
    expect(find.text('Unidad base'), findsOneWidget);
    expect(find.text('Tamaño de la porción (g)'), findsOneWidget);
    expect(find.text('Serving unit'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Energía / Calorías (kcal)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Energía / Calorías (kcal)'), findsOneWidget);
    expect(find.text('Proteínas (g)'), findsOneWidget);
    expect(find.text('Carbohidratos (g)'), findsOneWidget);
    expect(find.text('Grasas (g)'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sodio (mg)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Azúcares (g)'), findsOneWidget);
    expect(find.text('Grasas saturadas (g)'), findsOneWidget);
    expect(find.text('Sodio (mg)'), findsOneWidget);
    expect(find.text('Fibra (g)'), findsOneWidget);
  });

  testWidgets('product form serving label switches to ml', (tester) async {
    final fixture = await createMemoryStore();

    await tester.pumpWidget(
      MaterialApp(home: CreateProductScreen(store: fixture.store)),
    );

    await tester.tap(find.text('ml'));
    await tester.pumpAndSettle();

    expect(find.text('Tamaño de la porción (ml)'), findsOneWidget);
    expect(find.text('Serving unit'), findsNothing);
  });

  testWidgets('saving product stores inferred serving unit', (tester) async {
    final fixture = await createMemoryStore();

    await tester.pumpWidget(
      MaterialApp(home: CreateProductScreen(store: fixture.store)),
    );

    await enterTextInField(tester, 'Nombre del producto', 'Jugo');
    await tester.tap(find.text('ml'));
    await tester.pumpAndSettle();
    await enterTextInField(tester, 'Tamaño de la porción (ml)', '200');

    await tester.scrollUntilVisible(
      find.text('Energía / Calorías (kcal)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await enterTextInField(tester, 'Energía / Calorías (kcal)', '50');
    await enterTextInField(tester, 'Proteínas (g)', '1');
    await enterTextInField(tester, 'Carbohidratos (g)', '12');
    await enterTextInField(tester, 'Grasas (g)', '0');

    await tester.scrollUntilVisible(
      find.text('Guardar producto'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar producto'));
    await tester.pumpAndSettle();

    final row =
        (await fixture.database.select(fixture.database.productRows).get())
            .single;
    expect(row.servingSize, 200);
    expect(row.servingUnit, 'ml');
  });

  testWidgets('barcode confirmation screen uses Spanish product labels', (
    tester,
  ) async {
    final fixture = await createMemoryStore();

    await tester.pumpWidget(
      MaterialApp(
        home: ProductImportConfirmationScreen(
          store: fixture.store,
          draft: const ProductImportDraft(
            barcode: '7800000000000',
            name: 'Yogur',
            servingSize: 140,
            servingUnit: 'g',
            caloriesPer100: 65,
            proteinPer100: 8.8,
            carbsPer100: 5.9,
            fatPer100: 0.7,
          ),
        ),
      ),
    );

    expect(find.text('Confirmar producto'), findsOneWidget);
    expect(find.text('Nombre del producto'), findsOneWidget);
    expect(find.text('Tamaño de la porción (g)'), findsOneWidget);
    expect(find.text('Serving unit'), findsNothing);
  });

  testWidgets('OCR confirmation screen uses Spanish product labels', (
    tester,
  ) async {
    final fixture = await createMemoryStore();

    await tester.pumpWidget(
      MaterialApp(
        home: OcrProductConfirmationScreen(
          store: fixture.store,
          draft: const NutritionLabelOcrDraft(
            rawText: 'Por 100 g',
            name: 'Producto OCR',
            servingSize: 140,
            servingUnit: 'g',
            caloriesPer100: 65,
            proteinPer100: 8.8,
            carbsPer100: 5.9,
            fatPer100: 0.7,
          ),
        ),
      ),
    );

    expect(find.text('Confirmar producto OCR'), findsOneWidget);
    expect(find.text('Nombre del producto'), findsOneWidget);
    expect(find.text('Tamaño de la porción (g)'), findsOneWidget);
    expect(find.text('Serving unit'), findsNothing);
  });
}
