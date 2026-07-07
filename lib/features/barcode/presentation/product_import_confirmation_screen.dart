import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../food_log/application/nutrivo_go_store.dart';
import '../../products/domain/product.dart';
import '../../products/presentation/product_cost_fields.dart';
import '../application/product_import_saver.dart';
import '../domain/product_import_draft.dart';

class ProductImportConfirmationScreen extends StatefulWidget {
  const ProductImportConfirmationScreen({
    required this.store,
    required this.draft,
    super.key,
    this.message,
    this.sourceLabel,
    this.confidence,
    this.warnings = const <String>[],
    this.assumptions = const <String>[],
    this.explanation,
    this.saver = const ProductImportSaver(),
  });

  final NutrivoGoStore store;
  final ProductImportDraft draft;
  final String? message;
  final String? sourceLabel;
  final String? confidence;
  final List<String> warnings;
  final List<String> assumptions;
  final String? explanation;
  final ProductImportSaver saver;

  @override
  State<ProductImportConfirmationScreen> createState() =>
      _ProductImportConfirmationScreenState();
}

class _ProductImportConfirmationScreenState
    extends State<ProductImportConfirmationScreen> {
  static final _numberInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9\.,]'),
  );

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _servingSizeController = TextEditingController();
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
  late BaseUnit _baseUnit;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _nameController.text = draft.name;
    _brandController.text = draft.brand ?? '';
    _barcodeController.text = draft.barcode;
    _servingSizeController.text = _formatInputNumberOrEmpty(draft.servingSize);
    _packagePriceController.text = _formatInputNumberOrEmpty(
      draft.packagePriceClp,
    );
    _packageQuantityController.text = _formatInputNumberOrEmpty(
      draft.packageQuantity,
    );
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
    _barcodeController.dispose();
    _servingSizeController.dispose();
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
    final per100Label = _baseUnit == BaseUnit.milliliters
        ? 'Por 100 ml'
        : 'Por 100 g';
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar producto')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (widget.message != null) ...[
                    _ImportMessage(message: widget.message!),
                    const SizedBox(height: 12),
                  ],
                  if (_hasReviewDetails) ...[
                    _GeminiReviewCard(
                      sourceLabel: widget.sourceLabel,
                      confidence: widget.confidence,
                      warnings: widget.warnings,
                      assumptions: widget.assumptions,
                      explanation: widget.explanation,
                    ),
                    const SizedBox(height: 12),
                  ],
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
                    decoration: const InputDecoration(
                      labelText: 'Código de barras',
                      prefixIcon: Icon(Icons.qr_code_2_outlined),
                    ),
                    validator: widget.draft.source == 'barcode'
                        ? _requiredText
                        : null,
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
                  _OptionalNumberField(
                    controller: _servingSizeController,
                    label: 'Tamaño de la porción (${_baseUnit.label})',
                    icon: Icons.straighten,
                    allowZero: false,
                    zeroErrorText:
                        'El tamaño de la porción debe ser mayor que cero',
                  ),
                  const SizedBox(height: 20),
                  ProductCostFields(
                    packagePriceController: _packagePriceController,
                    packageQuantityController: _packageQuantityController,
                    servingSizeController: _servingSizeController,
                    baseUnit: _baseUnit,
                    numberInputFormatter: _numberInputFormatter,
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
                        label: 'Energía / Calorías (kcal)',
                        errorLabel: 'calorias',
                        icon: Icons.local_fire_department_outlined,
                      ),
                      _RequiredNumberField(
                        controller: _proteinController,
                        label: 'Proteínas (g)',
                        errorLabel: 'proteinas',
                        icon: Icons.fitness_center,
                      ),
                      _RequiredNumberField(
                        controller: _carbsController,
                        label: 'Carbohidratos (g)',
                        errorLabel: 'carbohidratos',
                        icon: Icons.grain,
                      ),
                      _RequiredNumberField(
                        controller: _fatController,
                        label: 'Grasas (g)',
                        errorLabel: 'grasas',
                        icon: Icons.water_drop_outlined,
                      ),
                      _OptionalNumberField(
                        controller: _sugarController,
                        label: 'Azúcares (g)',
                        icon: Icons.cookie_outlined,
                      ),
                      _OptionalNumberField(
                        controller: _saturatedFatController,
                        label: 'Grasas saturadas (g)',
                        icon: Icons.opacity,
                      ),
                      _OptionalNumberField(
                        controller: _sodiumController,
                        label: 'Sodio (mg)',
                        icon: Icons.science_outlined,
                      ),
                      _OptionalNumberField(
                        controller: _fiberController,
                        label: 'Fibra (g)',
                        icon: Icons.spa_outlined,
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
    final servingSize = _parseOptionalNumber(_servingSizeController.text);
    final draft = ProductImportDraft(
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      brand: _emptyToNull(_brandController.text),
      servingSize: servingSize,
      servingUnit: servingSize == null ? null : _baseUnit.label,
      baseUnit: _baseUnit,
      caloriesPer100: _parseRequiredNumber(_caloriesController.text),
      proteinPer100: _parseRequiredNumber(_proteinController.text),
      carbsPer100: _parseRequiredNumber(_carbsController.text),
      fatPer100: _parseRequiredNumber(_fatController.text),
      sugarPer100: _parseOptionalNumber(_sugarController.text),
      saturatedFatPer100: _parseOptionalNumber(_saturatedFatController.text),
      sodiumPer100: _parseOptionalNumber(_sodiumController.text),
      fiberPer100: _parseOptionalNumber(_fiberController.text),
      packagePriceClp: _parseOptionalNumber(_packagePriceController.text),
      packageQuantity: _parseOptionalNumber(_packageQuantityController.text),
      packageQuantityUnit: _packageQuantityController.text.trim().isEmpty
          ? null
          : _baseUnit.label,
      source: widget.draft.source,
    );
    final product = await widget.saver.save(widget.store, draft);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(product);
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
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
    return value.toString();
  }

  bool get _hasReviewDetails {
    return widget.sourceLabel != null ||
        widget.confidence != null ||
        widget.warnings.isNotEmpty ||
        widget.assumptions.isNotEmpty ||
        widget.explanation?.trim().isNotEmpty == true;
  }
}

class _ImportMessage extends StatelessWidget {
  const _ImportMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
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

class _GeminiReviewCard extends StatelessWidget {
  const _GeminiReviewCard({
    required this.sourceLabel,
    required this.confidence,
    required this.warnings,
    required this.assumptions,
    required this.explanation,
  });

  final String? sourceLabel;
  final String? confidence;
  final List<String> warnings;
  final List<String> assumptions;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sourceLabel ?? 'Gemini',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Gemini puede equivocarse. Revisa antes de guardar.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (confidence?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Confianza: $confidence'),
            ],
            if (explanation?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(explanation!),
            ],
            if (warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ReviewList(title: 'Advertencias', items: warnings),
            ],
            if (assumptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ReviewList(title: 'Supuestos', items: assumptions),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• $item',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
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
        _ProductImportConfirmationScreenState._numberInputFormatter,
      ],
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        final parsed =
            _ProductImportConfirmationScreenState._parseOptionalNumber(value);
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
    this.allowZero = true,
    this.zeroErrorText = 'Debe ser 0 o mas',
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool allowZero;
  final String zeroErrorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        _ProductImportConfirmationScreenState._numberInputFormatter,
      ],
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        final text = value?.trim();
        if (text == null || text.isEmpty) {
          return null;
        }
        final parsed =
            _ProductImportConfirmationScreenState._parseOptionalNumber(text);
        if (parsed == null) {
          return 'Ingresa un numero valido';
        }
        if (parsed < 0 || (!allowZero && parsed == 0)) {
          return zeroErrorText;
        }
        return null;
      },
    );
  }
}
