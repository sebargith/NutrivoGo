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
  });

  final String id;
  final Product product;
  final double quantity;
  final String unit;
  final MealType mealType;
  final MacroSnapshot macros;
  final DateTime createdAt;
}
