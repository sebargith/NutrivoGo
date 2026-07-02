import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

const MethodChannel _platformChannel = MethodChannel('nutrivogo/platform');

Future<Directory> appDataDirectory() async {
  if (Platform.isAndroid) {
    final directoryPath = await _platformChannel.invokeMethod<String>(
      'applicationSupportDirectory',
    );
    if (directoryPath == null || directoryPath.isEmpty) {
      throw StateError('Android application directory was not available.');
    }
    return Directory(directoryPath);
  }

  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    final localAppData = Platform.environment['LOCALAPPDATA'];
    final basePath = appData ?? localAppData ?? Directory.current.path;
    return Directory(p.join(basePath, 'NutrivoGo'));
  }

  final home = Platform.environment['HOME'];
  if (home != null && home.isNotEmpty) {
    return Directory(p.join(home, '.nutrivogo'));
  }

  return Directory(p.join(Directory.current.path, '.nutrivogo'));
}
