import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/calendar_date.dart';
import '../../../shared/utils/cost_formatters.dart';
import '../../../shared/utils/macro_formatters.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../food_log/domain/consumption_summary.dart';
import '../../food_log/domain/log_item.dart';
import '../../food_log/domain/meal_type.dart';
import '../../food_log/presentation/quantity_display.dart';
import '../../gemini/application/gemini_product_client.dart';
import '../../products/presentation/product_search_screen.dart';

enum _HistoryPeriod { day, week, month }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.store, super.key, this.geminiClient});

  final NutrivoGoStore store;
  final GeminiProductClient? geminiClient;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryPeriod _period = _HistoryPeriod.day;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = calendarDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddFood(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar alimento'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.store,
          builder: (context, _) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    SegmentedButton<_HistoryPeriod>(
                      segments: const [
                        ButtonSegment(
                          value: _HistoryPeriod.day,
                          label: Text('Día'),
                        ),
                        ButtonSegment(
                          value: _HistoryPeriod.week,
                          label: Text('Semana'),
                        ),
                        ButtonSegment(
                          value: _HistoryPeriod.month,
                          label: Text('Mes'),
                        ),
                      ],
                      selected: {_period},
                      onSelectionChanged: (selection) {
                        setState(() => _period = selection.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    _DateNavigator(
                      label: _periodLabel,
                      isToday: isSameCalendarDate(
                        _selectedDate,
                        DateTime.now(),
                      ),
                      onPrevious: () => _moveDate(-1),
                      onNext: () => _moveDate(1),
                      onPick: _pickDate,
                      onToday: () => setState(
                        () => _selectedDate = calendarDate(DateTime.now()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_period == _HistoryPeriod.week) ...[
                      _WeekDayStrip(
                        store: widget.store,
                        start: _weekStart(_selectedDate),
                        selectedDate: _selectedDate,
                        onSelect: (date) =>
                            setState(() => _selectedDate = date),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SummaryCard(summary: _summary, title: _summaryTitle),
                    const SizedBox(height: 20),
                    if (_period == _HistoryPeriod.day) ...[
                      _DailyDetail(
                        store: widget.store,
                        date: _selectedDate,
                        onAdd: (meal) => _openAddFood(context, meal),
                      ),
                      const SizedBox(height: 20),
                      _DaysList(
                        dates: widget.store.consumptionDates,
                        selectedDate: _selectedDate,
                        store: widget.store,
                        onSelect: (date) =>
                            setState(() => _selectedDate = date),
                      ),
                    ] else
                      _PeriodHint(period: _period),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ConsumptionSummary get _summary {
    return switch (_period) {
      _HistoryPeriod.day => widget.store.summaryForDate(_selectedDate),
      _HistoryPeriod.week => widget.store.summaryForRange(
        _weekStart(_selectedDate),
        _weekStart(_selectedDate).add(const Duration(days: 7)),
      ),
      _HistoryPeriod.month => widget.store.summaryForRange(
        DateTime.utc(_selectedDate.year, _selectedDate.month),
        DateTime.utc(_selectedDate.year, _selectedDate.month + 1),
      ),
    };
  }

  String get _summaryTitle => switch (_period) {
    _HistoryPeriod.day => 'Resumen del día',
    _HistoryPeriod.week => 'Resumen de la semana',
    _HistoryPeriod.month => 'Resumen del mes',
  };

  String get _periodLabel => switch (_period) {
    _HistoryPeriod.day => _formatDate(_selectedDate),
    _HistoryPeriod.week =>
      'Semana del ${_formatDate(_weekStart(_selectedDate))}',
    _HistoryPeriod.month =>
      '${_monthName(_selectedDate.month)} ${_selectedDate.year}',
  };

  Future<void> _openAddFood(BuildContext context, [MealType? meal]) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductSearchScreen(
          store: widget.store,
          initialMealType: meal,
          initialConsumedOn: _selectedDate,
          geminiClient: widget.geminiClient,
        ),
      ),
    );
  }

  void _moveDate(int direction) {
    setState(() {
      _selectedDate = switch (_period) {
        _HistoryPeriod.day => _selectedDate.add(Duration(days: direction)),
        _HistoryPeriod.week => _selectedDate.add(Duration(days: 7 * direction)),
        _HistoryPeriod.month => DateTime.utc(
          _selectedDate.year,
          _selectedDate.month + direction,
          1,
        ),
      };
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Seleccionar fecha',
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = calendarDate(picked));
    }
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.label,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
    required this.onToday,
  });

  final String label;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPick;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Anterior',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(label, overflow: TextOverflow.ellipsis),
              ),
            ),
            IconButton(
              tooltip: 'Siguiente',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (!isToday)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onToday,
              child: const Text('Volver a hoy'),
            ),
          ),
      ],
    );
  }
}

class _WeekDayStrip extends StatelessWidget {
  const _WeekDayStrip({
    required this.store,
    required this.start,
    required this.selectedDate,
    required this.onSelect,
  });

  final NutrivoGoStore store;
  final DateTime start;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            for (var index = 0; index < 7; index++)
              Expanded(
                child: _WeekDayRing(
                  date: start.add(Duration(days: index)),
                  calories: store
                      .totalsForDate(start.add(Duration(days: index)))
                      .calories,
                  selected: isSameCalendarDate(
                    start.add(Duration(days: index)),
                    selectedDate,
                  ),
                  onTap: () => onSelect(start.add(Duration(days: index))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekDayRing extends StatelessWidget {
  const _WeekDayRing({
    required this.date,
    required this.calories,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final double calories;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekdays[date.weekday - 1],
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppPalette.ocean : AppPalette.mutedInk,
            ),
          ),
          Text('${date.day}', style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 4),
          Container(
            width: 42,
            height: 42,
            padding: EdgeInsets.all(selected ? 2 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: AppPalette.ocean, width: 2)
                  : null,
            ),
            child: CustomPaint(
              painter: _DayRingPainter(),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      formatMacro(calories),
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const sweep = math.pi * 2 / 3 - 0.08;
    for (final entry in <(double, Color)>[
      (-math.pi / 2, AppPalette.leaf),
      (math.pi / 6, AppPalette.pumpkin),
      (math.pi * 5 / 6, AppPalette.corn),
    ]) {
      paint.color = entry.$2;
      canvas.drawArc(rect.deflate(2), entry.$1 + 0.04, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DayRingPainter oldDelegate) => false;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.title});

  final ConsumptionSummary summary;
  final String title;

  @override
  Widget build(BuildContext context) {
    final macros = summary.totalMacros;
    final average = summary.averageMacros;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Calorías',
                    value: _kcal(macros.calories),
                    color: AppPalette.ocean,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Proteínas',
                    value: _grams(macros.protein),
                    color: AppPalette.leaf,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Carbohidratos',
                    value: _grams(macros.carbs),
                    color: AppPalette.pumpkin,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Grasas',
                    value: _grams(macros.fat),
                    color: AppPalette.corn,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _MacroLine(
              label: 'Promedio diario',
              value: summary.recordedDayCount == 0
                  ? 'Sin registros'
                  : '${_kcal(average.calories)} | ${_grams(average.protein)} P | ${_grams(average.carbs)} C | ${_grams(average.fat)} G',
            ),
            _MacroLine(
              label: 'Gasto registrado',
              value: formatClp(summary.knownCostTotalClp),
            ),
            _MacroLine(
              label: 'Promedio de gasto',
              value: formatClp(summary.averageKnownCostClp),
            ),
            _MacroLine(
              label: 'Días con registros',
              value: '${summary.recordedDayCount}',
            ),
            if (summary.foodsWithoutPrice > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${summary.foodsWithoutPrice} alimentos sin precio',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppPalette.mutedInk, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MacroLine extends StatelessWidget {
  const _MacroLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyDetail extends StatelessWidget {
  const _DailyDetail({
    required this.store,
    required this.date,
    required this.onAdd,
  });

  final NutrivoGoStore store;
  final DateTime date;
  final ValueChanged<MealType> onAdd;

  @override
  Widget build(BuildContext context) {
    final allItems = store.logItemsForDate(date);
    if (allItems.isEmpty) {
      return const _EmptyHistory();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalle del día', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final meal in MealType.values) ...[
          _MealGroup(
            meal: meal,
            items: store.itemsForMeal(meal, consumedOn: date),
            onAdd: () => onAdd(meal),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MealGroup extends StatelessWidget {
  const _MealGroup({
    required this.meal,
    required this.items,
    required this.onAdd,
  });

  final MealType meal;
  final List<LogItem> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  meal.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Agregar a ${meal.label}',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (items.isEmpty)
              const Text('Sin registros')
            else
              for (final item in items) _HistoryLogTile(item: item),
          ],
        ),
      ),
    );
  }
}

class _HistoryLogTile extends StatelessWidget {
  const _HistoryLogTile({required this.item});

  final LogItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(item.product.displayName),
      subtitle: Text(
        '${loggedQuantityDisplay(quantity: item.quantity, unit: item.unit, baseQuantity: item.baseQuantitySnapshot, baseUnit: item.product.baseUnitLabel)} | ${_kcal(item.macros.calories)} | ${_grams(item.macros.protein)} P | ${_grams(item.macros.carbs)} C | ${_grams(item.macros.fat)} G',
      ),
      trailing: Text(formatClp(item.costSnapshotClp)),
    );
  }
}

class _DaysList extends StatelessWidget {
  const _DaysList({
    required this.dates,
    required this.selectedDate,
    required this.store,
    required this.onSelect,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final NutrivoGoStore store;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Días registrados', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final date in dates)
          _HistoryDayTile(
            date: date,
            summary: store.summaryForDate(date),
            selected: isSameCalendarDate(date, selectedDate),
            onTap: () => onSelect(date),
          ),
      ],
    );
  }
}

class _HistoryDayTile extends StatelessWidget {
  const _HistoryDayTile({
    required this.date,
    required this.summary,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final ConsumptionSummary summary;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final macros = summary.totalMacros;
    return Card(
      color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: ListTile(
        onTap: onTap,
        title: Text(_formatDate(date)),
        subtitle: Text(
          '${_kcal(macros.calories)} | ${_grams(macros.protein)} P | ${_grams(macros.carbs)} C | ${_grams(macros.fat)} G',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatClp(summary.knownCostTotalClp)),
            if (summary.foodsWithoutPrice > 0)
              Text('${summary.foodsWithoutPrice} sin precio'),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.history_outlined, size: 32),
            const SizedBox(height: 8),
            Text(
              'Sin registros',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text('Agrega alimentos para ver el resumen de este día.'),
          ],
        ),
      ),
    );
  }
}

class _PeriodHint extends StatelessWidget {
  const _PeriodHint({required this.period});

  final _HistoryPeriod period;

  @override
  Widget build(BuildContext context) {
    final label = period == _HistoryPeriod.week ? 'semana' : 'mes';
    return Text(
      'Los promedios se calculan solo sobre los días con registros de este $label.',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

DateTime _weekStart(DateTime date) {
  final normalized = calendarDate(date);
  return normalized.subtract(
    Duration(days: normalized.weekday - DateTime.monday),
  );
}

String _formatDate(DateTime date) {
  return '${date.day} de ${_monthName(date.month)} de ${date.year}';
}

String _monthName(int month) {
  const names = <String>[
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
  return names[month - 1];
}

String _kcal(double value) => '${formatMacro(value, decimals: 1)} kcal';

String _grams(double value) => '${formatMacro(value, decimals: 1)} g';
