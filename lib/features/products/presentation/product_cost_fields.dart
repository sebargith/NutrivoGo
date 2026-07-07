import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/cost_formatters.dart';
import '../../food_log/domain/food_cost_calculator.dart';
import '../domain/product.dart';

class ProductCostFields extends StatelessWidget {
  const ProductCostFields({
    required this.packagePriceController,
    required this.packageQuantityController,
    required this.servingSizeController,
    required this.baseUnit,
    required this.numberInputFormatter,
    super.key,
  });

  final TextEditingController packagePriceController;
  final TextEditingController packageQuantityController;
  final TextEditingController servingSizeController;
  final BaseUnit baseUnit;
  final TextInputFormatter numberInputFormatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Costo', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Se usa para calcular el costo por porción y por registro.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final priceField = _CostNumberField(
              controller: packagePriceController,
              label: 'Precio total del producto (CLP)',
              icon: Icons.payments_outlined,
              numberInputFormatter: numberInputFormatter,
            );
            final quantityField = _CostNumberField(
              controller: packageQuantityController,
              label: 'Cantidad total del producto/envase (${baseUnit.label})',
              icon: Icons.inventory_2_outlined,
              numberInputFormatter: numberInputFormatter,
            );

            if (constraints.maxWidth < 640) {
              return Column(
                children: [
                  priceField,
                  const SizedBox(height: 12),
                  quantityField,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: priceField),
                const SizedBox(width: 12),
                Expanded(child: quantityField),
              ],
            );
          },
        ),
        AnimatedBuilder(
          animation: Listenable.merge([
            packagePriceController,
            packageQuantityController,
            servingSizeController,
          ]),
          builder: (context, _) {
            final packagePrice = parseOptionalCostNumber(
              packagePriceController.text,
            );
            final packageQuantity = parseOptionalCostNumber(
              packageQuantityController.text,
            );
            final servingSize = parseOptionalCostNumber(
              servingSizeController.text,
            );
            final costPer100 = const FoodCostCalculator().costPer100FromPackage(
              packagePriceClp: packagePrice,
              packageQuantity: packageQuantity,
            );
            final costPerServing = const FoodCostCalculator()
                .costPerServingFromPackage(
                  packagePriceClp: packagePrice,
                  packageQuantity: packageQuantity,
                  servingSize: servingSize,
                );

            if (costPer100 == null && costPerServing == null) {
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
                  if (costPer100 != null)
                    _CostChip(
                      label: 'Costo estimado por 100 ${baseUnit.label}',
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
}

class _CostNumberField extends StatelessWidget {
  const _CostNumberField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.numberInputFormatter,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputFormatter numberInputFormatter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [numberInputFormatter],
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
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
    final theme = Theme.of(context);
    return Chip(
      avatar: const Icon(Icons.attach_money, size: 16),
      label: Text('$label: $value'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
