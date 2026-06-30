import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../products/domain/product.dart';
import '../domain/log_item.dart';
import '../domain/macro_calculator.dart';
import '../domain/macro_snapshot.dart';
import '../domain/meal_type.dart';

class NutrivoGoStore extends ChangeNotifier {
  NutrivoGoStore({
    AppDatabase? database,
    MacroCalculator? calculator,
    DateTime Function()? clock,
  }) : _database = database ?? AppDatabase(),
       _ownsDatabase = database == null,
       _calculator = calculator ?? const MacroCalculator(),
       _clock = clock ?? DateTime.now {
    ready = load();
  }

  final AppDatabase _database;
  final bool _ownsDatabase;
  final MacroCalculator _calculator;
  final DateTime Function() _clock;
  final List<Product> _products = <Product>[];
  final List<LogItem> _logItems = <LogItem>[];
  int _idCounter = 0;

  late final Future<void> ready;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  List<Product> get products => List.unmodifiable(_products);

  List<LogItem> get logItems => List.unmodifiable(_logItems);

  List<Product> get recentProducts {
    final activeProductIds = _products.map((product) => product.id).toSet();
    final seenProductIds = <String>{};
    final recent = <Product>[];

    for (final item in _logItems.reversed) {
      final product = item.product;
      if (!activeProductIds.contains(product.id) ||
          !seenProductIds.add(product.id)) {
        continue;
      }
      recent.add(product);
      if (recent.length == 5) {
        break;
      }
    }

    return List.unmodifiable(recent);
  }

  List<LogItem> get todaysLogItems {
    return _logItems
        .where((item) => _isSameDay(item.createdAt, _clock()))
        .toList(growable: false);
  }

  MacroSnapshot get dailyTotals {
    return todaysLogItems.fold(
      const MacroSnapshot.zero(),
      (total, item) => total + item.macros,
    );
  }

  List<LogItem> itemsForMeal(MealType mealType) {
    return todaysLogItems
        .where((item) => item.mealType == mealType)
        .toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    final productRows = await _database.select(_database.productRows).get();
    final productsById = {
      for (final row in productRows) row.id: _productFromRow(row),
    };

    final activeProducts =
        productRows
            .where((row) => row.deletedAt == null)
            .map(_productFromRow)
            .toList()
          ..sort(_compareProducts);

    final logRows = await (_database.select(
      _database.logItemRows,
    )..where((row) => row.deletedAt.isNull())).get();
    final activeLogItems = <LogItem>[
      for (final row in logRows)
        if (productsById[row.productId] != null)
          _logItemFromRow(row, productsById[row.productId]!),
    ]..sort((left, right) => left.createdAt.compareTo(right.createdAt));

    _products
      ..clear()
      ..addAll(activeProducts);
    _logItems
      ..clear()
      ..addAll(activeLogItems);
    _isLoading = false;
    notifyListeners();
  }

  Future<Product> addProduct({
    required String name,
    required BaseUnit baseUnit,
    required double caloriesPer100,
    required double proteinPer100,
    required double carbsPer100,
    required double fatPer100,
    String? brand,
    double? servingSize,
    String? servingUnit,
  }) async {
    final now = _clock();
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
      createdAt: now,
      updatedAt: now,
    );

    await _database
        .into(_database.productRows)
        .insert(_productToCompanion(product));
    _upsertProduct(product);
    notifyListeners();
    return product;
  }

  Future<Product> updateProduct(
    Product product, {
    String? name,
    String? brand,
    double? servingSize,
    String? servingUnit,
    bool clearServingSize = false,
    BaseUnit? baseUnit,
    double? caloriesPer100,
    double? proteinPer100,
    double? carbsPer100,
    double? fatPer100,
  }) async {
    final updated = Product(
      id: product.id,
      name: name?.trim() ?? product.name,
      brand: brand == null ? product.brand : _emptyToNull(brand),
      servingSize: clearServingSize ? null : servingSize ?? product.servingSize,
      servingUnit: servingUnit == null
          ? product.servingUnit
          : _emptyToNull(servingUnit),
      baseUnit: baseUnit ?? product.baseUnit,
      caloriesPer100: caloriesPer100 ?? product.caloriesPer100,
      proteinPer100: proteinPer100 ?? product.proteinPer100,
      carbsPer100: carbsPer100 ?? product.carbsPer100,
      fatPer100: fatPer100 ?? product.fatPer100,
      createdAt: product.createdAt,
      updatedAt: _clock(),
    );

    await (_database.update(_database.productRows)
          ..where((row) => row.id.equals(product.id)))
        .write(_productToCompanion(updated));
    _upsertProduct(updated);
    _replaceProductInLogItems(updated);
    notifyListeners();
    return updated;
  }

  bool hasLogItemsForProduct(String productId) {
    return _logItems.any((item) => item.product.id == productId);
  }

  Future<void> deleteProduct(String id) async {
    final now = _clock();
    await (_database.update(
      _database.productRows,
    )..where((row) => row.id.equals(id))).write(
      ProductRowsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
    _products.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  Future<LogItem> addLogItem({
    required Product product,
    required double quantity,
    required String unit,
    required MealType mealType,
  }) async {
    final now = _clock();
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
      createdAt: now,
      updatedAt: now,
    );

    await _database
        .into(_database.logItemRows)
        .insert(_logItemToCompanion(item));
    _logItems.add(item);
    _logItems.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    notifyListeners();
    return item;
  }

  Future<void> removeLogItem(String id) async {
    final now = _clock();
    await (_database.update(
      _database.logItemRows,
    )..where((row) => row.id.equals(id))).write(
      LogItemRowsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
    );
    _logItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> close() async {
    if (_ownsDatabase) {
      await _database.close();
    }
  }

  @override
  void dispose() {
    unawaited(close());
    super.dispose();
  }

  Product _productFromRow(ProductRow row) {
    return Product(
      id: row.id,
      name: row.name,
      brand: row.brand,
      servingSize: row.servingSize,
      servingUnit: row.servingUnit,
      baseUnit: BaseUnit.fromLabel(row.baseUnit),
      caloriesPer100: row.caloriesPer100,
      proteinPer100: row.proteinPer100,
      carbsPer100: row.carbsPer100,
      fatPer100: row.fatPer100,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  ProductRowsCompanion _productToCompanion(Product product) {
    return ProductRowsCompanion(
      id: Value(product.id),
      name: Value(product.name),
      brand: Value(product.brand),
      servingSize: Value(product.servingSize),
      servingUnit: Value(product.servingUnit),
      baseUnit: Value(product.baseUnit.label),
      caloriesPer100: Value(product.caloriesPer100),
      proteinPer100: Value(product.proteinPer100),
      carbsPer100: Value(product.carbsPer100),
      fatPer100: Value(product.fatPer100),
      createdAt: Value(product.createdAt),
      updatedAt: Value(product.updatedAt),
      deletedAt: Value(product.deletedAt),
    );
  }

  LogItem _logItemFromRow(LogItemRow row, Product product) {
    return LogItem(
      id: row.id,
      product: product,
      quantity: row.quantity,
      unit: row.unit,
      mealType: MealType.values.byName(row.mealType),
      macros: MacroSnapshot(
        calories: row.calories,
        protein: row.protein,
        carbs: row.carbs,
        fat: row.fat,
      ),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  LogItemRowsCompanion _logItemToCompanion(LogItem item) {
    return LogItemRowsCompanion(
      id: Value(item.id),
      productId: Value(item.product.id),
      mealType: Value(item.mealType.name),
      quantity: Value(item.quantity),
      unit: Value(item.unit),
      calories: Value(item.macros.calories),
      protein: Value(item.macros.protein),
      carbs: Value(item.macros.carbs),
      fat: Value(item.macros.fat),
      createdAt: Value(item.createdAt),
      updatedAt: Value(item.updatedAt),
      deletedAt: Value(item.deletedAt),
    );
  }

  void _upsertProduct(Product product) {
    final index = _products.indexWhere((existing) => existing.id == product.id);
    if (index == -1) {
      _products.add(product);
    } else {
      _products[index] = product;
    }
    _products.sort(_compareProducts);
  }

  void _replaceProductInLogItems(Product product) {
    for (var index = 0; index < _logItems.length; index++) {
      final item = _logItems[index];
      if (item.product.id == product.id) {
        _logItems[index] = item.copyWith(product: product);
      }
    }
  }

  int _compareProducts(Product left, Product right) {
    return left.displayName.toLowerCase().compareTo(
      right.displayName.toLowerCase(),
    );
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _makeId(String prefix) {
    _idCounter += 1;
    return '$prefix-${_clock().microsecondsSinceEpoch}-$_idCounter';
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
