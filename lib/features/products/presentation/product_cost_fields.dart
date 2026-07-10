import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/cost_formatters.dart';
import '../../food_log/domain/food_cost_calculator.dart';
import '../domain/product.dart';

class ProductCostFields extends StatefulWidget {
  const ProductCostFields({
    required this.packagePriceController,
    required this.packageQuantityController,
    required this.servingSizeController,
    required this.unitsPerServingController,
    required this.servingsPerPackageController,
    required this.baseUnit,
    required this.numberInputFormatter,
    super.key,
  });

  final TextEditingController packagePriceController;
  final TextEditingController packageQuantityController;
  final TextEditingController servingSizeController;
  final TextEditingController unitsPerServingController;
  final TextEditingController servingsPerPackageController;
  final BaseUnit baseUnit;
  final TextInputFormatter numberInputFormatter;

  @override
  State<ProductCostFields> createState() => _ProductCostFieldsState();
}

class _ProductCostFieldsState extends State<ProductCostFields> {
  bool _packageQuantityOverridden = false;
  bool _writingEstimate = false;

  @override
  void initState() {
    super.initState();
    _packageQuantityOverridden = !_matchesEstimateOrIsEmpty();
    widget.servingSizeController.addListener(_updateEstimate);
    widget.servingsPerPackageController.addListener(_updateEstimate);
    widget.packageQuantityController.addListener(_handlePackageEdit);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateEstimate());
  }

  @override
  void didUpdateWidget(covariant ProductCostFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.servingSizeController != widget.servingSizeController ||
        oldWidget.servingsPerPackageController !=
            widget.servingsPerPackageController ||
        oldWidget.packageQuantityController !=
            widget.packageQuantityController) {
      oldWidget.servingSizeController.removeListener(_updateEstimate);
      oldWidget.servingsPerPackageController.removeListener(_updateEstimate);
      oldWidget.packageQuantityController.removeListener(_handlePackageEdit);
      widget.servingSizeController.addListener(_updateEstimate);
      widget.servingsPerPackageController.addListener(_updateEstimate);
      widget.packageQuantityController.addListener(_handlePackageEdit);
      _packageQuantityOverridden = !_matchesEstimateOrIsEmpty();
      _updateEstimate();
    }
  }

  @override
  void dispose() {
    widget.servingSizeController.removeListener(_updateEstimate);
    widget.servingsPerPackageController.removeListener(_updateEstimate);
    widget.packageQuantityController.removeListener(_handlePackageEdit);
    super.dispose();
  }

  double? get _estimate {
    final servingSize = parseOptionalCostNumber(
      widget.servingSizeController.text,
    );
    final servings = parseOptionalCostNumber(
      widget.servingsPerPackageController.text,
    );
    if (servingSize == null ||
        servingSize <= 0 ||
        servings == null ||
        servings <= 0) {
      return null;
    }
    return servingSize * servings;
  }

  bool _matchesEstimateOrIsEmpty() {
    final current = parseOptionalCostNumber(
      widget.packageQuantityController.text,
    );
    final estimate = _estimate;
    if (current == null) {
      return true;
    }
    return estimate != null && (current - estimate).abs() < 0.0001;
  }

  void _handlePackageEdit() {
    if (_writingEstimate) {
      return;
    }
    setState(() => _packageQuantityOverridden = true);
  }

  void _updateEstimate() {
    if (!mounted) {
      return;
    }
    if (_packageQuantityOverridden) {
      setState(() {});
      return;
    }
    final estimate = _estimate;
    _writingEstimate = true;
    widget.packageQuantityController.text = estimate == null
        ? ''
        : formatEditableNumber(estimate);
    _writingEstimate = false;
    setState(() {});
  }

  void _recalculate() {
    setState(() => _packageQuantityOverridden = false);
    _updateEstimate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final servingSize = parseOptionalCostNumber(
      widget.servingSizeController.text,
    );
    final unitsPerServing = parseOptionalCostNumber(
      widget.unitsPerServingController.text,
    );
    final servingsPerPackage = parseOptionalCostNumber(
      widget.servingsPerPackageController.text,
    );
    final packageQuantity = parseOptionalCostNumber(
      widget.packageQuantityController.text,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Porción y envase', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _ResponsiveFields(
          children: [
            _OptionalPositiveField(
              controller: widget.servingSizeController,
              label: 'Tamaño de la porción (${widget.baseUnit.label})',
              icon: Icons.straighten,
              formatter: widget.numberInputFormatter,
            ),
            _OptionalPositiveField(
              controller: widget.unitsPerServingController,
              label: 'Unidades por porción',
              icon: Icons.pin_outlined,
              formatter: widget.numberInputFormatter,
            ),
            _OptionalPositiveField(
              controller: widget.servingsPerPackageController,
              label: 'Porciones por envase',
              icon: Icons.grid_view_outlined,
              formatter: widget.numberInputFormatter,
            ),
            _OptionalPositiveField(
              controller: widget.packageQuantityController,
              label:
                  'Cantidad total del producto/envase (${widget.baseUnit.label})',
              icon: Icons.inventory_2_outlined,
              formatter: widget.numberInputFormatter,
              suffixIcon: _estimate == null
                  ? null
                  : IconButton(
                      tooltip: 'Recalcular',
                      onPressed: _recalculate,
                      icon: const Icon(Icons.refresh),
                    ),
            ),
          ],
        ),
        if (_estimate != null) ...[
          const SizedBox(height: 8),
          Text(
            _packageQuantityOverridden
                ? 'Cantidad editada manualmente. Usa Recalcular para volver al valor automático.'
                : 'Calculado automáticamente desde '
                      '${formatSpanishNumber(servingsPerPackage!)} porciones × '
                      '${formatSpanishNumber(servingSize!)} ${widget.baseUnit.label}.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (servingSize != null && servingSize > 0) ...[
          const SizedBox(height: 10),
          _ServingPackageSummary(
            baseUnit: widget.baseUnit,
            servingSize: servingSize,
            unitsPerServing: unitsPerServing,
            servingsPerPackage: servingsPerPackage,
            packageQuantity: packageQuantity,
          ),
        ],
        const SizedBox(height: 20),
        Text('Costo', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Ingresa el precio total. El resto se calcula con los datos del envase.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        _OptionalPositiveField(
          controller: widget.packagePriceController,
          label: 'Precio total del producto (CLP)',
          icon: Icons.payments_outlined,
          formatter: widget.numberInputFormatter,
        ),
        AnimatedBuilder(
          animation: Listenable.merge([
            widget.packagePriceController,
            widget.packageQuantityController,
            widget.servingSizeController,
            widget.unitsPerServingController,
            widget.servingsPerPackageController,
          ]),
          builder: (context, _) {
            final product = _calculationProduct();
            final calculator = const FoodCostCalculator();
            final costPer100 = calculator.costPer100(product);
            final costPerServing = calculator.costPerServing(product);
            final costPerUnit = calculator.costPerUnit(product);
            if (costPer100 == null &&
                costPerServing == null &&
                costPerUnit == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (costPerServing != null)
                    _CostChip(
                      label: 'Costo estimado por porción',
                      value: formatClp(costPerServing),
                    ),
                  if (costPerUnit != null)
                    _CostChip(
                      label: 'Costo estimado por unidad',
                      value: formatClp(costPerUnit),
                    ),
                  if (costPer100 != null)
                    _CostChip(
                      label: 'Costo estimado por 100 ${widget.baseUnit.label}',
                      value: formatClp(costPer100),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Product _calculationProduct() {
    final now = DateTime.fromMillisecondsSinceEpoch(0);
    return Product(
      id: 'cost-preview',
      name: 'Vista previa',
      baseUnit: widget.baseUnit,
      servingSize: parseOptionalCostNumber(widget.servingSizeController.text),
      servingUnit: widget.baseUnit.label,
      unitsPerServing: parseOptionalCostNumber(
        widget.unitsPerServingController.text,
      ),
      servingsPerPackage: parseOptionalCostNumber(
        widget.servingsPerPackageController.text,
      ),
      packagePriceClp: parseOptionalCostNumber(
        widget.packagePriceController.text,
      ),
      packageQuantity: parseOptionalCostNumber(
        widget.packageQuantityController.text,
      ),
      packageQuantityUnit: widget.baseUnit.label,
      caloriesPer100: 0,
      proteinPer100: 0,
      carbsPer100: 0,
      fatPer100: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _ServingPackageSummary extends StatelessWidget {
  const _ServingPackageSummary({
    required this.baseUnit,
    required this.servingSize,
    required this.unitsPerServing,
    required this.servingsPerPackage,
    required this.packageQuantity,
  });

  final BaseUnit baseUnit;
  final double servingSize;
  final double? unitsPerServing;
  final double? servingsPerPackage;
  final double? packageQuantity;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if (unitsPerServing != null && unitsPerServing! > 0)
        '1 porción = ${formatSpanishNumber(unitsPerServing!)} unidades = '
            '${formatSpanishNumber(servingSize)} ${baseUnit.label}'
      else
        '1 porción = ${formatSpanishNumber(servingSize)} ${baseUnit.label}',
      if (unitsPerServing != null && unitsPerServing! > 0)
        '1 unidad ≈ ${formatSpanishNumber(servingSize / unitsPerServing!)} '
            '${baseUnit.label}',
      if (servingsPerPackage != null && servingsPerPackage! > 0)
        'Envase estimado: ${formatSpanishNumber(servingsPerPackage!)} porciones'
            '${unitsPerServing != null && unitsPerServing! > 0 ? ' = ${formatSpanishNumber(unitsPerServing! * servingsPerPackage!)} unidades' : ''}'
            '${packageQuantity != null ? ' = ${formatSpanishNumber(packageQuantity!)} ${baseUnit.label}' : ''}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(line)),
      ],
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children)
              SizedBox(width: (constraints.maxWidth - 12) / 2, child: child),
          ],
        );
      },
    );
  }
}

class _OptionalPositiveField extends StatelessWidget {
  const _OptionalPositiveField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.formatter,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputFormatter formatter;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [formatter],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
      validator: (value) {
        final text = value?.trim();
        if (text == null || text.isEmpty) {
          return null;
        }
        final parsed = parseOptionalCostNumber(text);
        if (parsed == null) {
          return 'Ingresa un número válido';
        }
        if (parsed <= 0) {
          return 'Debe ser mayor que cero';
        }
        return null;
      },
    );
  }
}

class _CostChip extends StatelessWidget {
  const _CostChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.attach_money, size: 16),
      label: Text('$label: $value'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

double? parseOptionalCostNumber(String? value) {
  final text = value?.trim().replaceAll(',', '.');
  if (text == null || text.isEmpty) {
    return null;
  }
  return double.tryParse(text);
}

String formatEditableNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value
      .toStringAsFixed(4)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String formatSpanishNumber(double value) {
  return formatEditableNumber(value).replaceAll('.', ',');
}
