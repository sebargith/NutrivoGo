import 'macro_snapshot.dart';

class ConsumptionSummary {
  const ConsumptionSummary({
    required this.totalMacros,
    required this.recordedDayCount,
    required this.knownCostTotalClp,
    required this.daysWithKnownCost,
    required this.foodsWithoutPrice,
  });

  final MacroSnapshot totalMacros;
  final int recordedDayCount;
  final double? knownCostTotalClp;
  final int daysWithKnownCost;
  final int foodsWithoutPrice;

  MacroSnapshot get averageMacros {
    if (recordedDayCount == 0) {
      return const MacroSnapshot.zero();
    }
    return MacroSnapshot(
      calories: totalMacros.calories / recordedDayCount,
      protein: totalMacros.protein / recordedDayCount,
      carbs: totalMacros.carbs / recordedDayCount,
      fat: totalMacros.fat / recordedDayCount,
    );
  }

  double? get averageKnownCostClp {
    final total = knownCostTotalClp;
    if (total == null || daysWithKnownCost == 0) {
      return null;
    }
    return total / daysWithKnownCost;
  }
}
