import '../../products/domain/product.dart';
import 'macro_calculator.dart';

class FoodCostCalculator {
  const FoodCostCalculator();

  static const _macroCalculator = MacroCalculator();

  double? costPerBaseUnit(Product product) {
    return costPerBaseUnitFromPackage(
      packagePriceClp: product.packagePriceClp,
      packageQuantity: product.packageQuantity,
    );
  }

  double? costPer100(Product product) {
    final perBaseUnit = costPerBaseUnit(product);
    if (perBaseUnit == null) {
      return null;
    }
    return perBaseUnit * 100;
  }

  double? costPerServing(Product product) {
    final perBaseUnit = costPerBaseUnit(product);
    final servingSize = product.servingSize;
    if (perBaseUnit == null || servingSize == null || servingSize <= 0) {
      return null;
    }
    return perBaseUnit * servingSize;
  }

  double? calculateLogCost({
    required Product product,
    required double quantity,
    required String unit,
  }) {
    final perBaseUnit = costPerBaseUnit(product);
    if (perBaseUnit == null) {
      return null;
    }
    final baseQuantity = _macroCalculator.quantityInBaseUnit(
      product: product,
      quantity: quantity,
      unit: unit,
    );
    return perBaseUnit * baseQuantity;
  }

  double? costPerBaseUnitFromPackage({
    required double? packagePriceClp,
    required double? packageQuantity,
  }) {
    if (packagePriceClp == null ||
        packageQuantity == null ||
        packagePriceClp <= 0 ||
        packageQuantity <= 0) {
      return null;
    }
    return packagePriceClp / packageQuantity;
  }

  double? costPer100FromPackage({
    required double? packagePriceClp,
    required double? packageQuantity,
  }) {
    final perBaseUnit = costPerBaseUnitFromPackage(
      packagePriceClp: packagePriceClp,
      packageQuantity: packageQuantity,
    );
    if (perBaseUnit == null) {
      return null;
    }
    return perBaseUnit * 100;
  }

  double? costPerServingFromPackage({
    required double? packagePriceClp,
    required double? packageQuantity,
    required double? servingSize,
  }) {
    final perBaseUnit = costPerBaseUnitFromPackage(
      packagePriceClp: packagePriceClp,
      packageQuantity: packageQuantity,
    );
    if (perBaseUnit == null || servingSize == null || servingSize <= 0) {
      return null;
    }
    return perBaseUnit * servingSize;
  }
}
