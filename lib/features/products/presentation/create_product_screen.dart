import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../food_log/application/nutrivo_go_store.dart';
import '../domain/product.dart';
import 'product_cost_fields.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({
    required this.store,
    super.key,
    this.product,
    this.initialBarcode,
  });

  final NutrivoGoStore store;
  final Product? product;
  final String? initialBarcode;

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
  final _barcodeController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _unitsPerServingController = TextEditingController();
  final _servingsPerPackageController = TextEditingController();
  final _packagePriceController = TextEditingController();
  final _packageQuantityController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _sugarController = TextEditingController();
  final _saturatedFatController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _fiberController = TextEditingController();
  BaseUnit _baseUnit = BaseUnit.grams;
  bool _isSaving = false;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product == null) {
      _barcodeController.text = widget.initialBarcode ?? '';
      return;
    }
    _nameController.text = product.name;
    _brandController.text = product.brand ?? '';
    _barcodeController.text = product.barcode ?? '';
    _servingSizeController.text = _formatOptionalInputNumber(
      product.servingSize,
    );
    _packagePriceController.text = _formatOptionalInputNumber(
      product.packagePriceClp,
    );
    _packageQuantityController.text = _formatOptionalInputNumber(
      product.packageQuantity,
    );
    _unitsPerServingController.text = _formatOptionalInputNumber(
      product.unitsPerServing,
    );
    _servingsPerPackageController.text = _formatOptionalInputNumber(
      product.servingsPerPackage,
    );
    _caloriesController.text = _formatInputNumber(product.caloriesPer100);
    _proteinController.text = _formatInputNumber(product.proteinPer100);
    _carbsController.text = _formatInputNumber(product.carbsPer100);
    _fatController.text = _formatInputNumber(product.fatPer100);
    _sugarController.text = _formatOptionalInputNumber(product.sugarPer100);
    _saturatedFatController.text = _formatOptionalInputNumber(
      product.saturatedFatPer100,
    );
    _sodiumController.text = _formatOptionalInputNumber(product.sodiumPer100);
    _fiberController.text = _formatOptionalInputNumber(product.fiberPer100);
    _baseUnit = product.baseUnit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _servingSizeController.dispose();
    _unitsPerServingController.dispose();
    _servingsPerPackageController.dispose();
    _packagePriceController.dispose();
    _packageQuantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _saturatedFatController.dispose();
    _sodiumController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Crear producto'),
      ),
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
                      labelText: 'Nombre del producto',
                      prefixIcon: Icon(Icons.fastfood_outlined),
                    ),
                    validator: _requiredText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _brandController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _barcodeController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Código de barras',
                      prefixIcon: Icon(Icons.qr_code_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Unidad base',
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
                  ProductCostFields(
                    packagePriceController: _packagePriceController,
                    packageQuantityController: _packageQuantityController,
                    servingSizeController: _servingSizeController,
                    unitsPerServingController: _unitsPerServingController,
                    servingsPerPackageController: _servingsPerPackageController,
                    baseUnit: _baseUnit,
                    numberInputFormatter: _numberInputFormatter,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _baseUnit == BaseUnit.milliliters
                        ? 'Por 100 ml'
                        : 'Por 100 g',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _ResponsiveFields(
                    children: [
                      _RequiredNumberField(
                        controller: _caloriesController,
                        label: 'Energía / Calorías (kcal)',
                        errorLabel: 'calorias',
                        icon: Icons.local_fire_department_outlined,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                      _RequiredNumberField(
                        controller: _proteinController,
                        label: 'Proteínas (g)',
                        errorLabel: 'proteinas',
                        icon: Icons.fitness_center,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                      _RequiredNumberField(
                        controller: _carbsController,
                        label: 'Carbohidratos (g)',
                        errorLabel: 'carbohidratos',
                        icon: Icons.grain,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                      _RequiredNumberField(
                        controller: _fatController,
                        label: 'Grasas (g)',
                        errorLabel: 'grasas',
                        icon: Icons.water_drop_outlined,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                      _OptionalNumberField(
                        controller: _sugarController,
                        label: 'Azúcares (g)',
                        icon: Icons.cookie_outlined,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                      _OptionalNumberField(
                        controller: _saturatedFatController,
                        label: 'Grasas saturadas (g)',
                        icon: Icons.opacity,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                      _OptionalNumberField(
                        controller: _sodiumController,
                        label: 'Sodio (mg)',
                        icon: Icons.science_outlined,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                      _OptionalNumberField(
                        controller: _fiberController,
                        label: 'Fibra (g)',
                        icon: Icons.spa_outlined,
                        numberInputFormatter: _numberInputFormatter,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.check),
                    label: Text(_isSaving ? 'Guardando' : 'Guardar producto'),
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
    final editingProduct = widget.product;
    final servingSize = _parseOptionalNumber(_servingSizeController.text);
    final servingUnit = servingSize == null ? null : _baseUnit.label;
    final barcode = _barcodeController.text.trim();
    final product = editingProduct == null
        ? await widget.store.addProduct(
            name: _nameController.text,
            brand: _brandController.text,
            servingSize: servingSize,
            servingUnit: servingUnit,
            baseUnit: _baseUnit,
            caloriesPer100: _parseRequiredNumber(_caloriesController.text),
            proteinPer100: _parseRequiredNumber(_proteinController.text),
            carbsPer100: _parseRequiredNumber(_carbsController.text),
            fatPer100: _parseRequiredNumber(_fatController.text),
            barcode: barcode,
            source: barcode.isEmpty ? null : 'barcode',
            sugarPer100: _parseOptionalNumber(_sugarController.text),
            saturatedFatPer100: _parseOptionalNumber(
              _saturatedFatController.text,
            ),
            sodiumPer100: _parseOptionalNumber(_sodiumController.text),
            fiberPer100: _parseOptionalNumber(_fiberController.text),
            packagePriceClp: _parseOptionalNumber(_packagePriceController.text),
            packageQuantity: _parseOptionalNumber(
              _packageQuantityController.text,
            ),
            packageQuantityUnit: _packageQuantityController.text.trim().isEmpty
                ? null
                : _baseUnit.label,
            unitsPerServing: _parseOptionalNumber(
              _unitsPerServingController.text,
            ),
            servingsPerPackage: _parseOptionalNumber(
              _servingsPerPackageController.text,
            ),
          )
        : await widget.store.updateProduct(
            editingProduct,
            name: _nameController.text,
            brand: _brandController.text,
            servingSize: servingSize,
            servingUnit: servingUnit,
            clearServingSize: _servingSizeController.text.trim().isEmpty,
            baseUnit: _baseUnit,
            caloriesPer100: _parseRequiredNumber(_caloriesController.text),
            proteinPer100: _parseRequiredNumber(_proteinController.text),
            carbsPer100: _parseRequiredNumber(_carbsController.text),
            fatPer100: _parseRequiredNumber(_fatController.text),
            barcode: barcode,
            source: barcode.isEmpty ? null : editingProduct.source ?? 'barcode',
            clearBarcode: barcode.isEmpty,
            clearSource: barcode.isEmpty,
            sugarPer100: _parseOptionalNumber(_sugarController.text),
            saturatedFatPer100: _parseOptionalNumber(
              _saturatedFatController.text,
            ),
            sodiumPer100: _parseOptionalNumber(_sodiumController.text),
            fiberPer100: _parseOptionalNumber(_fiberController.text),
            clearSugar: _sugarController.text.trim().isEmpty,
            clearSaturatedFat: _saturatedFatController.text.trim().isEmpty,
            clearSodium: _sodiumController.text.trim().isEmpty,
            clearFiber: _fiberController.text.trim().isEmpty,
            packagePriceClp: _parseOptionalNumber(_packagePriceController.text),
            packageQuantity: _parseOptionalNumber(
              _packageQuantityController.text,
            ),
            packageQuantityUnit: _packageQuantityController.text.trim().isEmpty
                ? null
                : _baseUnit.label,
            clearPackagePrice: _packagePriceController.text.trim().isEmpty,
            clearPackageQuantity: _packageQuantityController.text
                .trim()
                .isEmpty,
            unitsPerServing: _parseOptionalNumber(
              _unitsPerServingController.text,
            ),
            servingsPerPackage: _parseOptionalNumber(
              _servingsPerPackageController.text,
            ),
            clearUnitsPerServing: _unitsPerServingController.text
                .trim()
                .isEmpty,
            clearServingsPerPackage: _servingsPerPackageController.text
                .trim()
                .isEmpty,
          );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(product);
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del producto es obligatorio';
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

  String _formatInputNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  String _formatOptionalInputNumber(double? value) {
    if (value == null) {
      return '';
    }
    return _formatInputNumber(value);
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

class _RequiredNumberField extends StatelessWidget {
  const _RequiredNumberField({
    required this.controller,
    required this.label,
    required this.errorLabel,
    required this.icon,
    required this.numberInputFormatter,
  });

  final TextEditingController controller;
  final String label;
  final String errorLabel;
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
        final parsed = _parseOptionalNumber(value);
        if (parsed == null) {
          return 'Ingresa $errorLabel';
        }
        if (parsed < 0) {
          return 'Debe ser 0 o más';
        }
        return null;
      },
    );
  }
}

class _OptionalNumberField extends StatelessWidget {
  const _OptionalNumberField({
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
        final parsed = _parseOptionalNumber(text);
        if (parsed == null) {
          return 'Ingresa un numero valido';
        }
        if (parsed < 0) {
          return 'Debe ser 0 o más';
        }
        return null;
      },
    );
  }
}

double? _parseOptionalNumber(String? value) {
  final text = value?.trim().replaceAll(',', '.');
  if (text == null || text.isEmpty) {
    return null;
  }
  return double.tryParse(text);
}
