import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/macro_formatters.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../products/domain/product.dart';
import '../application/ocr_product_import_saver.dart';
import '../domain/nutrition_label_ocr_draft.dart';

class OcrProductConfirmationScreen extends StatefulWidget {
  const OcrProductConfirmationScreen({
    required this.store,
    required this.draft,
    super.key,
    this.saver = const OcrProductImportSaver(),
  });

  final NutrivoGoStore store;
  final NutritionLabelOcrDraft draft;
  final OcrProductImportSaver saver;

  @override
  State<OcrProductConfirmationScreen> createState() =>
      _OcrProductConfirmationScreenState();
}

class _OcrProductConfirmationScreenState
    extends State<OcrProductConfirmationScreen> {
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
  final _sugarController = TextEditingController();
  final _saturatedFatController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _fiberController = TextEditingController();
  late BaseUnit _baseUnit;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _nameController.text = draft.name;
    _brandController.text = draft.brand ?? '';
    _servingSizeController.text = _formatInputNumberOrEmpty(draft.servingSize);
    _servingUnitController.text = draft.servingUnit ?? '';
    _caloriesController.text = _formatInputNumberOrEmpty(draft.caloriesPer100);
    _proteinController.text = _formatInputNumberOrEmpty(draft.proteinPer100);
    _carbsController.text = _formatInputNumberOrEmpty(draft.carbsPer100);
    _fatController.text = _formatInputNumberOrEmpty(draft.fatPer100);
    _sugarController.text = _formatInputNumberOrEmpty(draft.sugarPer100);
    _saturatedFatController.text = _formatInputNumberOrEmpty(
      draft.saturatedFatPer100,
    );
    _sodiumController.text = _formatInputNumberOrEmpty(draft.sodiumPer100);
    _fiberController.text = _formatInputNumberOrEmpty(draft.fiberPer100);
    _baseUnit = draft.baseUnit;
  }

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
    _sugarController.dispose();
    _saturatedFatController.dispose();
    _sodiumController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final per100Label = _baseUnit == BaseUnit.milliliters
        ? 'Por 100 ml'
        : 'Por 100 g';
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm OCR Product')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ReviewMessage(draft: widget.draft),
                  if (widget.draft.perServingValues != null) ...[
                    const SizedBox(height: 12),
                    _PerServingCard(values: widget.draft.perServingValues!),
                  ],
                  const SizedBox(height: 12),
                  _RawTextCard(rawText: widget.draft.rawText),
                  const SizedBox(height: 16),
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
                    'Detected basis: ${widget.draft.basisLabel}',
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
                  _ResponsiveFields(
                    children: [
                      _OptionalNumberField(
                        controller: _servingSizeController,
                        label: 'Porción',
                        icon: Icons.straighten,
                      ),
                      TextFormField(
                        controller: _servingUnitController,
                        decoration: const InputDecoration(
                          labelText: 'Serving unit',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    per100Label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _ResponsiveFields(
                    children: [
                      _RequiredNumberField(
                        controller: _caloriesController,
                        label: 'Energía / Calorías',
                        errorLabel: 'calorías',
                        icon: Icons.local_fire_department_outlined,
                      ),
                      _RequiredNumberField(
                        controller: _proteinController,
                        label: 'Proteínas',
                        errorLabel: 'proteínas',
                        icon: Icons.fitness_center,
                      ),
                      _RequiredNumberField(
                        controller: _carbsController,
                        label: 'Carbohidratos',
                        errorLabel: 'carbohidratos',
                        icon: Icons.grain,
                      ),
                      _RequiredNumberField(
                        controller: _fatController,
                        label: 'Grasas',
                        errorLabel: 'grasas',
                        icon: Icons.water_drop_outlined,
                      ),
                      _OptionalNumberField(
                        controller: _sugarController,
                        label: 'Azúcares',
                        icon: Icons.cookie_outlined,
                      ),
                      _OptionalNumberField(
                        controller: _saturatedFatController,
                        label: 'Grasas saturadas',
                        icon: Icons.opacity,
                      ),
                      _OptionalNumberField(
                        controller: _sodiumController,
                        label: 'Sodio',
                        icon: Icons.science_outlined,
                      ),
                      _OptionalNumberField(
                        controller: _fiberController,
                        label: 'Fibra',
                        icon: Icons.spa_outlined,
                      ),
                    ],
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
    final draft = NutritionLabelOcrDraft(
      rawText: widget.draft.rawText,
      name: _nameController.text.trim(),
      brand: _emptyToNull(_brandController.text),
      servingSize: _parseOptionalNumber(_servingSizeController.text),
      servingUnit: _emptyToNull(_servingUnitController.text),
      baseUnit: _baseUnit,
      caloriesPer100: _parseRequiredNumber(_caloriesController.text),
      proteinPer100: _parseRequiredNumber(_proteinController.text),
      carbsPer100: _parseRequiredNumber(_carbsController.text),
      fatPer100: _parseRequiredNumber(_fatController.text),
      sugarPer100: _parseOptionalNumber(_sugarController.text),
      saturatedFatPer100: _parseOptionalNumber(_saturatedFatController.text),
      sodiumPer100: _parseOptionalNumber(_sodiumController.text),
      fiberPer100: _parseOptionalNumber(_fiberController.text),
      detectedBasis: widget.draft.detectedBasis,
      perServingValues: widget.draft.perServingValues,
      normalizedFromServing: widget.draft.normalizedFromServing,
    );
    final product = await widget.saver.save(widget.store, draft);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop<Product>(product);
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    return null;
  }

  static double _parseRequiredNumber(String value) {
    return double.parse(value.trim().replaceAll(',', '.'));
  }

  static double? _parseOptionalNumber(String? value) {
    final text = value?.trim().replaceAll(',', '.');
    if (text == null || text.isEmpty) {
      return null;
    }
    return double.tryParse(text);
  }

  static String? _emptyToNull(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static String _formatInputNumberOrEmpty(double? value) {
    if (value == null) {
      return '';
    }
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class _ReviewMessage extends StatelessWidget {
  const _ReviewMessage({required this.draft});

  final NutritionLabelOcrDraft draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                draft.reviewMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerServingCard extends StatelessWidget {
  const _PerServingCard({required this.values});

  final OcrNutritionValues values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.restaurant_menu),
        title: const Text('Detected per-serving values'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          _ValueRow(
            label: 'Energía / Calorías',
            value: values.calories,
            unit: 'kcal',
          ),
          _ValueRow(label: 'Proteínas', value: values.protein, unit: 'g'),
          _ValueRow(label: 'Carbohidratos', value: values.carbs, unit: 'g'),
          _ValueRow(label: 'Azúcares', value: values.sugar, unit: 'g'),
          _ValueRow(label: 'Grasas', value: values.fat, unit: 'g'),
          _ValueRow(
            label: 'Grasas saturadas',
            value: values.saturatedFat,
            unit: 'g',
          ),
          _ValueRow(label: 'Sodio', value: values.sodium, unit: 'mg'),
          _ValueRow(label: 'Fibra', value: values.fiber, unit: 'g'),
        ],
      ),
    );
  }
}

class _RawTextCard extends StatelessWidget {
  const _RawTextCard({required this.rawText});

  final String rawText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.notes_outlined),
        title: const Text('Raw OCR text'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [SelectableText(rawText)],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final displayValue = value;
    if (displayValue == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('${formatMacro(displayValue, decimals: 1)} $unit'),
        ],
      ),
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

class _RequiredNumberField extends StatelessWidget {
  const _RequiredNumberField({
    required this.controller,
    required this.label,
    required this.errorLabel,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String errorLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        _OcrProductConfirmationScreenState._numberInputFormatter,
      ],
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        final parsed = _OcrProductConfirmationScreenState._parseOptionalNumber(
          value,
        );
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
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        _OcrProductConfirmationScreenState._numberInputFormatter,
      ],
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        final text = value?.trim();
        if (text == null || text.isEmpty) {
          return null;
        }
        final parsed = _OcrProductConfirmationScreenState._parseOptionalNumber(
          text,
        );
        if (parsed == null) {
          return 'Debe ser un número';
        }
        if (parsed < 0) {
          return 'Debe ser 0 o más';
        }
        return null;
      },
    );
  }
}
