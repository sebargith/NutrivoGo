import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/core/sync/record_sync_status.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/ocr/application/ocr_product_import_saver.dart';
import 'package:nutrivogo/features/ocr/domain/nutrition_label_ocr_draft.dart';
import 'package:nutrivogo/features/ocr_reports/application/ocr_report_exporter.dart';
import 'package:nutrivogo/features/ocr_reports/domain/ocr_image_saving_mode.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 4, 12);

  Future<({AppDatabase database, NutrivoGoStore store})>
  createMemoryStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    final store = NutrivoGoStore(database: database, clock: () => fixedNow);
    await store.ready;
    addTearDown(database.close);
    return (database: database, store: store);
  }

  const parsedDraft = NutritionLabelOcrDraft(
    rawText: 'INFORMACION NUTRICIONAL\nPor 100 g\nProteinas 8,8 g',
    name: 'Scanned yogurt',
    servingSize: 140,
    servingUnit: 'g',
    baseUnit: BaseUnit.grams,
    caloriesPer100: 65,
    proteinPer100: 8.8,
    carbsPer100: 5.9,
    fatPer100: 0.7,
    sugarPer100: 5.9,
    saturatedFatPer100: 0.4,
    sodiumPer100: 65,
    detectedBasis: OcrNutritionBasis.per100g,
    warnings: ['Values inferred from reconstructed OCR table.'],
    imagePathLocal: 'C:/temp/yogurt.jpg',
  );

  test('OCR report is created after OCR product save', () async {
    final (:store, :database) = await createMemoryStore();
    final correctedDraft = parsedDraft.copyWith(
      name: 'Corrected yogurt',
      caloriesPer100: 66,
      fatPer100: 0.8,
    );

    final product = await const OcrProductImportSaver().save(
      store,
      correctedDraft,
      parsedDraft: parsedDraft,
      wasParserCorrect: false,
      userFeedback: 'Fat needed correction.',
    );

    expect(product.name, 'Corrected yogurt');
    expect(store.ocrScanReports, hasLength(1));
    final report = store.ocrScanReports.single;
    expect(report.productId, product.id);
    expect(report.productName, 'Corrected yogurt');
    expect(report.rawOcrText, parsedDraft.rawText);
    expect(report.parsedMap['calories_per_100'], 65);
    expect(report.parsedMap['fat_per_100'], 0.7);
    expect(report.correctedMap?['calories_per_100'], 66);
    expect(report.correctedMap?['fat_per_100'], 0.8);
    expect(report.wasParserCorrect, isFalse);
    expect(report.userFeedback, 'Fat needed correction.');
    expect(report.syncStatus, RecordSyncStatus.pending);

    final rows = await database.select(database.ocrScanReportRows).get();
    expect(rows.single.rawOcrText, parsedDraft.rawText);
    expect(rows.single.correctedJson, isNotNull);
  });

  test('was_parser_correct true false and unsure values are saved', () async {
    final fixture = await createMemoryStore();
    final store = fixture.store;

    await store.addOcrScanReport(
      rawOcrText: 'correct',
      parsedJson: const {'name': 'A'},
      correctedJson: const {'name': 'A'},
      platform: 'android',
      wasParserCorrect: true,
    );
    await store.addOcrScanReport(
      rawOcrText: 'incorrect',
      parsedJson: const {'name': 'B'},
      correctedJson: const {'name': 'B fixed'},
      platform: 'android',
      wasParserCorrect: false,
    );
    await store.addOcrScanReport(
      rawOcrText: 'unsure',
      parsedJson: const {'name': 'C'},
      correctedJson: const {'name': 'C'},
      platform: 'android',
      wasParserCorrect: null,
    );

    expect(
      store.ocrScanReports.map((report) => report.wasParserCorrect).toSet(),
      {true, false, null},
    );
  });

  test('report remains pending when logged out', () async {
    final (:store, :database) = await createMemoryStore();

    await store.addOcrScanReport(
      rawOcrText: 'local only',
      parsedJson: const {'name': 'Local'},
      correctedJson: const {'name': 'Local'},
      platform: 'windows',
      wasParserCorrect: null,
    );

    final row =
        (await database.select(database.ocrScanReportRows).get()).single;
    expect(row.userId, isNull);
    expect(row.syncStatus, RecordSyncStatus.pending.storageValue);
  });

  test('OCR reports do not affect daily macro totals', () async {
    final fixture = await createMemoryStore();
    final store = fixture.store;

    await store.addOcrScanReport(
      rawOcrText: 'debug only',
      parsedJson: const {'name': 'Debug'},
      platform: 'android',
    );

    expect(store.dailyTotals.calories, 0);
    expect(store.dailyTotals.protein, 0);
    expect(store.logItems, isEmpty);
  });

  test('export JSON contains expected OCR report fields', () async {
    final fixture = await createMemoryStore();
    final store = fixture.store;
    await store.addOcrScanReport(
      rawOcrText: 'export me',
      parsedJson: const {'calories_per_100': 65},
      correctedJson: const {'calories_per_100': 66},
      detectedBasis: 'per_100g',
      parserWarnings: const ['warning'],
      platform: 'android',
      productName: 'Yogurt',
      imagePathLocal: 'C:/temp/yogurt.jpg',
      wasParserCorrect: false,
    );

    final export = const OcrReportExporter().exportJson(store.ocrScanReports);

    expect(export, contains('"raw_ocr_text": "export me"'));
    expect(export, contains('"parsed_json"'));
    expect(export, contains('"corrected_json"'));
    expect(export, contains('"was_parser_correct": false'));
    expect(export, contains('"detected_basis": "per_100g"'));
    expect(export, contains('"product_name": "Yogurt"'));
  });

  test('image setting Nunca does not store local image metadata', () async {
    final fixture = await createMemoryStore();
    final store = fixture.store;
    await store.setOcrImageSavingMode(OcrImageSavingMode.never);

    await store.addOcrScanReport(
      rawOcrText: 'image',
      parsedJson: const {'name': 'Image'},
      platform: 'android',
      imagePathLocal: 'C:/temp/image.jpg',
      wasParserCorrect: false,
    );

    expect(store.ocrScanReports.single.imagePathLocal, isNull);
  });

  test(
    'image setting incorrect only stores image for incorrect or unsure',
    () async {
      final fixture = await createMemoryStore();
      final store = fixture.store;
      await store.setOcrImageSavingMode(OcrImageSavingMode.incorrectOnly);

      await store.addOcrScanReport(
        rawOcrText: 'correct',
        parsedJson: const {'name': 'Correct'},
        platform: 'android',
        imagePathLocal: 'C:/temp/correct.jpg',
        wasParserCorrect: true,
      );
      await store.addOcrScanReport(
        rawOcrText: 'incorrect',
        parsedJson: const {'name': 'Incorrect'},
        platform: 'android',
        imagePathLocal: 'C:/temp/incorrect.jpg',
        wasParserCorrect: false,
      );
      await store.addOcrScanReport(
        rawOcrText: 'unsure',
        parsedJson: const {'name': 'Unsure'},
        platform: 'android',
        imagePathLocal: 'C:/temp/unsure.jpg',
        wasParserCorrect: null,
      );

      final byText = {
        for (final report in store.ocrScanReports) report.rawOcrText: report,
      };
      expect(byText['correct']?.imagePathLocal, isNull);
      expect(byText['incorrect']?.imagePathLocal, 'C:/temp/incorrect.jpg');
      expect(byText['unsure']?.imagePathLocal, 'C:/temp/unsure.jpg');
    },
  );

  test(
    'image setting Siempre stores local image metadata for all reports',
    () async {
      final fixture = await createMemoryStore();
      final store = fixture.store;
      await store.setOcrImageSavingMode(OcrImageSavingMode.always);

      await store.addOcrScanReport(
        rawOcrText: 'always',
        parsedJson: const {'name': 'Always'},
        platform: 'android',
        imagePathLocal: 'C:/temp/always.jpg',
        wasParserCorrect: true,
      );

      expect(store.ocrScanReports.single.imagePathLocal, 'C:/temp/always.jpg');
    },
  );
}
