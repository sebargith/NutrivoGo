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
    );
  }
}
