import 'package:flutter/material.dart';

import 'features/dashboard/presentation/today_dashboard_screen.dart';
import 'features/food_log/application/nutrivo_go_store.dart';
import 'shared/theme/app_theme.dart';

class NutrivoGoApp extends StatefulWidget {
  const NutrivoGoApp({super.key, this.store});

  final NutrivoGoStore? store;

  @override
  State<NutrivoGoApp> createState() => _NutrivoGoAppState();
}

class _NutrivoGoAppState extends State<NutrivoGoApp> {
  late final NutrivoGoStore _store;
  late final bool _ownsStore;

  @override
  void initState() {
    super.initState();
    _ownsStore = widget.store == null;
    _store = widget.store ?? NutrivoGoStore();
  }

  @override
  void dispose() {
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutrivoGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: TodayDashboardScreen(store: _store),
    );
  }
}
