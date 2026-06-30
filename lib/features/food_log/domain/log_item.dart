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

  LogItem copyWith({
    Product? product,
    double? quantity,
    String? unit,
    MealType? mealType,
    MacroSnapshot? macros,
    DateTime? updatedAt,
    DateTime? deletedAt,
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
    );
  }
}
