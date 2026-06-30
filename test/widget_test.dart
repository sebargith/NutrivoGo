import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Add Food'), findsOneWidget);
    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
  });
}
