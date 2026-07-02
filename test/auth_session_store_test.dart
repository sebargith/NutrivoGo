import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivogo/core/auth/auth_controller.dart';
import 'package:nutrivogo/core/auth/auth_session_store.dart';
import 'package:supabase/supabase.dart';

void main() {
  test(
    'stores session JSON for remembered login between app restarts',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'nutrivogo-auth-session-',
      );
      addTearDown(() => directory.delete(recursive: true));

      final firstStore = AuthSessionStore(
        directoryProvider: () async => directory,
      );
      await firstStore.write('{"access_token":"token"}');

      final secondStore = AuthSessionStore(
        directoryProvider: () async => directory,
      );
      expect(await secondStore.read(), '{"access_token":"token"}');

      await secondStore.clear();
      expect(await firstStore.read(), isNull);
    },
  );

  test('restores a saved unexpired Supabase session', () async {
    final directory = await Directory.systemTemp.createTemp(
      'nutrivogo-auth-restore-',
    );
    addTearDown(() => directory.delete(recursive: true));

    final store = AuthSessionStore(directoryProvider: () async => directory);
    await store.write(
      jsonEncode({
        'access_token': _unsignedJwt({
          'exp': DateTime.now().add(const Duration(hours: 1)).secondsSinceEpoch,
        }),
        'refresh_token': 'refresh-token',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': {
          'id': 'user-1',
          'aud': 'authenticated',
          'email': 'personal@example.com',
          'created_at': DateTime.utc(2026).toIso8601String(),
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
        },
      }),
    );

    final controller = AuthController(
      client: SupabaseClient('https://example.supabase.co', 'anon-key'),
      sessionStore: store,
    );
    addTearDown(controller.dispose);

    await controller.ready;

    expect(controller.isSignedIn, isTrue);
    expect(controller.currentUser?.email, 'personal@example.com');
    expect(await store.read(), isNotNull);
  });
}

String _unsignedJwt(Map<String, dynamic> payload) {
  String encodePart(Map<String, dynamic> value) {
    return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  }

  return '${encodePart({'alg': 'none', 'typ': 'JWT'})}.${encodePart(payload)}.';
}

extension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}
