import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/cost_formatters.dart';
import '../../../shared/utils/calendar_date.dart';
import '../../../shared/utils/macro_formatters.dart';
import '../../products/domain/product.dart';
import '../application/nutrivo_go_store.dart';
import '../domain/food_cost_calculator.dart';
import '../domain/log_item.dart';
import '../domain/macro_calculator.dart';
import '../domain/macro_snapshot.dart';
import '../domain/meal_type.dart';
import 'quantity_display.dart';

class AddFoodQuantityScreen extends StatefulWidget {
  const AddFoodQuantityScreen({
    required this.store,
    required this.product,
    super.key,
    this.initialMealType,
    this.initialConsumedOn,
  });

  final NutrivoGoStore store;
  final Product product;
  final MealType? initialMealType;
  final DateTime? initialConsumedOn;

  @override
  State<AddFoodQuantityScreen> createState() => _AddFoodQuantityScreenState();
}

class _AddFoodQuantityScreenState extends State<AddFoodQuantityScreen> {
  static final _numberInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9\.,]'),
  );

  final _formKey = GlobalKey<FormState>();
  final _calculator = const MacroCalculator();
  final _costCalculator = const FoodCostCalculator();
  late final TextEditingController _quantityController;
  late String _unit;
  late MealType _mealType;
  late DateTime _consumedOn;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType ?? MealType.lunch;
    _consumedOn = calendarDate(widget.initialConsumedOn ?? DateTime.now());
    final hasServing = widget.product.servingSize != null;
    _unit = hasServing ? 'serving' : widget.product.baseUnitLabel;
    final initialQuantity = hasServing ? 1.0 : 100.0;
    _quantityController = TextEditingController(
      text: formatQuantity(initialQuantity),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewMacros();
    final availableUnits = [
      widget.product.baseUnitLabel,
      if (widget.product.servingSize != null) 'serving',
      if (widget.product.baseQuantityPerUnit != null) 'unit',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar alimento')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                children: [
                  _ProductSummary(product: widget.product),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final diameter = (constraints.maxWidth - 112).clamp(
                        190.0,
                        280.0,
                      );
                      return _CircularQuantityInput(
                        diameter: diameter,
                        controller: _quantityController,
                        formatter: _numberInputFormatter,
                        unit: _unit,
                        validationMessage: _positiveNumberValidator(
                          _quantityController.text,
                        ),
                        onDecrease: () => _adjustQuantity(-1),
                        onIncrease: () => _adjustQuantity(1),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      for (final unit in availableUnits)
                        ButtonSegment(
                          value: unit,
                          label: Text(quantityUnitShortLabel(unit)),
                        ),
                    ],
                    selected: {_unit},
                    onSelectionChanged: (selection) {
                      setState(() => _unit = selection.first);
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quantityHelperText(_unit),
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppPalette.mutedInk),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Asignar a comida',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<MealType>(
                    initialValue: _mealType,
                    decoration: const InputDecoration(
                      labelText: 'Comida',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    items: [
                      for (final meal in MealType.values)
                        DropdownMenuItem(value: meal, child: Text(meal.label)),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _mealType = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Fecha de consumo'),
                      subtitle: Text(_formatDate(_consumedOn)),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: _pickConsumedOn,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MacroPreview(snapshot: preview, cost: _previewCost()),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.check),
                    label: Text(
                      _isSaving
                          ? 'Guardando'
                          : isSameCalendarDate(_consumedOn, DateTime.now())
                          ? 'Registrar en ${_mealType.label}'
                          : 'Registrar el ${_formatDate(_consumedOn)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _adjustQuantity(int direction) {
    final current = _parseOptionalNumber(_quantityController.text) ?? 0;
    final step = _unit == 'g' || _unit == 'ml' ? 10.0 : 1.0;
    final next = (current + direction * step).clamp(step, 99999.0);
    _quantityController.text = formatQuantity(next);
  }

  MacroSnapshot _previewMacros() {
    final quantity = _parseOptionalNumber(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      return const MacroSnapshot.zero();
    }
    try {
      return _calculator.calculateFromProduct(
        product: widget.product,
        quantity: quantity,
        unit: _unit,
      );
    } on ArgumentError {
      return const MacroSnapshot.zero();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    final item = await widget.store.addLogItem(
      product: widget.product,
      quantity: _parseRequiredNumber(_quantityController.text),
      unit: _unit,
      mealType: _mealType,
      consumedOn: _consumedOn,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop<LogItem>(item);
  }

  String? _positiveNumberValidator(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return 'Ingresa la cantidad consumida';
    }
    final parsed = _parseOptionalNumber(text);
    if (parsed == null) {
      return 'Ingresa un número válido';
    }
    if (parsed <= 0) {
      return 'La cantidad debe ser mayor que cero';
    }
    return null;
  }

  double? _previewCost() {
    final quantity = _parseOptionalNumber(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      return null;
    }
    try {
      return _costCalculator.calculateLogCost(
        product: widget.product,
        quantity: quantity,
        unit: _unit,
      );
    } on ArgumentError {
      return null;
    }
  }

  double _parseRequiredNumber(String value) {
    return double.parse(value.trim().replaceAll(',', '.'));
  }

  Future<void> _pickConsumedOn() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _consumedOn,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Fecha de consumo',
    );
    if (selected != null && mounted) {
      setState(() => _consumedOn = calendarDate(selected));
    }
  }

  String _formatDate(DateTime date) {
    const months = <String>[
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
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  double? _parseOptionalNumber(String? value) {
    final text = value?.trim().replaceAll(',', '.');
    if (text == null || text.isEmpty) {
      return null;
    }
    return double.tryParse(text);
  }
}

class _CircularQuantityInput extends StatelessWidget {
  const _CircularQuantityInput({
    required this.diameter,
    required this.controller,
    required this.formatter,
    required this.unit,
    required this.validationMessage,
    required this.onDecrease,
    required this.onIncrease,
  });

  final double diameter;
  final TextEditingController controller;
  final TextInputFormatter formatter;
  final String unit;
  final String? validationMessage;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuantityButton(
          tooltip: 'Disminuir cantidad',
          icon: Icons.remove,
          onPressed: onDecrease,
        ),
        const SizedBox(width: 12),
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppPalette.paper,
            border: Border.all(color: AppPalette.ocean, width: 7),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [formatter],
                    validator: (value) => validationMessage,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppPalette.ocean,
                      fontSize: 34,
                    ),
                    decoration: const InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 0, height: 0),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Text(
                    quantityUnitShortLabel(unit),
                    style: const TextStyle(
                      color: AppPalette.mutedInk,
                      fontSize: 13,
                    ),
                  ),
                  if (validationMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      validationMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppPalette.beet,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _QuantityButton(
          tooltip: 'Aumentar cantidad',
          icon: Icons.add,
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: AppPalette.ocean,
      iconSize: 28,
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppPalette.mist.withValues(alpha: 0.55),
            border: Border.all(color: AppPalette.outline),
          ),
          child: const Icon(
            Icons.rice_bowl_outlined,
            color: AppPalette.ocean,
            size: 42,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: theme.textTheme.titleLarge),
              if (product.brand?.isNotEmpty == true)
                Text(
                  product.brand!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppPalette.mutedInk,
                  ),
                ),
              const SizedBox(height: 5),
              Text(
                '${formatMacro(product.caloriesPer100)} kcal / 100 ${product.baseUnitLabel}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppPalette.mutedInk,
                ),
              ),
              if (servingSizeDisplay(product) != null)
                Text(
                  servingSizeDisplay(product)!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPalette.mutedInk,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroPreview extends StatelessWidget {
  const _MacroPreview({required this.snapshot, required this.cost});

  final MacroSnapshot snapshot;
  final double? cost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vista previa nutricional',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MacroPill(
                    label: 'Calorías',
                    value: formatMacro(snapshot.calories),
                    unit: 'kcal',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MacroPill(
                    label: 'Proteínas',
                    value: formatMacro(snapshot.protein, decimals: 1),
                    unit: 'g',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MacroPill(
                    label: 'Carbohidratos',
                    value: formatMacro(snapshot.carbs, decimals: 1),
                    unit: 'g',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MacroPill(
                    label: 'Grasas',
                    value: formatMacro(snapshot.fat, decimals: 1),
                    unit: 'g',
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 20),
                const SizedBox(width: 8),
                const Text('Costo estimado'),
                const Spacer(),
                Text(formatClp(cost), style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
      decoration: BoxDecoration(
        color: AppPalette.porcelain,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              unit.isEmpty ? value : '$value $unit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppPalette.mutedInk,
            ),
          ),
        ],
      ),
    );
  }
}
