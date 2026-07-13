import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/record_sync_status.dart';
import '../../../shared/utils/calendar_date.dart';
import '../../ocr_reports/domain/ocr_image_saving_mode.dart';
import '../../ocr_reports/domain/ocr_scan_report.dart';
import '../../products/domain/product.dart';
import '../domain/food_cost_calculator.dart';
import '../domain/consumption_summary.dart';
import '../domain/log_item.dart';
import '../domain/macro_calculator.dart';
import '../domain/macro_snapshot.dart';
import '../domain/meal_type.dart';

class NutrivoGoStore extends ChangeNotifier {
  NutrivoGoStore({
    AppDatabase? database,
    MacroCalculator? calculator,
    FoodCostCalculator? costCalculator,
    DateTime Function()? clock,
  }) : _database = database ?? AppDatabase(),
       _ownsDatabase = database == null,
       _calculator = calculator ?? const MacroCalculator(),
       _costCalculator = costCalculator ?? const FoodCostCalculator(),
       _clock = clock ?? DateTime.now {
    ready = load();
  }

  final AppDatabase _database;
  final bool _ownsDatabase;
  final MacroCalculator _calculator;
  final FoodCostCalculator _costCalculator;
  final DateTime Function() _clock;
  final List<Product> _products = <Product>[];
  final List<LogItem> _logItems = <LogItem>[];
  final List<OcrScanReport> _ocrScanReports = <OcrScanReport>[];
  String? _activeUserId;
  int _idCounter = 0;
  int _localChangeVersion = 0;
  OcrImageSavingMode _ocrImageSavingMode = OcrImageSavingMode.incorrectOnly;

  late final Future<void> ready;
  bool _isLoading = true;
  static const _ocrImageSavingModeKey = 'ocr_image_saving_mode';

  bool get isLoading => _isLoading;

  String? get activeUserId => _activeUserId;

  int get localChangeVersion => _localChangeVersion;

  List<Product> get products => List.unmodifiable(_products);

  List<LogItem> get logItems => List.unmodifiable(_logItems);

  List<OcrScanReport> get ocrScanReports {
    return List.unmodifiable(_ocrScanReports);
  }

  OcrImageSavingMode get ocrImageSavingMode => _ocrImageSavingMode;

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
    return logItemsForDate(_clock());
  }

  MacroSnapshot get dailyTotals {
    return todaysLogItems.fold(
      const MacroSnapshot.zero(),
      (total, item) => total + item.macros,
    );
  }

  double? get dailyCostClp {
    return _sumKnownCosts(todaysLogItems);
  }

  bool get hasUnknownDailyCosts {
    return todaysLogItems.any((item) => item.costSnapshotClp == null);
  }

  Product? findProductByBarcode(String barcode) {
    final normalized = _normalizeBarcode(barcode);
    if (normalized == null) {
      return null;
    }
    for (final product in _products) {
      if (_normalizeBarcode(product.barcode) == normalized) {
        return product;
      }
    }
    return null;
  }

  List<LogItem> logItemsForDate(DateTime date) {
    return _logItems
        .where(
          (item) => isSameCalendarDate(item.consumedOn ?? item.createdAt, date),
        )
        .toList(growable: false);
  }

  List<DateTime> get consumptionDates {
    final dates = <DateTime>{
      for (final item in _logItems)
        calendarDate(item.consumedOn ?? item.createdAt),
    }.toList()..sort((left, right) => right.compareTo(left));
    return List.unmodifiable(dates);
  }

  MacroSnapshot totalsForDate(DateTime date) {
    return _totalMacros(logItemsForDate(date));
  }

  double? costForDate(DateTime date) {
    return _sumKnownCosts(logItemsForDate(date));
  }

  int foodsWithoutPriceForDate(DateTime date) {
    return _countUnknownCosts(logItemsForDate(date));
  }

  ConsumptionSummary summaryForRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    final items = _logItems
        .where((item) {
          final date = calendarDate(item.consumedOn ?? item.createdAt);
          return !date.isBefore(calendarDate(startInclusive)) &&
              date.isBefore(calendarDate(endExclusive));
        })
        .toList(growable: false);
    final recordedDates = <DateTime>{
      for (final item in items) calendarDate(item.consumedOn ?? item.createdAt),
    };
    final knownCosts = <DateTime, double>{};
    for (final item in items) {
      final cost = item.costSnapshotClp;
      if (cost == null) {
        continue;
      }
      final date = calendarDate(item.consumedOn ?? item.createdAt);
      knownCosts.update(
        date,
        (current) => current + cost,
        ifAbsent: () => cost,
      );
    }
    return ConsumptionSummary(
      totalMacros: _totalMacros(items),
      recordedDayCount: recordedDates.length,
      knownCostTotalClp: knownCosts.isEmpty
          ? null
          : knownCosts.values.fold<double>(0, (sum, value) => sum + value),
      daysWithKnownCost: knownCosts.length,
      foodsWithoutPrice: _countUnknownCosts(items),
    );
  }

  ConsumptionSummary summaryForDate(DateTime date) {
    return summaryForRange(
      date,
      calendarDate(date).add(const Duration(days: 1)),
    );
  }

  List<LogItem> itemsForMeal(MealType mealType, {DateTime? consumedOn}) {
    return logItemsForDate(
      consumedOn ?? _clock(),
    ).where((item) => item.mealType == mealType).toList(growable: false);
  }

  double? costForMeal(MealType mealType, {DateTime? consumedOn}) {
    return _sumKnownCosts(itemsForMeal(mealType, consumedOn: consumedOn));
  }

  bool hasUnknownCostsForMeal(MealType mealType, {DateTime? consumedOn}) {
    return itemsForMeal(
      mealType,
      consumedOn: consumedOn,
    ).any((item) => item.costSnapshotClp == null);
  }

  List<Product> frequentProductsForMeal(MealType mealType, {int limit = 5}) {
    final ranked = rankedProductsForMeal(mealType: mealType, query: '');
    return ranked
        .where((product) => _mealUsageStats(mealType)[product.id] != null)
        .take(limit)
        .toList(growable: false);
  }

  List<Product> rankedProductsForMeal({MealType? mealType, String query = ''}) {
    final normalizedQuery = query.trim().toLowerCase();
    final mealStats = mealType == null
        ? <String, _UsageStats>{}
        : _mealUsageStats(mealType);
    final generalStats = _generalUsageStats();

    final ranked = _products.where((product) {
      if (normalizedQuery.isEmpty) {
        return true;
      }
      return _productSearchText(product).contains(normalizedQuery);
    }).toList();

    ranked.sort((left, right) {
      if (normalizedQuery.isNotEmpty) {
        final searchComparison = _searchRank(
          left,
          normalizedQuery,
        ).compareTo(_searchRank(right, normalizedQuery));
        if (searchComparison != 0) {
          return searchComparison;
        }
      }

      final leftMeal = mealStats[left.id];
      final rightMeal = mealStats[right.id];
      final mealComparison = _compareUsageStats(leftMeal, rightMeal);
      if (mealComparison != 0) {
        return mealComparison;
      }

      final generalComparison = _compareUsageStats(
        generalStats[left.id],
        generalStats[right.id],
      );
      if (generalComparison != 0) {
        return generalComparison;
      }

      return _compareProducts(left, right);
    });

    return List.unmodifiable(ranked);
  }

  Future<void> load() async {
    _isLoading = true;
    await _loadSettings();
    final productRows = await _database.select(_database.productRows).get();
    final productsById = {
      for (final row in productRows)
        if (_canShowUserData(row.userId)) row.id: _productFromRow(row),
    };

    final activeProducts =
        productRows
            .where(
              (row) => row.deletedAt == null && _canShowUserData(row.userId),
            )
            .map(_productFromRow)
            .toList()
          ..sort(_compareProducts);

    final logRows = await (_database.select(
      _database.logItemRows,
    )..where((row) => row.deletedAt.isNull())).get();
    final activeLogItems = <LogItem>[
      for (final row in logRows)
        if (_canShowUserData(row.userId) && productsById[row.productId] != null)
          _logItemFromRow(row, productsById[row.productId]!),
    ]..sort((left, right) => left.createdAt.compareTo(right.createdAt));

    final ocrReportRows = await (_database.select(
      _database.ocrScanReportRows,
    )..where((row) => row.deletedAt.isNull())).get();
    final activeOcrReports = <OcrScanReport>[
      for (final row in ocrReportRows)
        if (_canShowUserData(row.userId)) _ocrScanReportFromRow(row),
    ]..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    _products
      ..clear()
      ..addAll(activeProducts);
    _logItems
      ..clear()
      ..addAll(activeLogItems);
    _ocrScanReports
      ..clear()
      ..addAll(activeOcrReports);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setActiveUserId(String? userId) async {
    if (_activeUserId == userId) {
      return;
    }
    _activeUserId = userId;
    await load();
  }

  Future<void> setOcrImageSavingMode(OcrImageSavingMode mode) async {
    if (_ocrImageSavingMode == mode) {
      return;
    }
    _ocrImageSavingMode = mode;
    await _database
        .into(_database.appSettingRows)
        .insertOnConflictUpdate(
          AppSettingRowsCompanion(
            key: const Value(_ocrImageSavingModeKey),
            value: Value(mode.storageValue),
            updatedAt: Value(_clock()),
          ),
        );
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
    String? barcode,
    String? source,
    double? sugarPer100,
    double? saturatedFatPer100,
    double? sodiumPer100,
    double? fiberPer100,
    double? packagePriceClp,
    double? packageQuantity,
    String? packageQuantityUnit,
    double? unitsPerServing,
    double? servingsPerPackage,
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
      userId: _activeUserId,
      barcode: _normalizeBarcode(barcode),
      source: _emptyToNull(source),
      sugarPer100: sugarPer100,
      saturatedFatPer100: saturatedFatPer100,
      sodiumPer100: sodiumPer100,
      fiberPer100: fiberPer100,
      packagePriceClp: packagePriceClp,
      packageQuantity: packageQuantity,
      packageQuantityUnit: packageQuantity == null
          ? null
          : _emptyToNull(packageQuantityUnit) ?? baseUnit.label,
      unitsPerServing: _positiveOptional(unitsPerServing),
      servingsPerPackage: _positiveOptional(servingsPerPackage),
    );

    await _database
        .into(_database.productRows)
        .insert(_productToCompanion(product));
    _upsertProduct(product);
    _markLocalChange();
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
    String? barcode,
    String? source,
    bool clearBarcode = false,
    bool clearSource = false,
    double? sugarPer100,
    double? saturatedFatPer100,
    double? sodiumPer100,
    double? fiberPer100,
    double? packagePriceClp,
    double? packageQuantity,
    String? packageQuantityUnit,
    double? unitsPerServing,
    double? servingsPerPackage,
    bool clearExtraNutrients = false,
    bool clearSugar = false,
    bool clearSaturatedFat = false,
    bool clearSodium = false,
    bool clearFiber = false,
    bool clearPackagePrice = false,
    bool clearPackageQuantity = false,
    bool clearUnitsPerServing = false,
    bool clearServingsPerPackage = false,
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
      userId: product.userId ?? _activeUserId,
      syncStatus: RecordSyncStatus.pending,
      barcode: clearBarcode
          ? null
          : barcode == null
          ? product.barcode
          : _normalizeBarcode(barcode),
      source: clearSource
          ? null
          : source == null
          ? product.source
          : _emptyToNull(source),
      sugarPer100: clearExtraNutrients || clearSugar
          ? null
          : sugarPer100 ?? product.sugarPer100,
      saturatedFatPer100: clearExtraNutrients || clearSaturatedFat
          ? null
          : saturatedFatPer100 ?? product.saturatedFatPer100,
      sodiumPer100: clearExtraNutrients || clearSodium
          ? null
          : sodiumPer100 ?? product.sodiumPer100,
      fiberPer100: clearExtraNutrients || clearFiber
          ? null
          : fiberPer100 ?? product.fiberPer100,
      packagePriceClp: clearPackagePrice
          ? null
          : packagePriceClp ?? product.packagePriceClp,
      packageQuantity: clearPackageQuantity
          ? null
          : packageQuantity ?? product.packageQuantity,
      packageQuantityUnit: clearPackageQuantity
          ? null
          : packageQuantityUnit == null
          ? product.packageQuantityUnit
          : _emptyToNull(packageQuantityUnit),
      unitsPerServing: clearUnitsPerServing
          ? null
          : _positiveOptional(unitsPerServing ?? product.unitsPerServing),
      servingsPerPackage: clearServingsPerPackage
          ? null
          : _positiveOptional(servingsPerPackage ?? product.servingsPerPackage),
    );

    await (_database.update(_database.productRows)
          ..where((row) => row.id.equals(product.id)))
        .write(_productToCompanion(updated));
    _upsertProduct(updated);
    _replaceProductInLogItems(updated);
    _markLocalChange();
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
      ProductRowsCompanion(
        updatedAt: Value(now),
        deletedAt: Value(now),
        syncStatus: Value(RecordSyncStatus.pending.storageValue),
        lastSyncedAt: const Value(null),
      ),
    );
    _products.removeWhere((product) => product.id == id);
    _markLocalChange();
    notifyListeners();
  }

  Future<LogItem> addLogItem({
    required Product product,
    required double quantity,
    required String unit,
    required MealType mealType,
    DateTime? consumedOn,
  }) async {
    final now = _clock();
    final macros = _calculator.calculateFromProduct(
      product: product,
      quantity: quantity,
      unit: unit,
    );
    final costSnapshot = _costCalculator.calculateLogCost(
      product: product,
      quantity: quantity,
      unit: unit,
    );
    final baseQuantity = _calculator.quantityInBaseUnit(
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
      consumedOn: calendarDate(consumedOn ?? now),
      userId: _activeUserId,
      costSnapshotClp: costSnapshot,
      costPer100SnapshotClp: _costCalculator.costPer100(product),
      costPerServingSnapshotClp: _costCalculator.costPerServing(product),
      packagePriceSnapshotClp: product.packagePriceClp,
      packageQuantitySnapshot: product.effectivePackageQuantity,
      baseQuantitySnapshot: baseQuantity,
      servingSizeSnapshot: product.servingSize,
      unitsPerServingSnapshot: product.unitsPerServing,
      baseQuantityPerUnitSnapshot: product.baseQuantityPerUnit,
    );

    await _database
        .into(_database.logItemRows)
        .insert(_logItemToCompanion(item));
    _logItems.add(item);
    _logItems.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    _markLocalChange();
    notifyListeners();
    return item;
  }

  Future<void> removeLogItem(String id) async {
    final now = _clock();
    await (_database.update(
      _database.logItemRows,
    )..where((row) => row.id.equals(id))).write(
      LogItemRowsCompanion(
        updatedAt: Value(now),
        deletedAt: Value(now),
        syncStatus: Value(RecordSyncStatus.pending.storageValue),
        lastSyncedAt: const Value(null),
      ),
    );
    _logItems.removeWhere((item) => item.id == id);
    _markLocalChange();
    notifyListeners();
  }

  Future<OcrScanReport> addOcrScanReport({
    required String rawOcrText,
    required Map<String, Object?> parsedJson,
    required String platform,
    Map<String, Object?>? correctedJson,
    String? detectedBasis,
    List<String> parserWarnings = const <String>[],
    double? parserConfidence,
    bool? wasParserCorrect,
    String? userFeedback,
    String? productId,
    String? productName,
    String? barcode,
    String source = 'ocr',
    String? appVersion,
    String? imagePathLocal,
  }) async {
    final now = _clock();
    final report = OcrScanReport(
      id: _makeId('ocr-report'),
      rawOcrText: rawOcrText,
      parsedJson: jsonEncode(parsedJson),
      correctedJson: correctedJson == null ? null : jsonEncode(correctedJson),
      detectedBasis: _emptyToNull(detectedBasis),
      parserWarnings: parserWarnings.isEmpty
          ? null
          : jsonEncode(parserWarnings),
      parserConfidence: parserConfidence,
      wasParserCorrect: wasParserCorrect,
      userFeedback: _emptyToNull(userFeedback),
      productId: _emptyToNull(productId),
      productName: _emptyToNull(productName),
      barcode: _normalizeBarcode(barcode),
      source: source,
      platform: platform,
      appVersion: _emptyToNull(appVersion),
      imagePathLocal: _shouldKeepOcrImagePath(imagePathLocal, wasParserCorrect)
          ? _emptyToNull(imagePathLocal)
          : null,
      createdAt: now,
      updatedAt: now,
      userId: _activeUserId,
    );

    await _database
        .into(_database.ocrScanReportRows)
        .insert(_ocrScanReportToCompanion(report));
    _upsertOcrScanReport(report);
    _markLocalChange();
    notifyListeners();
    return report;
  }

  Future<void> close() async {
    if (_ownsDatabase) {
      await _database.close();
    }
  }

  Future<void> _loadSettings() async {
    final row =
        await (_database.select(_database.appSettingRows)
              ..where((setting) => setting.key.equals(_ocrImageSavingModeKey)))
            .getSingleOrNull();
    _ocrImageSavingMode = OcrImageSavingMode.fromStorage(row?.value);
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
      userId: row.userId,
      syncStatus: RecordSyncStatus.fromStorage(row.syncStatus),
      lastSyncedAt: row.lastSyncedAt,
      barcode: row.barcode,
      source: row.source,
      sugarPer100: row.sugarPer100,
      saturatedFatPer100: row.saturatedFatPer100,
      sodiumPer100: row.sodiumPer100,
      fiberPer100: row.fiberPer100,
      packagePriceClp: row.packagePriceClp,
      packageQuantity: row.packageQuantity,
      packageQuantityUnit: row.packageQuantityUnit,
      unitsPerServing: row.unitsPerServing,
      servingsPerPackage: row.servingsPerPackage,
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
      userId: Value(product.userId),
      syncStatus: Value(product.syncStatus.storageValue),
      lastSyncedAt: Value(product.lastSyncedAt),
      barcode: Value(product.barcode),
      source: Value(product.source),
      sugarPer100: Value(product.sugarPer100),
      saturatedFatPer100: Value(product.saturatedFatPer100),
      sodiumPer100: Value(product.sodiumPer100),
      fiberPer100: Value(product.fiberPer100),
      packagePriceClp: Value(product.packagePriceClp),
      packageQuantity: Value(product.packageQuantity),
      packageQuantityUnit: Value(product.packageQuantityUnit),
      unitsPerServing: Value(product.unitsPerServing),
      servingsPerPackage: Value(product.servingsPerPackage),
    );
  }

  LogItem _logItemFromRow(LogItemRow row, Product product) {
    return LogItem(
      id: row.id,
      product: product,
      quantity: row.quantity,
      unit: row.unit,
      mealType: MealType.fromStorage(row.mealType),
      macros: MacroSnapshot(
        calories: row.calories,
        protein: row.protein,
        carbs: row.carbs,
        fat: row.fat,
      ),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      consumedOn: row.consumedOn == null
          ? calendarDate(row.createdAt)
          : calendarDate(row.consumedOn!),
      deletedAt: row.deletedAt,
      userId: row.userId,
      syncStatus: RecordSyncStatus.fromStorage(row.syncStatus),
      lastSyncedAt: row.lastSyncedAt,
      costSnapshotClp: row.costSnapshotClp,
      costPer100SnapshotClp: row.costPer100SnapshotClp,
      costPerServingSnapshotClp: row.costPerServingSnapshotClp,
      packagePriceSnapshotClp: row.packagePriceSnapshotClp,
      packageQuantitySnapshot: row.packageQuantitySnapshot,
      baseQuantitySnapshot: row.baseQuantitySnapshot,
      servingSizeSnapshot: row.servingSizeSnapshot,
      unitsPerServingSnapshot: row.unitsPerServingSnapshot,
      baseQuantityPerUnitSnapshot: row.baseQuantityPerUnitSnapshot,
    );
  }

  LogItemRowsCompanion _logItemToCompanion(LogItem item) {
    return LogItemRowsCompanion(
      id: Value(item.id),
      productId: Value(item.product.id),
      mealType: Value(item.mealType.storageValue),
      quantity: Value(item.quantity),
      unit: Value(item.unit),
      calories: Value(item.macros.calories),
      protein: Value(item.macros.protein),
      carbs: Value(item.macros.carbs),
      fat: Value(item.macros.fat),
      createdAt: Value(item.createdAt),
      updatedAt: Value(item.updatedAt),
      consumedOn: Value(calendarDate(item.consumedOn ?? item.createdAt)),
      deletedAt: Value(item.deletedAt),
      userId: Value(item.userId),
      syncStatus: Value(item.syncStatus.storageValue),
      lastSyncedAt: Value(item.lastSyncedAt),
      costSnapshotClp: Value(item.costSnapshotClp),
      costPer100SnapshotClp: Value(item.costPer100SnapshotClp),
      costPerServingSnapshotClp: Value(item.costPerServingSnapshotClp),
      packagePriceSnapshotClp: Value(item.packagePriceSnapshotClp),
      packageQuantitySnapshot: Value(item.packageQuantitySnapshot),
      baseQuantitySnapshot: Value(item.baseQuantitySnapshot),
      servingSizeSnapshot: Value(item.servingSizeSnapshot),
      unitsPerServingSnapshot: Value(item.unitsPerServingSnapshot),
      baseQuantityPerUnitSnapshot: Value(item.baseQuantityPerUnitSnapshot),
    );
  }

  OcrScanReport _ocrScanReportFromRow(OcrScanReportRow row) {
    return OcrScanReport(
      id: row.id,
      rawOcrText: row.rawOcrText,
      parsedJson: row.parsedJson,
      correctedJson: row.correctedJson,
      detectedBasis: row.detectedBasis,
      parserWarnings: row.parserWarnings,
      parserConfidence: row.parserConfidence,
      wasParserCorrect: row.wasParserCorrect,
      userFeedback: row.userFeedback,
      productId: row.productId,
      productName: row.productName,
      barcode: row.barcode,
      source: row.source,
      platform: row.platform,
      appVersion: row.appVersion,
      imageSaved: row.imageSaved,
      imageStoragePath: row.imageStoragePath,
      imageCropStoragePath: row.imageCropStoragePath,
      imagePathLocal: row.imagePathLocal,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      userId: row.userId,
      syncStatus: RecordSyncStatus.fromStorage(row.syncStatus),
      lastSyncedAt: row.lastSyncedAt,
    );
  }

  OcrScanReportRowsCompanion _ocrScanReportToCompanion(OcrScanReport report) {
    return OcrScanReportRowsCompanion(
      id: Value(report.id),
      rawOcrText: Value(report.rawOcrText),
      parsedJson: Value(report.parsedJson),
      correctedJson: Value(report.correctedJson),
      detectedBasis: Value(report.detectedBasis),
      parserWarnings: Value(report.parserWarnings),
      parserConfidence: Value(report.parserConfidence),
      wasParserCorrect: Value(report.wasParserCorrect),
      userFeedback: Value(report.userFeedback),
      productId: Value(report.productId),
      productName: Value(report.productName),
      barcode: Value(report.barcode),
      source: Value(report.source),
      platform: Value(report.platform),
      appVersion: Value(report.appVersion),
      imageSaved: Value(report.imageSaved),
      imageStoragePath: Value(report.imageStoragePath),
      imageCropStoragePath: Value(report.imageCropStoragePath),
      imagePathLocal: Value(report.imagePathLocal),
      createdAt: Value(report.createdAt),
      updatedAt: Value(report.updatedAt),
      deletedAt: Value(report.deletedAt),
      userId: Value(report.userId),
      syncStatus: Value(report.syncStatus.storageValue),
      lastSyncedAt: Value(report.lastSyncedAt),
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

  void _upsertOcrScanReport(OcrScanReport report) {
    final index = _ocrScanReports.indexWhere(
      (existing) => existing.id == report.id,
    );
    if (index == -1) {
      _ocrScanReports.add(report);
    } else {
      _ocrScanReports[index] = report;
    }
    _ocrScanReports.sort(
      (left, right) => right.createdAt.compareTo(left.createdAt),
    );
  }

  double? _sumKnownCosts(Iterable<LogItem> items) {
    var hasKnownCost = false;
    var total = 0.0;
    for (final item in items) {
      final cost = item.costSnapshotClp;
      if (cost == null) {
        continue;
      }
      hasKnownCost = true;
      total += cost;
    }
    return hasKnownCost ? total : null;
  }

  MacroSnapshot _totalMacros(Iterable<LogItem> items) {
    return items.fold(
      const MacroSnapshot.zero(),
      (total, item) => total + item.macros,
    );
  }

  int _countUnknownCosts(Iterable<LogItem> items) {
    return items.where((item) => item.costSnapshotClp == null).length;
  }

  Map<String, _UsageStats> _mealUsageStats(MealType mealType) {
    final stats = <String, _UsageStats>{};
    for (final item in _logItems) {
      if (item.mealType != mealType) {
        continue;
      }
      stats.update(
        item.product.id,
        (current) => current.add(item.createdAt),
        ifAbsent: () => _UsageStats.first(item.createdAt),
      );
    }
    return stats;
  }

  Map<String, _UsageStats> _generalUsageStats() {
    final stats = <String, _UsageStats>{};
    for (final item in _logItems) {
      stats.update(
        item.product.id,
        (current) => current.add(item.createdAt),
        ifAbsent: () => _UsageStats.first(item.createdAt),
      );
    }
    return stats;
  }

  String _productSearchText(Product product) {
    return '${product.name} ${product.brand ?? ''} ${product.barcode ?? ''}'
        .toLowerCase();
  }

  int _searchRank(Product product, String query) {
    final name = product.name.toLowerCase();
    final brand = product.brand?.toLowerCase() ?? '';
    final barcode = product.barcode?.toLowerCase() ?? '';
    if (name == query || barcode == query) {
      return 0;
    }
    if (name.startsWith(query)) {
      return 1;
    }
    if (brand.startsWith(query)) {
      return 2;
    }
    return 3;
  }

  int _compareUsageStats(_UsageStats? left, _UsageStats? right) {
    final leftCount = left?.count ?? 0;
    final rightCount = right?.count ?? 0;
    final countComparison = rightCount.compareTo(leftCount);
    if (countComparison != 0) {
      return countComparison;
    }

    final leftLastUsed = left?.lastUsedAt;
    final rightLastUsed = right?.lastUsedAt;
    if (leftLastUsed == null && rightLastUsed == null) {
      return 0;
    }
    if (leftLastUsed == null) {
      return 1;
    }
    if (rightLastUsed == null) {
      return -1;
    }
    return rightLastUsed.compareTo(leftLastUsed);
  }

  int _compareProducts(Product left, Product right) {
    return left.displayName.toLowerCase().compareTo(
      right.displayName.toLowerCase(),
    );
  }

  bool _canShowUserData(String? rowUserId) {
    return rowUserId == null || rowUserId == _activeUserId;
  }

  void _markLocalChange() {
    _localChangeVersion += 1;
  }

  bool _shouldKeepOcrImagePath(String? imagePathLocal, bool? wasParserCorrect) {
    if (_emptyToNull(imagePathLocal) == null) {
      return false;
    }
    return switch (_ocrImageSavingMode) {
      OcrImageSavingMode.never => false,
      OcrImageSavingMode.incorrectOnly => wasParserCorrect != true,
      OcrImageSavingMode.always => true,
    };
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

  String? _normalizeBarcode(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed.replaceAll(RegExp(r'\s+'), '');
  }

  double? _positiveOptional(double? value) {
    if (value == null || !value.isFinite || value <= 0) {
      return null;
    }
    return value;
  }
}

class _UsageStats {
  const _UsageStats({required this.count, required this.lastUsedAt});

  factory _UsageStats.first(DateTime usedAt) {
    return _UsageStats(count: 1, lastUsedAt: usedAt);
  }

  final int count;
  final DateTime lastUsedAt;

  _UsageStats add(DateTime usedAt) {
    return _UsageStats(
      count: count + 1,
      lastUsedAt: usedAt.isAfter(lastUsedAt) ? usedAt : lastUsedAt,
    );
  }
}
