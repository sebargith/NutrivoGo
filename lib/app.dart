import 'dart:async';

import 'package:flutter/material.dart';

import 'core/auth/auth_controller.dart';
import 'core/database/app_database.dart';
import 'core/supabase/supabase_client_provider.dart';
import 'features/dashboard/presentation/today_dashboard_screen.dart';
import 'features/food_log/application/nutrivo_go_store.dart';
import 'features/sync/application/sync_service.dart';
import 'shared/theme/app_theme.dart';

class NutrivoGoApp extends StatefulWidget {
  const NutrivoGoApp({
    super.key,
    this.store,
    this.authController,
    this.syncService,
  });

  final NutrivoGoStore? store;
  final AuthController? authController;
  final SyncService? syncService;

  @override
  State<NutrivoGoApp> createState() => _NutrivoGoAppState();
}

class _NutrivoGoAppState extends State<NutrivoGoApp> {
  AppDatabase? _database;
  late final NutrivoGoStore _store;
  late final bool _ownsStore;
  AuthController? _authController;
  SyncService? _syncService;
  late final bool _ownsAuthController;
  late final bool _ownsSyncService;
  late final bool _ownsDatabase;

  @override
  void initState() {
    super.initState();
    _ownsStore = widget.store == null;
    _ownsAuthController = widget.authController == null && widget.store == null;
    _ownsSyncService = widget.syncService == null && widget.store == null;
    _ownsDatabase = widget.store == null;

    if (widget.store == null) {
      _database = AppDatabase();
      _store = NutrivoGoStore(database: _database);
      final supabaseClient = createSupabaseClient();
      _authController =
          widget.authController ?? AuthController(client: supabaseClient);
      _syncService =
          widget.syncService ??
          SyncService(
            client: supabaseClient,
            database: _database!,
            store: _store,
          );
      return;
    }

    _store = widget.store!;
    _authController = widget.authController;
    _syncService = widget.syncService;
  }

  @override
  void dispose() {
    if (_ownsSyncService) {
      _syncService?.dispose();
    }
    if (_ownsAuthController) {
      _authController?.dispose();
    }
    if (_ownsStore) {
      _store.dispose();
    }
    if (_ownsDatabase) {
      final database = _database;
      if (database != null) {
        unawaited(database.close());
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutrivoGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: TodayDashboardScreen(
        store: _store,
        authController: _authController,
        syncService: _syncService,
      ),
    );
  }
}
