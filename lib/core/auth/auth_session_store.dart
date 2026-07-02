import 'dart:io';

import 'package:path/path.dart' as p;

import '../platform/app_data_directory.dart';

class AuthSessionStore {
  AuthSessionStore({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? appDataDirectory;

  static const fileName = 'supabase_session.json';

  final Future<Directory> Function() _directoryProvider;

  Future<String?> read() async {
    final file = await _sessionFile();
    if (!await file.exists()) {
      return null;
    }
    final content = await file.readAsString();
    final trimmed = content.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> write(String sessionJson) async {
    final directory = await _directoryProvider();
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, fileName));
    await file.writeAsString(sessionJson);
  }

  Future<void> clear() async {
    final file = await _sessionFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _sessionFile() async {
    final directory = await _directoryProvider();
    return File(p.join(directory.path, fileName));
  }
}
