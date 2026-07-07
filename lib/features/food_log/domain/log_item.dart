import '../../../core/sync/record_sync_status.dart';
import '../../products/domain/product.dart';
import 'macro_snapshot.dart';
import 'meal_type.dart';

class LogItem {
  const LogItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.mealType,
    required this.macros,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userId,
    this.syncStatus = RecordSyncStatus.pending,
    this.lastSyncedAt,
    this.costSnapshotClp,
    this.costPer100SnapshotClp,
    this.costPerServingSnapshotClp,
    this.packagePriceSnapshotClp,
    this.packageQuantitySnapshot,
  });

  final String id;
  final Product product;
  final double quantity;
  final String unit;
  final MealType mealType;
  final MacroSnapshot macros;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;
  final RecordSyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final double? costSnapshotClp;
  final double? costPer100SnapshotClp;
  final double? costPerServingSnapshotClp;
  final double? packagePriceSnapshotClp;
  final double? packageQuantitySnapshot;

  LogItem copyWith({
    Product? product,
    double? quantity,
    String? unit,
    MealType? mealType,
    MacroSnapshot? macros,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? userId,
    RecordSyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    double? costSnapshotClp,
    double? costPer100SnapshotClp,
    double? costPerServingSnapshotClp,
    double? packagePriceSnapshotClp,
    double? packageQuantitySnapshot,
  }) {
    return LogItem(
      id: id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      mealType: mealType ?? this.mealType,
      macros: macros ?? this.macros,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      costSnapshotClp: costSnapshotClp ?? this.costSnapshotClp,
      costPer100SnapshotClp:
          costPer100SnapshotClp ?? this.costPer100SnapshotClp,
      costPerServingSnapshotClp:
          costPerServingSnapshotClp ?? this.costPerServingSnapshotClp,
      packagePriceSnapshotClp:
          packagePriceSnapshotClp ?? this.packagePriceSnapshotClp,
      packageQuantitySnapshot:
          packageQuantitySnapshot ?? this.packageQuantitySnapshot,
    );
  }
}
