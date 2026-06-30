import 'package:flutter/foundation.dart';

import '../../products/domain/product.dart';
import '../domain/log_item.dart';
import '../domain/macro_calculator.dart';
import '../domain/macro_snapshot.dart';
import '../domain/meal_type.dart';

class NutrivoGoStore extends ChangeNotifier {
  NutrivoGoStore({MacroCalculator? calculator})
    : _calculator = calculator ?? const MacroCalculator();

  final MacroCalculator _calculator;
  final List<Product> _products = <Product>[];
  final List<LogItem> _logItems = <LogItem>[];

  List<Product> get products => List.unmodifiable(_products);

  List<LogItem> get logItems => List.unmodifiable(_logItems);

  MacroSnapshot get dailyTotals {
    return _logItems.fold(
      const MacroSnapshot.zero(),
      (total, item) => total + item.macros,
    );
  }

  List<LogItem> itemsForMeal(MealType mealType) {
    return _logItems
        .where((item) => item.mealType == mealType)
        .toList(growable: false);
  }

  Product addProduct({
    required String name,
    required BaseUnit baseUnit,
    required double caloriesPer100,
    required double proteinPer100,
    required double carbsPer100,
    required double fatPer100,
    String? brand,
    double? servingSize,
    String? servingUnit,
  }) {
    final product = Product(
      id: _makeId('product'),
      name: name.trim(),
      brand: _emptyToNull(brand),
      servingSize: servingSize,
      servingUnit: _emptyToNull(servingUnit),
      baseUnit: baseUnit,
      caloriesPer100: caloriesPer100,
      proteinPer100: proteinPer100,
      carbsPer100: carbsPer100,
      fatPer100: fatPer100,
    );
    _products.add(product);
    _products.sort(
      (left, right) => left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      ),
    );
    notifyListeners();
    return product;
  }

  LogItem addLogItem({
    required Product product,
    required double quantity,
    required String unit,
    required MealType mealType,
  }) {
    final macros = _calculator.calculateFromProduct(
      product: product,
      quantity: quantity,
      unit: unit,
    );
    final item = LogItem(
      id: _makeId('log'),
      product: product,
      quantity: quantity,
      unit: unit,
      mealType: mealType,
      macros: macros,
      createdAt: DateTime.now(),
    );
    _logItems.add(item);
    notifyListeners();
    return item;
  }

  void removeLogItem(String id) {
    _logItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  String _makeId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
