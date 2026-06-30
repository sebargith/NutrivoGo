import 'package:flutter/material.dart';

import '../../../shared/utils/macro_formatters.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../food_log/domain/log_item.dart';
import '../../food_log/domain/macro_snapshot.dart';
import '../../food_log/domain/meal_type.dart';
import '../../products/presentation/product_search_screen.dart';

class TodayDashboardScreen extends StatelessWidget {
  const TodayDashboardScreen({required this.store, super.key});

  final NutrivoGoStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutrivoGo'),
        actions: [
          IconButton(
            tooltip: 'Products',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => _openAddFood(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddFood(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    _Header(date: DateTime.now()),
                    const SizedBox(height: 16),
                    _MacroGrid(totals: store.dailyTotals),
                    const SizedBox(height: 20),
                    for (final meal in MealType.values) ...[
                      _MealSection(
                        mealType: meal,
                        items: store.itemsForMeal(meal),
                        onRemove: store.removeLogItem,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openAddFood(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductSearchScreen(store: store),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                MaterialLocalizations.of(context).formatFullDate(date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.calendar_today_outlined, size: 28),
      ],
    );
  }
}

class _MacroGrid extends StatelessWidget {
  const _MacroGrid({required this.totals});

  final MacroSnapshot totals;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: columns == 4 ? 1.75 : 1.55,
          children: [
            _MacroCard(
              label: 'Calories',
              value: formatMacro(totals.calories),
              unit: 'kcal',
              icon: Icons.local_fire_department_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            _MacroCard(
              label: 'Protein',
              value: formatMacro(totals.protein, decimals: 1),
              unit: 'g',
              icon: Icons.fitness_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            _MacroCard(
              label: 'Carbs',
              value: formatMacro(totals.carbs, decimals: 1),
              unit: 'g',
              icon: Icons.grain,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            _MacroCard(
              label: 'Fat',
              value: formatMacro(totals.fat, decimals: 1),
              unit: 'g',
              icon: Icons.water_drop_outlined,
              color: const Color(0xFFFF8A65),
            ),
          ],
        );
      },
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: value,
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.mealType,
    required this.items,
    required this.onRemove,
  });

  final MealType mealType;
  final List<LogItem> items;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calories = items.fold<double>(
      0,
      (total, item) => total + item.macros.calories,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mealType.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${formatMacro(calories)} kcal',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (items.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'No food logged',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              for (final item in items)
                _LogItemTile(item: item, onRemove: onRemove),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogItemTile extends StatelessWidget {
  const _LogItemTile({required this.item, required this.onRemove});

  final LogItem item;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        item.product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${formatQuantity(item.quantity)} ${item.unit} - '
        '${formatMacro(item.macros.protein, decimals: 1)}P  '
        '${formatMacro(item.macros.carbs, decimals: 1)}C  '
        '${formatMacro(item.macros.fat, decimals: 1)}F',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${formatMacro(item.macros.calories)} kcal',
            style: theme.textTheme.labelLarge,
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close),
            onPressed: () => onRemove(item.id),
          ),
        ],
      ),
    );
  }
}
