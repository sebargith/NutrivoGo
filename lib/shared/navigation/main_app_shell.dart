import 'package:flutter/material.dart';

import '../../core/auth/auth_controller.dart';
import '../../features/dashboard/presentation/today_dashboard_screen.dart';
import '../../features/food_log/application/nutrivo_go_store.dart';
import '../../features/gemini/application/gemini_product_client.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/products/presentation/product_search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/sync/application/sync_service.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({
    required this.store,
    super.key,
    this.authController,
    this.syncService,
    this.geminiClient,
  });

  final NutrivoGoStore store;
  final AuthController? authController;
  final SyncService? syncService;
  final GeminiProductClient? geminiClient;

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TodayDashboardScreen(
            store: widget.store,
            authController: widget.authController,
            syncService: widget.syncService,
            geminiClient: widget.geminiClient,
          ),
          HistoryScreen(store: widget.store, geminiClient: widget.geminiClient),
          ProductSearchScreen(
            store: widget.store,
            geminiClient: widget.geminiClient,
            isProductTab: true,
          ),
          SettingsScreen(
            store: widget.store,
            authController: widget.authController,
            syncService: widget.syncService,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
