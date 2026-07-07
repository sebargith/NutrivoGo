import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../platform/app_data_directory.dart';

part 'app_database.g.dart';

@DataClassName('ProductRow')
class ProductRows extends Table {
  @override
  String get tableName => 'products';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  RealColumn get servingSize => real().nullable()();
  TextColumn get servingUnit => text().nullable()();
  TextColumn get baseUnit => text()();
  RealColumn get caloriesPer100 => real()();
  RealColumn get proteinPer100 => real()();
  RealColumn get carbsPer100 => real()();
  RealColumn get fatPer100 => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get source => text().nullable()();
  RealColumn get sugarPer100 => real().nullable()();
  RealColumn get saturatedFatPer100 => real().nullable()();
  RealColumn get sodiumPer100 => real().nullable()();
  RealColumn get fiberPer100 => real().nullable()();
  RealColumn get packagePriceClp => real().nullable()();
  RealColumn get packageQuantity => real().nullable()();
  TextColumn get packageQuantityUnit => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LogItemRow')
class LogItemRows extends Table {
  @override
  String get tableName => 'log_items';

  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get mealType => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  RealColumn get costSnapshotClp => real().nullable()();
  RealColumn get costPer100SnapshotClp => real().nullable()();
  RealColumn get costPerServingSnapshotClp => real().nullable()();
  RealColumn get packagePriceSnapshotClp => real().nullable()();
  RealColumn get packageQuantitySnapshot => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('OcrScanReportRow')
class OcrScanReportRows extends Table {
  @override
  String get tableName => 'ocr_scan_reports';

  TextColumn get id => text()();
  TextColumn get rawOcrText => text()();
  TextColumn get parsedJson => text()();
  TextColumn get correctedJson => text().nullable()();
  TextColumn get detectedBasis => text().nullable()();
  TextColumn get parserWarnings => text().nullable()();
  RealColumn get parserConfidence => real().nullable()();
  BoolColumn get wasParserCorrect => boolean().nullable()();
  TextColumn get userFeedback => text().nullable()();
  TextColumn get productId => text().nullable()();
  TextColumn get productName => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('ocr'))();
  TextColumn get platform => text()();
  TextColumn get appVersion => text().nullable()();
  BoolColumn get imageSaved => boolean().withDefault(const Constant(false))();
  TextColumn get imageStoragePath => text().nullable()();
  TextColumn get imageCropStoragePath => text().nullable()();
  TextColumn get imagePathLocal => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettingRows extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [ProductRows, LogItemRows, OcrScanReportRows, AppSettingRows],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.connect(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(productRows, productRows.userId);
        await migrator.addColumn(productRows, productRows.syncStatus);
        await migrator.addColumn(productRows, productRows.lastSyncedAt);
        await migrator.addColumn(logItemRows, logItemRows.userId);
        await migrator.addColumn(logItemRows, logItemRows.syncStatus);
        await migrator.addColumn(logItemRows, logItemRows.lastSyncedAt);
      }
      if (from < 3) {
        await migrator.addColumn(productRows, productRows.barcode);
        await migrator.addColumn(productRows, productRows.source);
        await migrator.addColumn(productRows, productRows.sugarPer100);
        await migrator.addColumn(productRows, productRows.saturatedFatPer100);
        await migrator.addColumn(productRows, productRows.sodiumPer100);
        await migrator.addColumn(productRows, productRows.fiberPer100);
      }
      if (from < 4) {
        await migrator.createTable(ocrScanReportRows);
        await migrator.createTable(appSettingRows);
      }
      if (from < 5) {
        await migrator.addColumn(productRows, productRows.packagePriceClp);
        await migrator.addColumn(productRows, productRows.packageQuantity);
        await migrator.addColumn(productRows, productRows.packageQuantityUnit);
        await migrator.addColumn(logItemRows, logItemRows.costSnapshotClp);
        await migrator.addColumn(
          logItemRows,
          logItemRows.costPer100SnapshotClp,
        );
        await migrator.addColumn(
          logItemRows,
          logItemRows.costPerServingSnapshotClp,
        );
        await migrator.addColumn(
          logItemRows,
          logItemRows.packagePriceSnapshotClp,
        );
        await migrator.addColumn(
          logItemRows,
          logItemRows.packageQuantitySnapshot,
        );
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await appDataDirectory();
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, 'nutrivogo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
