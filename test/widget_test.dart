import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:drift/native.dart';
import 'package:nutrivogo/app.dart';
import 'package:nutrivogo/core/database/app_database.dart';
import 'package:nutrivogo/features/food_log/application/nutrivo_go_store.dart';

void main() {
  testWidgets('shows the NutrivoGo dashboard', (tester) async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    final store = NutrivoGoStore(database: database);
    await store.ready;

    await tester.pumpWidget(NutrivoGoApp(store: store));

    expect(find.text('NutrivoGo'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Calorías'), findsOneWidget);
    expect(find.text('Agregar alimento'), findsOneWidget);
    expect(find.text('Desayuno'), findsOneWidget);
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text('Tarde'), findsOneWidget);
    final dashboardScroll = find.byType(Scrollable).first;
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
}
