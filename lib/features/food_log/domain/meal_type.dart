enum MealType {
  breakfast('Desayuno'),
  lunch('Almuerzo'),
  afternoon('Tarde'),
  dinner('Cena'),
  snack('Snack');

  const MealType(this.label);

  final String label;

  String get storageValue => name;

  static MealType fromStorage(String value) {
    return MealType.values.firstWhere(
      (mealType) => mealType.storageValue == value,
      orElse: () => MealType.snack,
    );
  }
}
