import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Flutter code does not contain Gemini secret names or direct API URL',
    () {
      final libFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in libFiles) {
        final text = file.readAsStringSync();
        expect(text, isNot(contains('GEMINI_API_KEY')), reason: file.path);
        expect(
          text,
          isNot(contains('generativelanguage.googleapis.com')),
          reason: file.path,
        );
      }
    },
  );

  test('Gemini call and secret stay in the Supabase Edge Function', () {
    final functionText = File(
      'supabase/functions/analyze-product-gemini/index.ts',
    ).readAsStringSync();

    expect(functionText, contains('GEMINI_API_KEY'));
    expect(functionText, contains('GEMINI_MODEL'));
    expect(functionText, contains('generativelanguage.googleapis.com'));
    expect(functionText, contains('Authorization'));
    expect(functionText, contains('responseMimeType'));
    expect(functionText, contains('responseSchema'));
  });
}
