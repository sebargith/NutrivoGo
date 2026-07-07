import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/cost_formatters.dart';
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
  });

  final NutrivoGoStore store;
  final Product product;
  final MealType? initialMealType;

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType ?? MealType.lunch;
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
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Agregar a ${_mealType.label}')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ProductSummary(product: widget.product),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 560;
                      final quantityField = TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_numberInputFormatter],
                        decoration: InputDecoration(
                          labelText: 'Cantidad consumida',
                          prefixIcon: const Icon(Icons.straighten),
                          helperText: quantityHelperText(_unit),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _positiveNumberValidator,
                      );
                      final unitField = DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(
                          labelText: 'Medido en',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: [
                          for (final unit in availableUnits)
                            DropdownMenuItem(
                              value: unit,
                              child: Text(quantityUnitLabel(unit)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _unit = value);
                        },
                      );

                      if (!isWide) {
                        return Column(
                          children: [
                            quantityField,
                            const SizedBox(height: 12),
                            unitField,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: quantityField),
                          const SizedBox(width: 12),
                          Expanded(child: unitField),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 16),
                  _MacroPreview(snapshot: preview, cost: _previewCost()),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.check),
                    label: Text(_isSaving ? 'Guardando' : 'Agregar a hoy'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  double? _parseOptionalNumber(String? value) {
    final text = value?.trim().replaceAll(',', '.');
    if (text == null || text.isEmpty) {
      return null;
    }
    return double.tryParse(text);
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: theme.textTheme.titleLarge),
            if (product.brand?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                product.brand!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.local_fire_department_outlined,
                  text:
                      '${formatMacro(product.caloriesPer100)} kcal / 100${product.baseUnitLabel}',
                ),
                _InfoChip(
                  icon: Icons.fitness_center,
                  text:
                      '${formatMacro(product.proteinPer100, decimals: 1)} g proteínas',
                ),
                if (servingSizeDisplay(product) != null)
                  _InfoChip(
                    icon: Icons.straighten,
                    text: servingSizeDisplay(product)!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Text('Macros calculados', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MacroPill(
                  label: 'Calorías',
                  value: formatMacro(snapshot.calories),
                  unit: 'kcal',
                ),
                _MacroPill(
                  label: 'Proteínas',
                  value: formatMacro(snapshot.protein, decimals: 1),
                  unit: 'g',
                ),
                _MacroPill(
                  label: 'Carbohidratos',
                  value: formatMacro(snapshot.carbs, decimals: 1),
                  unit: 'g',
                ),
                _MacroPill(
                  label: 'Grasas',
                  value: formatMacro(snapshot.fat, decimals: 1),
                  unit: 'g',
                ),
                _MacroPill(label: 'Gasto', value: formatClp(cost), unit: ''),
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
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              unit.isEmpty ? value : '$value $unit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
