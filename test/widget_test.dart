import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:drift/native.dart';
import 'package:nutrivogo/app.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';
import 'package:nutrivogo/features/food_log/domain/meal_type.dart';
import 'package:nutrivogo/features/products/domain/product.dart';

void main() {
  Future<({AppDatabase database, NutrivoGoStore store})>
  createMemoryStore() async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    final store = NutrivoGoStore(database: database);
    await store.ready;
    return (database: database, store: store);
  }

  testWidgets('shows the NutrivoGo dashboard', (tester) async {
    final fixture = await createMemoryStore();
    final store = fixture.store;

    await tester.pumpWidget(NutrivoGoApp(store: store));

    expect(find.text('Hoy'), findsWidgets);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Calorías'), findsOneWidget);
    expect(find.text('Desayuno'), findsOneWidget);
    final dashboardScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Agregar alimento'),
      300,
      scrollable: dashboardScroll,
    );
    expect(find.text('Agregar alimento'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Almuerzo'),
      300,
      scrollable: dashboardScroll,
    );
    expect(find.text('Almuerzo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Tarde'),
      300,
      scrollable: dashboardScroll,
    );
    expect(find.text('Tarde'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Cena'),
      300,
      scrollable: dashboardScroll,
    );
    expect(find.text('Cena'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Snack'),
      300,
      scrollable: dashboardScroll,
    );
    expect(find.text('Snack'), findsOneWidget);
    expect(find.text('Breakfast'), findsNothing);
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('Dinner'), findsNothing);
    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
  });

  testWidgets('dashboard shows daily meal and item cost', (tester) async {
    final fixture = await createMemoryStore();
    final store = fixture.store;
    final product = await store.addProduct(
      name: 'Avena',
      baseUnit: BaseUnit.grams,
      caloriesPer100: 380,
      proteinPer100: 13,
      carbsPer100: 62,
      fatPer100: 7,
      packagePriceClp: 3000,
      packageQuantity: 1000,
      packageQuantityUnit: 'g',
    );
    await store.addLogItem(
      product: product,
      quantity: 60,
      unit: 'g',
      mealType: MealType.breakfast,
    );

    await tester.pumpWidget(NutrivoGoApp(store: store));

    expect(find.text('Gasto del día'), findsOneWidget);
    expect(find.textContaining('\$180'), findsWidgets);
    expect(
      find.textContaining('Algunos alimentos no tienen precio'),
      findsNothing,
    );
  });

  testWidgets('Plato navigation keeps all product entry methods available', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fixture = await createMemoryStore();
    await tester.pumpWidget(NutrivoGoApp(store: fixture.store));

    await tester.tap(find.text('Historial').last);
    await tester.pumpAndSettle();
    expect(find.text('Día'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Mes'), findsOneWidget);

    await tester.tap(find.text('Productos').last);
    await tester.pumpAndSettle();
    expect(find.text('Código'), findsOneWidget);
    expect(find.text('Etiqueta'), findsOneWidget);
    expect(find.text('Gemini'), findsOneWidget);
    expect(find.text('Crear producto'), findsWidgets);

    await tester.tap(find.text('Ajustes').last);
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsOneWidget);
  });

  for (final mealType in MealType.values) {
    testWidgets('meal quick add preselects ${mealType.label}', (tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fixture = await createMemoryStore();
      final store = fixture.store;
      await store.addProduct(
        name: 'Pan',
        baseUnit: BaseUnit.grams,
        caloriesPer100: 250,
        proteinPer100: 8,
        carbsPer100: 45,
        fatPer100: 3,
      );

      await tester.pumpWidget(NutrivoGoApp(store: store));

      final dashboardScroll = find.byType(Scrollable).first;
      final quickAdd = find.byTooltip('Agregar a ${mealType.label}');
      await tester.scrollUntilVisible(
        quickAdd,
        300,
        scrollable: dashboardScroll,
      );
      await tester.tap(quickAdd);
      await tester.pumpAndSettle();

      expect(find.text('Agregar a ${mealType.label}'), findsOneWidget);
      await tester.tap(find.text('Pan'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar alimento'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Registrar en ${mealType.label}'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Registrar en ${mealType.label}'));
      await tester.pumpAndSettle();

      expect(store.itemsForMeal(mealType), hasLength(1));
    });
  }
}
