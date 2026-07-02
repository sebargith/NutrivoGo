import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

import 'auth_session_store.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.client, AuthSessionStore? sessionStore})
    : _sessionStore = sessionStore ?? AuthSessionStore() {
    ready = restoreSession();
  }

  final SupabaseClient client;
  final AuthSessionStore _sessionStore;
  late final Future<void> ready;
  bool _isBusy = false;
  String? _message;
  String? _errorMessage;

  User? get currentUser => client.auth.currentUser;

  bool get isSignedIn => currentUser != null;

  bool get isBusy => _isBusy;

  String? get message => _message;

  String? get errorMessage => _errorMessage;

  Future<void> signIn({required String email, required String password}) async {
    await _run(() async {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        throw const AuthException('Sign in did not return a user.');
      }
      await _persistCurrentSession();
      _message = 'Signed in as ${response.user!.email ?? email.trim()}';
    });
  }

  Future<void> signOut() async {
    await _run(() async {
      await client.auth.signOut();
      await _sessionStore.clear();
      _message = 'Signed out.';
    });
  }

  Future<void> restoreSession() async {
    final sessionJson = await _sessionStore.read();
    if (sessionJson == null) {
      return;
    }

    _isBusy = true;
    _message = null;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await client.auth.recoverSession(sessionJson);
      if (response.session == null) {
        await _sessionStore.clear();
        return;
      }
      await _persistCurrentSession();
      _message = 'Personal sync session restored.';
    } on AuthException {
      await _sessionStore.clear();
    } on FormatException {
      await _sessionStore.clear();
    } on Object {
      await _sessionStore.clear();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _isBusy = true;
    _message = null;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on Object catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _persistCurrentSession() async {
    final session = client.auth.currentSession;
    if (session == null) {
      await _sessionStore.clear();
      return;
    }
    await _sessionStore.write(jsonEncode(session.toJson()));
  }
}
