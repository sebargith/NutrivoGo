import 'package:flutter/foundation.dart';

import '../../../shared/app_info.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../products/domain/product.dart';
import '../domain/nutrition_label_ocr_draft.dart';

class OcrProductImportSaver {
  const OcrProductImportSaver();

  Future<Product> save(
    NutrivoGoStore store,
    NutritionLabelOcrDraft draft, {
    NutritionLabelOcrDraft? parsedDraft,
    bool? wasParserCorrect,
    String? userFeedback,
  }) async {
    if (!draft.hasRequiredNutrition) {
      throw ArgumentError('OCR product is missing required nutrition.');
    }
    final product = await store.addProduct(
      name: draft.name,
      brand: draft.brand,
      servingSize: draft.servingSize,
      servingUnit: draft.servingUnit,
      baseUnit: draft.baseUnit,
      caloriesPer100: draft.caloriesPer100!,
      proteinPer100: draft.proteinPer100!,
      carbsPer100: draft.carbsPer100!,
      fatPer100: draft.fatPer100!,
      source: 'ocr',
      sugarPer100: draft.sugarPer100,
      saturatedFatPer100: draft.saturatedFatPer100,
      sodiumPer100: draft.sodiumPer100,
      fiberPer100: draft.fiberPer100,
      packagePriceClp: draft.packagePriceClp,
      packageQuantity: draft.packageQuantity,
      packageQuantityUnit: draft.packageQuantityUnit,
    );
    final originalDraft = parsedDraft ?? draft;
    await store.addOcrScanReport(
      rawOcrText: originalDraft.rawText,
      parsedJson: originalDraft.toReportJson(),
      correctedJson: draft.toReportJson(),
      detectedBasis: originalDraft.basisStorageValue,
      parserWarnings: originalDraft.warnings,
      parserConfidence: originalDraft.parserConfidence,
      wasParserCorrect: wasParserCorrect,
      userFeedback: userFeedback,
      productId: product.id,
      productName: product.name,
      barcode: product.barcode,
      source: 'ocr',
      platform: defaultTargetPlatform.name,
      appVersion: AppInfo.version,
      imagePathLocal: originalDraft.imagePathLocal,
    );
    return product;
  }
}
