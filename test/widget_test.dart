import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/app.dart';

void main() {
  testWidgets('shows the NutrivoGo dashboard', (tester) async {
    await tester.pumpWidget(const NutrivoGoApp());

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
