class MacroSnapshot {
  const MacroSnapshot({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  const MacroSnapshot.zero() : calories = 0, protein = 0, carbs = 0, fat = 0;

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MacroSnapshot operator +(MacroSnapshot other) {
    return MacroSnapshot(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
    );
  }
}
