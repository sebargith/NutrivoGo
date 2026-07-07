import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/barcode/domain/product_import_draft.dart';
import 'package:nutrivogo/features/barcode/presentation/product_import_confirmation_screen.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/gemini/application/gemini_product_client.dart';
import 'package:nutrivogo/features/gemini/domain/gemini_product_analysis.dart';
import 'package:nutrivogo/features/gemini/presentation/gemini_generic_product_screen.dart';
import 'package:nutrivogo/features/ocr/domain/nutrition_label_ocr_draft.dart';
import 'package:nutrivogo/features/ocr/presentation/ocr_product_confirmation_screen.dart';

void main() {
  Future<({AppDatabase database, NutrivoGoStore store})>
  createMemoryStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database);
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  testWidgets('generic Gemini screen shows Spanish labels and errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GeminiGenericProductScreen(
          client: _FakeGeminiProductClient(
            exception: const GeminiProductException(
              'No se pudo analizar con Gemini',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Agregar con Gemini'), findsOneWidget);
    expect(find.text('Describe el alimento'), findsOneWidget);
    expect(find.text('Ejemplo: plátano, huevo, arroz cocido'), findsOneWidget);
    expect(
      find.text('Gemini puede equivocarse. Revisa antes de guardar.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'plátano');
    await tester.tap(find.text('Generar producto'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo analizar con Gemini'), findsOneWidget);
  });

  testWidgets('confirmation screen displays Gemini review metadata', (
    tester,
  ) async {
    final fixture = await createMemoryStore();

    await tester.pumpWidget(
      MaterialApp(
        home: ProductImportConfirmationScreen(
          store: fixture.store,
          draft: const ProductImportDraft(
            barcode: '',
            name: 'Plátano',
            caloriesPer100: 89,
            proteinPer100: 1.1,
            carbsPer100: 22.8,
            fatPer100: 0.3,
            source: 'gemini_generic',
          ),
          sourceLabel: 'Gemini alimento genérico',
          confidence: 'medium',
          warnings: const ['Valores aproximados'],
          assumptions: const ['Alimento crudo común'],
          explanation: 'Valores aproximados por 100 g.',
        ),
      ),
    );

    expect(find.text('Gemini alimento genérico'), findsOneWidget);
    expect(
      find.text('Gemini puede equivocarse. Revisa antes de guardar.'),
      findsOneWidget,
    );
    expect(find.text('Confianza: medium'), findsOneWidget);
    expect(find.text('Advertencias'), findsOneWidget);
    expect(find.text('Supuestos'), findsOneWidget);
  });

  testWidgets('failed label Gemini analysis keeps existing OCR fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await createMemoryStore();
    await tester.pumpWidget(
      MaterialApp(
        home: OcrProductConfirmationScreen(
          store: fixture.store,
          geminiClient: _FakeGeminiProductClient(
            exception: const GeminiProductException(
              'No se pudo analizar con Gemini',
            ),
          ),
          draft: const NutritionLabelOcrDraft(
            rawText: 'Por 100 g',
            name: 'Producto OCR',
            servingSize: 140,
            servingUnit: 'g',
            caloriesPer100: 65,
            proteinPer100: 8.8,
            carbsPer100: 5.9,
            fatPer100: 0.7,
            imagePathLocal: 'label.jpg',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Analizar con Gemini'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo analizar con Gemini'), findsOneWidget);
    expect(_textFieldValue(tester, 'Nombre del producto'), 'Producto OCR');
    expect(_textFieldValue(tester, 'Energía / Calorías (kcal)'), '65');
    expect(_textFieldValue(tester, 'Proteínas (g)'), '8.8');
    expect(_textFieldValue(tester, 'Carbohidratos (g)'), '5.9');
    expect(_textFieldValue(tester, 'Grasas (g)'), '0.7');
  });
}

String _textFieldValue(WidgetTester tester, String label) {
  final fieldFinder = find.ancestor(
    of: find.text(label),
    matching: find.byType(TextFormField),
  );
  expect(fieldFinder, findsOneWidget);
  final field = tester.widget<TextFormField>(fieldFinder);
  return field.controller?.text ?? '';
}

class _FakeGeminiProductClient implements GeminiProductClient {
  const _FakeGeminiProductClient({this.exception});

  final GeminiProductException? exception;

  @override
  Future<GeminiProductAnalysis> analyzeGenericFood({
    required String query,
    String locale = 'Chile',
    String? baseUnitPreference,
  }) async {
    final error = exception;
    if (error != null) {
      throw error;
    }
    return _defaultAnalysis;
  }

  @override
  Future<GeminiProductAnalysis> analyzeNutritionLabelImage({
    required String imagePath,
    String? rawOcrText,
    String? hint,
  }) async {
    final error = exception;
    if (error != null) {
      throw error;
    }
    return _defaultAnalysis;
  }

  static final _defaultAnalysis = GeminiProductAnalysis.fromJson({
    'status': 'ok',
    'source_mode': 'generic_food',
    'product': {
      'name': 'Plátano',
      'basis': 'per_100g',
      'calories_kcal': 89,
      'protein_g': 1.1,
      'carbs_g': 22.8,
      'fat_g': 0.3,
    },
    'confidence': 'medium',
    'warnings': <String>[],
    'assumptions': <String>[],
    'explanation': '',
  });
}
