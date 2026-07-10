import '../../food_log/application/nutrivo_go_store.dart';
import '../../products/domain/product.dart';
import '../domain/product_import_draft.dart';

class ProductImportSaver {
  const ProductImportSaver();

  Future<Product> save(NutrivoGoStore store, ProductImportDraft draft) {
    if (!draft.hasRequiredNutrition) {
      throw ArgumentError('Imported product is missing required nutrition.');
    }
    return store.addProduct(
      name: draft.name,
      brand: draft.brand,
      servingSize: draft.servingSize,
      servingUnit: draft.servingUnit,
      baseUnit: draft.baseUnit,
      caloriesPer100: draft.caloriesPer100!,
      proteinPer100: draft.proteinPer100!,
      carbsPer100: draft.carbsPer100!,
      fatPer100: draft.fatPer100!,
      barcode: draft.barcode,
      source: draft.source,
      sugarPer100: draft.sugarPer100,
      saturatedFatPer100: draft.saturatedFatPer100,
      sodiumPer100: draft.sodiumPer100,
      fiberPer100: draft.fiberPer100,
      packagePriceClp: draft.packagePriceClp,
      packageQuantity: draft.packageQuantity,
      packageQuantityUnit: draft.packageQuantityUnit,
      unitsPerServing: draft.unitsPerServing,
      servingsPerPackage: draft.servingsPerPackage,
    );
  }
}
