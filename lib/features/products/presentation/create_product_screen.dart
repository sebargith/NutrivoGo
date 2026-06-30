import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../food_log/application/nutrivo_go_store.dart';
import '../domain/product.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({required this.store, super.key});

  final NutrivoGoStore store;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  static final _numberInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9\.,]'),
  );

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _servingUnitController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  BaseUnit _baseUnit = BaseUnit.grams;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _servingSizeController.dispose();
    _servingUnitController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Product name',
                      prefixIcon: Icon(Icons.fastfood_outlined),
                    ),
                    validator: _requiredText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _brandController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Base unit',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<BaseUnit>(
                    segments: const [
                      ButtonSegment(
                        value: BaseUnit.grams,
                        label: Text('g'),
                        icon: Icon(Icons.scale_outlined),
                      ),
                      ButtonSegment(
                        value: BaseUnit.milliliters,
                        label: Text('ml'),
                        icon: Icon(Icons.water_drop_outlined),
                      ),
                    ],
                    selected: {_baseUnit},
                    onSelectionChanged: (selection) {
                      setState(() => _baseUnit = selection.first);
                    },
                  ),
                  const SizedBox(height: 20),
                  _ServingFields(
                    servingSizeController: _servingSizeController,
                    servingUnitController: _servingUnitController,
                    numberInputFormatter: _numberInputFormatter,
                    optionalPositiveNumberValidator: _optionalPositiveNumber,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nutrition per 100${_baseUnit.label}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _NutritionFields(
                    caloriesController: _caloriesController,
                    proteinController: _proteinController,
                    carbsController: _carbsController,
                    fatController: _fatController,
                    numberInputFormatter: _numberInputFormatter,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.check),
                    label: Text(_isSaving ? 'Saving' : 'Save Product'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    final product = await widget.store.addProduct(
      name: _nameController.text,
      brand: _brandController.text,
      servingSize: _parseOptionalNumber(_servingSizeController.text),
      servingUnit: _servingUnitController.text,
      baseUnit: _baseUnit,
      caloriesPer100: _parseRequiredNumber(_caloriesController.text),
      proteinPer100: _parseRequiredNumber(_proteinController.text),
      carbsPer100: _parseRequiredNumber(_carbsController.text),
      fatPer100: _parseRequiredNumber(_fatController.text),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(product);
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _optionalPositiveNumber(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    final parsed = _parseOptionalNumber(text);
    if (parsed == null) {
      return 'Invalid number';
    }
    if (parsed <= 0) {
      return 'Must be greater than 0';
    }
    return null;
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

class _ServingFields extends StatelessWidget {
  const _ServingFields({
    required this.servingSizeController,
    required this.servingUnitController,
    required this.numberInputFormatter,
    required this.optionalPositiveNumberValidator,
  });

  final TextEditingController servingSizeController;
  final TextEditingController servingUnitController;
  final TextInputFormatter numberInputFormatter;
  final FormFieldValidator<String> optionalPositiveNumberValidator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final fields = [
          TextFormField(
            controller: servingSizeController,
            keyboardType: TextInputType.number,
            inputFormatters: [numberInputFormatter],
            decoration: const InputDecoration(
              labelText: 'Serving size',
              prefixIcon: Icon(Icons.straighten),
            ),
            validator: optionalPositiveNumberValidator,
          ),
          TextFormField(
            controller: servingUnitController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Serving unit',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
        ];

        if (!isWide) {
          return Column(
            children: [fields[0], const SizedBox(height: 12), fields[1]],
          );
        }

        return Row(
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 12),
            Expanded(child: fields[1]),
          ],
        );
      },
    );
  }
}

class _NutritionFields extends StatelessWidget {
  const _NutritionFields({
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
    required this.numberInputFormatter,
  });

  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;
  final TextInputFormatter numberInputFormatter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = [
          _NumberField(
            controller: caloriesController,
            label: 'Calories',
            icon: Icons.local_fire_department_outlined,
            numberInputFormatter: numberInputFormatter,
          ),
          _NumberField(
            controller: proteinController,
            label: 'Protein',
            icon: Icons.fitness_center,
            numberInputFormatter: numberInputFormatter,
          ),
          _NumberField(
            controller: carbsController,
            label: 'Carbs',
            icon: Icons.grain,
            numberInputFormatter: numberInputFormatter,
          ),
          _NumberField(
            controller: fatController,
            label: 'Fat',
            icon: Icons.water_drop_outlined,
            numberInputFormatter: numberInputFormatter,
          ),
        ];

        if (constraints.maxWidth < 640) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index != fields.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 12),
                Expanded(child: fields[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: fields[2]),
                const SizedBox(width: 12),
                Expanded(child: fields[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
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
      validator: _requiredPositiveNumber,
    );
  }

  String? _requiredPositiveNumber(String? value) {
    final text = value?.trim().replaceAll(',', '.');
    final parsed = text == null || text.isEmpty ? null : double.tryParse(text);
    if (parsed == null) {
      return 'Required';
    }
    if (parsed < 0) {
      return 'Must be 0 or more';
    }
    return null;
  }
}
