import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/macro_formatters.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../gemini/application/gemini_product_client.dart';
import '../../gemini/domain/gemini_product_analysis.dart';
import '../../products/domain/product.dart';
import '../../products/presentation/product_cost_fields.dart';
import '../application/ocr_product_import_saver.dart';
import '../domain/nutrition_label_ocr_draft.dart';

enum _ParserFeedback { correct, incorrect, unsure }

class OcrProductConfirmationScreen extends StatefulWidget {
  const OcrProductConfirmationScreen({
    required this.store,
    required this.draft,
    super.key,
    this.geminiClient,
    this.saver = const OcrProductImportSaver(),
  });

  final NutrivoGoStore store;
  final NutritionLabelOcrDraft draft;
  final GeminiProductClient? geminiClient;
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
  final _feedbackController = TextEditingController();
  late BaseUnit _baseUnit;
  late String _source;
  GeminiProductAnalysis? _geminiAnalysis;
  String? _geminiStatusMessage;
  String? _geminiErrorMessage;
  _ParserFeedback _parserFeedback = _ParserFeedback.unsure;
  bool _isSaving = false;
  bool _isAnalyzingWithGemini = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _nameController.text = draft.name;
    _brandController.text = draft.brand ?? '';
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
    _source = draft.source;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
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
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final per100Label = _baseUnit == BaseUnit.milliliters
        ? 'Por 100 ml'
        : 'Por 100 g';
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar producto OCR')),
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
                  const SizedBox(height: 12),
                  _GeminiLabelActionCard(
                    isAnalyzing: _isAnalyzingWithGemini,
                    statusMessage: _geminiStatusMessage,
                    errorMessage: _geminiErrorMessage,
                    hasImage: widget.draft.imagePathLocal != null,
                    onAnalyze: _analyzeLabelWithGemini,
                  ),
                  if (_geminiAnalysis != null) ...[
                    const SizedBox(height: 12),
                    _GeminiReviewCard(analysis: _geminiAnalysis!),
                  ],
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 20),
                  Text(
                    'Base detectada: ${widget.draft.basisLabel}',
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
                  const SizedBox(height: 16),
                  _ParserFeedbackCard(
                    value: _parserFeedback,
                    feedbackController: _feedbackController,
                    onChanged: (value) {
                      setState(() => _parserFeedback = value);
                    },
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
    final draft = NutritionLabelOcrDraft(
      rawText: widget.draft.rawText,
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
      detectedBasis: widget.draft.detectedBasis,
      perServingValues: widget.draft.perServingValues,
      normalizedFromServing: widget.draft.normalizedFromServing,
      warnings: widget.draft.warnings,
      parserConfidence: widget.draft.parserConfidence,
      imagePathLocal: widget.draft.imagePathLocal,
      packagePriceClp: _parseOptionalNumber(_packagePriceController.text),
      packageQuantity: _parseOptionalNumber(_packageQuantityController.text),
      packageQuantityUnit: _packageQuantityController.text.trim().isEmpty
          ? null
          : _baseUnit.label,
      source: _source,
    );
    final product = await widget.saver.save(
      widget.store,
      draft,
      parsedDraft: widget.draft,
      wasParserCorrect: _wasParserCorrect,
      userFeedback: _emptyToNull(_feedbackController.text),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop<Product>(product);
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
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  bool? get _wasParserCorrect {
    return switch (_parserFeedback) {
      _ParserFeedback.correct => true,
      _ParserFeedback.incorrect => false,
      _ParserFeedback.unsure => null,
    };
  }

  Future<void> _analyzeLabelWithGemini() async {
    final geminiClient = widget.geminiClient;
    final imagePath = widget.draft.imagePathLocal;
    if (geminiClient == null) {
      setState(() {
        _geminiErrorMessage = 'Inicia sesión para usar Gemini.';
        _geminiStatusMessage = null;
      });
      return;
    }
    if (imagePath == null || imagePath.trim().isEmpty) {
      setState(() {
        _geminiErrorMessage = 'No hay imagen disponible para Gemini.';
        _geminiStatusMessage = null;
      });
      return;
    }

    setState(() {
      _isAnalyzingWithGemini = true;
      _geminiStatusMessage = 'Subiendo imagen...';
      _geminiErrorMessage = null;
    });
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    setState(() => _geminiStatusMessage = 'Analizando etiqueta...');

    try {
      final analysis = await geminiClient.analyzeNutritionLabelImage(
        imagePath: imagePath,
        rawOcrText: widget.draft.rawText,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isAnalyzingWithGemini = false;
        _geminiAnalysis = analysis;
        _geminiStatusMessage = 'Resultado de Gemini recibido.';
        _geminiErrorMessage = null;
        _applyGeminiAnalysis(analysis);
      });
    } on GeminiProductException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isAnalyzingWithGemini = false;
        _geminiStatusMessage = null;
        _geminiErrorMessage = error.message;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isAnalyzingWithGemini = false;
        _geminiStatusMessage = null;
        _geminiErrorMessage = 'No se pudo analizar con Gemini';
      });
    }
  }

  void _applyGeminiAnalysis(GeminiProductAnalysis analysis) {
    final draft = analysis.draft;
    if (draft == null) {
      return;
    }
    if (draft.name.trim().isNotEmpty) {
      _nameController.text = draft.name;
    }
    if (draft.brand?.trim().isNotEmpty == true) {
      _brandController.text = draft.brand!;
    }
    _baseUnit = draft.baseUnit;
    _source = draft.source;
    _setOptionalNumber(_servingSizeController, draft.servingSize);
    _setOptionalNumber(_caloriesController, draft.caloriesPer100);
    _setOptionalNumber(_proteinController, draft.proteinPer100);
    _setOptionalNumber(_carbsController, draft.carbsPer100);
    _setOptionalNumber(_fatController, draft.fatPer100);
    _setOptionalNumber(_sugarController, draft.sugarPer100);
    _setOptionalNumber(_saturatedFatController, draft.saturatedFatPer100);
    _setOptionalNumber(_sodiumController, draft.sodiumPer100);
    _setOptionalNumber(_fiberController, draft.fiberPer100);
  }

  void _setOptionalNumber(TextEditingController controller, double? value) {
    if (value != null) {
      controller.text = _formatInputNumberOrEmpty(value);
    }
  }
}

class _ParserFeedbackCard extends StatelessWidget {
  const _ParserFeedbackCard({
    required this.value,
    required this.feedbackController,
    required this.onChanged,
  });

  final _ParserFeedback value;
  final TextEditingController feedbackController;
  final ValueChanged<_ParserFeedback> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'El OCR detecto correctamente la informacion?',
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeedbackChip(
                  label: 'Si, estaba correcto',
                  selected: value == _ParserFeedback.correct,
                  onSelected: () => onChanged(_ParserFeedback.correct),
                ),
                _FeedbackChip(
                  label: 'No, tuve que corregir valores',
                  selected: value == _ParserFeedback.incorrect,
                  onSelected: () => onChanged(_ParserFeedback.incorrect),
                ),
                _FeedbackChip(
                  label: 'No estoy seguro',
                  selected: value == _ParserFeedback.unsure,
                  onSelected: () => onChanged(_ParserFeedback.unsure),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: feedbackController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentario opcional sobre el error',
                prefixIcon: Icon(Icons.comment_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeminiLabelActionCard extends StatelessWidget {
  const _GeminiLabelActionCard({
    required this.isAnalyzing,
    required this.statusMessage,
    required this.errorMessage,
    required this.hasImage,
    required this.onAnalyze,
  });

  final bool isAnalyzing;
  final String? statusMessage;
  final String? errorMessage;
  final bool hasImage;
  final VoidCallback onAnalyze;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analizar etiqueta con Gemini',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'La imagen se enviará a Gemini para análisis.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gemini puede equivocarse. Revisa antes de guardar.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (statusMessage != null) ...[
              const SizedBox(height: 10),
              Text(statusMessage!),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isAnalyzing ? null : onAnalyze,
              icon: Icon(
                isAnalyzing ? Icons.hourglass_top : Icons.auto_awesome,
              ),
              label: Text(
                isAnalyzing ? 'Analizando etiqueta' : 'Analizar con Gemini',
              ),
            ),
            if (!hasImage) ...[
              const SizedBox(height: 8),
              Text(
                'No hay imagen disponible. Usa entrada manual si es necesario.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GeminiReviewCard extends StatelessWidget {
  const _GeminiReviewCard({required this.analysis});

  final GeminiProductAnalysis analysis;

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
                Icon(Icons.verified_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Valores aproximados',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Confianza: ${_confidenceLabel(analysis.confidence)}'),
            if (analysis.explanation.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(analysis.explanation),
            ],
            if (analysis.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              _GeminiReviewList(
                title: 'Advertencias',
                items: analysis.warnings,
              ),
            ],
            if (analysis.assumptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _GeminiReviewList(
                title: 'Supuestos',
                items: analysis.assumptions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _confidenceLabel(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'high' => 'alta',
    'medium' => 'media',
    'low' => 'baja',
    final text? when text.isNotEmpty => text,
    _ => 'no indicada',
  };
}

class _GeminiReviewList extends StatelessWidget {
  const _GeminiReviewList({required this.title, required this.items});

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

class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.reviewMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  for (final warning in draft.warnings) ...[
                    const SizedBox(height: 6),
                    Text(
                      warning,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
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
        title: const Text('Valores detectados por porción'),
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
        title: const Text('Texto OCR crudo'),
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
