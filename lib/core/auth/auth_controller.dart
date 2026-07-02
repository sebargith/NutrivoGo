import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.client});

  final SupabaseClient client;
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
      _message = 'Signed in as ${response.user!.email ?? email.trim()}';
    });
  }

  Future<void> signOut() async {
    await _run(() async {
      await client.auth.signOut();
      _message = 'Signed out.';
    });
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
}
