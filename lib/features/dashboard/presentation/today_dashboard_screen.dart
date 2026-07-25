import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/cost_formatters.dart';
import '../../../shared/utils/macro_formatters.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../food_log/domain/log_item.dart';
import '../../food_log/domain/macro_snapshot.dart';
import '../../food_log/domain/meal_type.dart';
import '../../food_log/presentation/quantity_display.dart';
import '../../gemini/application/gemini_product_client.dart';
import '../../history/presentation/history_screen.dart';
import '../../products/presentation/product_search_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../sync/application/sync_service.dart';

class TodayDashboardScreen extends StatelessWidget {
  const TodayDashboardScreen({
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoy'),
        leading: syncService == null
            ? null
            : _SyncStatusAction(
                syncService: syncService!,
                onPressed: () => _openSettings(context),
              ),
        actions: [
          IconButton(
            tooltip: 'Abrir historial',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _openHistory(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Center(
                      child: Text(
                        _formatDate(DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.mutedInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _NutritionPlate(totals: store.dailyTotals),
                    const SizedBox(height: 18),
                    _DailySpend(
                      value: store.dailyCostClp,
                      hasUnknown: store.hasUnknownDailyCosts,
                    ),
                    const SizedBox(height: 10),
                    _MealsPanel(
                      store: store,
                      onAdd: (meal) => _openAddFood(context, meal),
                      onRemove: (id) => unawaited(store.removeLogItem(id)),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _openAddFood(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Agregar alimento'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openAddFood(BuildContext context, [MealType? mealType]) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductSearchScreen(
          store: store,
          initialMealType: mealType,
          geminiClient: geminiClient,
        ),
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          store: store,
          authController: authController,
          syncService: syncService,
        ),
      ),
    );
  }

  Future<void> _openHistory(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(store: store, geminiClient: geminiClient),
      ),
    );
  }
}

class _SyncStatusAction extends StatelessWidget {
  const _SyncStatusAction({required this.syncService, required this.onPressed});

  final SyncService syncService;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: syncService,
      builder: (context, _) {
        return IconButton(
          tooltip: _tooltip,
          icon: Icon(_icon),
          color: _color,
          onPressed: onPressed,
        );
      },
    );
  }

  IconData get _icon {
    if (syncService.isSyncing) {
      return Icons.sync;
    }
    if (syncService.status == SyncRunStatus.failed) {
      return Icons.cloud_off_outlined;
    }
    if (syncService.pendingCount > 0) {
      return Icons.cloud_upload_outlined;
    }
    if (syncService.status == SyncRunStatus.synced) {
      return Icons.cloud_done_outlined;
    }
    return Icons.cloud_queue_outlined;
  }

  String get _tooltip {
    if (syncService.isSyncing) {
      return 'Sincronizando';
    }
    if (syncService.pendingCount > 0) {
      return '${syncService.pendingCount} cambios pendientes';
    }
    if (syncService.status == SyncRunStatus.failed) {
      return 'La sincronización requiere atención';
    }
    return 'Estado de sincronización';
  }

  Color? get _color {
    if (syncService.status == SyncRunStatus.failed) {
      return AppPalette.beet;
    }
    if (syncService.pendingCount > 0) {
      return AppPalette.pumpkin;
    }
    return AppPalette.ocean;
  }
}

class _NutritionPlate extends StatelessWidget {
  const _NutritionPlate({required this.totals});

  final MacroSnapshot totals;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 280.0);
        return Center(
          child: SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.paper,
                border: Border.all(color: AppPalette.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x160F2F3E),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: const _PlatePainter()),
                    Center(
                      child: Container(
                        width: size * 0.38,
                        height: size * 0.38,
                        decoration: BoxDecoration(
                          color: AppPalette.paper,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppPalette.outline),
                          boxShadow: const [
                            BoxShadow(color: Color(0x120F2F3E), blurRadius: 8),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatMacro(totals.calories),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppPalette.ocean,
                                        fontSize: 32,
                                      ),
                                ),
                                const Text(
                                  'kcal',
                                  style: TextStyle(
                                    color: AppPalette.mutedInk,
                                    fontSize: 12,
                                  ),
                                ),
                                const Text(
                                  'Calorías',
                                  style: TextStyle(
                                    color: AppPalette.mutedInk,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(-0.58, -0.2),
                      child: _PlateLabel(
                        icon: Icons.eco_outlined,
                        label: 'Proteínas',
                        value: '${formatMacro(totals.protein, decimals: 1)} g',
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.62, -0.2),
                      child: _PlateLabel(
                        icon: Icons.grass_outlined,
                        label: 'Carbohidratos',
                        value: '${formatMacro(totals.carbs, decimals: 1)} g',
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.7),
                      child: _PlateLabel(
                        icon: Icons.water_drop_outlined,
                        label: 'Grasas',
                        value: '${formatMacro(totals.fat, decimals: 1)} g',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlatePainter extends CustomPainter {
  const _PlatePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.24;
    final inset = stroke / 2 + 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    const gap = 0.045;
    const sweep = math.pi * 2 / 3 - gap * 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    paint.color = AppPalette.leaf;
    canvas.drawArc(rect, math.pi * 0.82 + gap, sweep, false, paint);
    paint.color = AppPalette.pumpkin;
    canvas.drawArc(rect, -math.pi * 0.5 + gap, sweep, false, paint);
    paint.color = AppPalette.corn;
    canvas.drawArc(rect, math.pi * 0.16 + gap, sweep, false, paint);

    final separators = Paint()
      ..color = AppPalette.paper
      ..strokeWidth = 5;
    for (final angle in [-math.pi / 2, math.pi / 6, math.pi * 5 / 6]) {
      final center = rect.center;
      final innerRadius = rect.width / 2 - stroke / 2;
      final outerRadius = rect.width / 2 + stroke / 2;
      canvas.drawLine(
        center +
            Offset(
              math.cos(angle) * innerRadius,
              math.sin(angle) * innerRadius,
            ),
        center +
            Offset(
              math.cos(angle) * outerRadius,
              math.sin(angle) * outerRadius,
            ),
        separators,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlatePainter oldDelegate) => false;
}

class _PlateLabel extends StatelessWidget {
  const _PlateLabel({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailySpend extends StatelessWidget {
  const _DailySpend({required this.value, required this.hasUnknown});

  final double? value;
  final bool hasUnknown;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: const Text('Gasto del día'),
        subtitle: hasUnknown ? const Text('Hay alimentos sin precio') : null,
        trailing: Text(
          formatClp(value),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _MealsPanel extends StatelessWidget {
  const _MealsPanel({
    required this.store,
    required this.onAdd,
    required this.onRemove,
  });

  final NutrivoGoStore store;
  final ValueChanged<MealType> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < MealType.values.length; index++) ...[
            _MealRow(
              meal: MealType.values[index],
              items: store.itemsForMeal(MealType.values[index]),
              cost: store.costForMeal(MealType.values[index]),
              onAdd: () => onAdd(MealType.values[index]),
              onRemove: onRemove,
            ),
            if (index < MealType.values.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.meal,
    required this.items,
    required this.cost,
    required this.onAdd,
    required this.onRemove,
  });

  final MealType meal;
  final List<LogItem> items;
  final double? cost;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final calories = items.fold<double>(
      0,
      (total, item) => total + item.macros.calories,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 6, 2),
      child: Column(
        children: [
          Row(
            children: [
              _MealIcon(meal: meal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meal.label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (cost != null) ...[
                Text(
                  formatClp(cost),
                  style: const TextStyle(
                    color: AppPalette.mutedInk,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${formatMacro(calories)} kcal',
                style: const TextStyle(
                  color: AppPalette.mutedInk,
                  fontSize: 12,
                ),
              ),
              IconButton(
                tooltip: 'Agregar a ${meal.label}',
                onPressed: onAdd,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle, color: AppPalette.ocean),
              ),
            ],
          ),
          if (items.isNotEmpty)
            for (final item in items)
              _LogItemLine(item: item, onRemove: onRemove),
        ],
      ),
    );
  }
}

class _MealIcon extends StatelessWidget {
  const _MealIcon({required this.meal});

  final MealType meal;

  @override
  Widget build(BuildContext context) {
    final icon = switch (meal) {
      MealType.breakfast => Icons.free_breakfast_outlined,
      MealType.lunch => Icons.rice_bowl_outlined,
      MealType.afternoon => Icons.local_cafe_outlined,
      MealType.dinner => Icons.dinner_dining_outlined,
      MealType.snack => Icons.apple_outlined,
    };
    return Icon(icon, color: AppPalette.ocean, size: 22);
  }
}

class _LogItemLine extends StatelessWidget {
  const _LogItemLine({required this.item, required this.onRemove});

  final LogItem item;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: AppPalette.beet.withValues(alpha: 0.12),
        padding: const EdgeInsets.only(right: 12),
        child: const Icon(Icons.delete_outline, color: AppPalette.beet),
      ),
      onDismissed: (_) => onRemove(item.id),
      child: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: ListTile(
          dense: true,
          minVerticalPadding: 0,
          contentPadding: EdgeInsets.zero,
          title: Text(
            item.product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            loggedQuantityDisplay(
              quantity: item.quantity,
              unit: item.unit,
              baseQuantity: item.baseQuantitySnapshot,
              baseUnit: item.product.baseUnitLabel,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${formatMacro(item.macros.calories)} kcal'),
              IconButton(
                tooltip: 'Eliminar',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onRemove(item.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const weekdays = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}
