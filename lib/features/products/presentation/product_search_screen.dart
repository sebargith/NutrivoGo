import 'package:flutter/material.dart';

import '../../../shared/utils/cost_formatters.dart';
import '../../../shared/utils/macro_formatters.dart';
import '../../barcode/application/open_food_facts_client.dart';
import '../../barcode/domain/product_import_draft.dart';
import '../../barcode/presentation/barcode_scan_screen.dart';
import '../../barcode/presentation/product_import_confirmation_screen.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../food_log/domain/food_cost_calculator.dart';
import '../../food_log/domain/log_item.dart';
import '../../food_log/domain/meal_type.dart';
import '../../food_log/presentation/add_food_quantity_screen.dart';
import '../../gemini/application/gemini_product_client.dart';
import '../../gemini/domain/gemini_product_analysis.dart';
import '../../gemini/presentation/gemini_generic_product_screen.dart';
import '../../ocr/domain/nutrition_label_ocr_draft.dart';
import '../../ocr/presentation/ocr_product_confirmation_screen.dart';
import '../../ocr/presentation/ocr_scan_screen.dart';
import '../domain/product.dart';
import 'create_product_screen.dart';

enum _ProductAction { edit, delete }

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({
    required this.store,
    super.key,
    this.initialMealType,
    this.initialConsumedOn,
    this.geminiClient,
    this.isProductTab = false,
  });

  final NutrivoGoStore store;
  final MealType? initialMealType;
  final DateTime? initialConsumedOn;
  final GeminiProductClient? geminiClient;
  final bool isProductTab;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final OpenFoodFactsClient _openFoodFactsClient = OpenFoodFactsClient();
  String _query = '';
  bool _isLookingUpBarcode = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _openFoodFactsClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isProductTab
              ? 'Productos'
              : widget.initialMealType == null
              ? 'Agregar alimento'
              : 'Agregar a ${widget.initialMealType!.label}',
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.store,
          builder: (context, _) {
            final products = _filteredProducts();
            final frequentProducts =
                _query.isEmpty && widget.initialMealType != null
                ? widget.store.frequentProductsForMeal(widget.initialMealType!)
                : <Product>[];
            final recentProducts =
                _query.isEmpty && widget.initialMealType == null
                ? widget.store.recentProducts
                : <Product>[];
            final quickProducts = frequentProducts.isNotEmpty
                ? frequentProducts
                : recentProducts;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: 'Buscar alimento o marca',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _isLookingUpBarcode ? null : _scanBarcode,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: Text(
                            _isLookingUpBarcode ? 'Buscando' : 'Escanear',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (quickProducts.isNotEmpty) ...[
                      _SectionHeader(
                        title: frequentProducts.isNotEmpty
                            ? 'Frecuentes'
                            : 'Recientes',
                        subtitle: 'Acceso rápido',
                      ),
                      const SizedBox(height: 10),
                      _FrequentPlate(
                        products: quickProducts,
                        onTap: _selectProduct,
                      ),
                      const SizedBox(height: 20),
                    ],
                    _ProductEntryActions(
                      isLookingUpBarcode: _isLookingUpBarcode,
                      onBarcode: _scanBarcode,
                      onOcr: _scanNutritionLabel,
                      onGemini: _openGeminiGeneric,
                      onCreate: _createProduct,
                    ),
                    const SizedBox(height: 20),
                    if (widget.store.products.isEmpty)
                      _EmptyProducts(onCreate: _createProduct)
                    else if (products.isEmpty)
                      _NoResults(onCreate: _createProduct)
                    else ...[
                      _SectionHeader(
                        title: 'Productos',
                        subtitle: '${products.length} guardados',
                      ),
                      const SizedBox(height: 8),
                      for (final product in products)
                        _ProductTile(
                          product: product,
                          onTap: _selectProduct,
                          onEdit: _editProduct,
                          onDelete: _confirmDeleteProduct,
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Product> _filteredProducts() {
    return widget.store.rankedProductsForMeal(
      mealType: widget.initialMealType,
      query: _query,
    );
  }

  Future<void> _createProduct() async {
    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) => CreateProductScreen(store: widget.store),
      ),
    );
    if (!mounted || product == null) {
      return;
    }
    await _selectProduct(product);
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const BarcodeScanScreen()),
    );
    if (!mounted || barcode == null || barcode.trim().isEmpty) {
      return;
    }
    await _handleBarcode(barcode);
  }

  Future<void> _scanNutritionLabel() async {
    final draft = await Navigator.of(context).push<NutritionLabelOcrDraft>(
      MaterialPageRoute<NutritionLabelOcrDraft>(
        builder: (_) => const OcrScanScreen(),
      ),
    );
    if (!mounted || draft == null) {
      return;
    }

    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) => OcrProductConfirmationScreen(
          store: widget.store,
          draft: draft,
          geminiClient: widget.geminiClient,
        ),
      ),
    );
    if (!mounted || product == null) {
      return;
    }
    await _selectProduct(product);
  }

  Future<void> _openGeminiGeneric() async {
    final geminiClient = widget.geminiClient;
    if (geminiClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para usar Gemini.')),
      );
      return;
    }

    final analysis = await Navigator.of(context).push<GeminiProductAnalysis>(
      MaterialPageRoute<GeminiProductAnalysis>(
        builder: (_) => GeminiGenericProductScreen(client: geminiClient),
      ),
    );
    if (!mounted || analysis == null || analysis.draft == null) {
      return;
    }

    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) => ProductImportConfirmationScreen(
          store: widget.store,
          draft: analysis.draft!,
          message: 'Valores aproximados generados por Gemini.',
          sourceLabel: analysis.sourceLabel,
          confidence: analysis.confidence,
          warnings: analysis.warnings,
          assumptions: analysis.assumptions,
          explanation: analysis.explanation,
        ),
      ),
    );
    if (!mounted || product == null) {
      return;
    }
    await _selectProduct(product);
  }

  Future<void> _handleBarcode(String barcode) async {
    final normalized = barcode.trim();
    final localProduct = widget.store.findProductByBarcode(normalized);
    if (localProduct != null) {
      await _selectProduct(localProduct);
      return;
    }

    setState(() => _isLookingUpBarcode = true);
    ProductLookupResult result;
    try {
      result = await _openFoodFactsClient.lookupBarcode(normalized);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isLookingUpBarcode = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo contactar Open Food Facts. Crea el producto manualmente. $error',
          ),
        ),
      );
      await _openManualProductWithBarcode(normalized);
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _isLookingUpBarcode = false);

    if (result.status == ProductLookupStatus.notFound || result.draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Código no encontrado en Open Food Facts. Créalo manualmente.',
          ),
        ),
      );
      await _openManualProductWithBarcode(normalized);
      return;
    }

    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) => ProductImportConfirmationScreen(
          store: widget.store,
          draft: result.draft!,
          message: result.message,
        ),
      ),
    );
    if (!mounted || product == null) {
      return;
    }
    await _selectProduct(product);
  }

  Future<void> _openManualProductWithBarcode(String barcode) async {
    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) =>
            CreateProductScreen(store: widget.store, initialBarcode: barcode),
      ),
    );
    if (!mounted || product == null) {
      return;
    }
    await _selectProduct(product);
  }

  Future<void> _editProduct(Product product) async {
    await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) =>
            CreateProductScreen(store: widget.store, product: product),
      ),
    );
  }

  Future<void> _confirmDeleteProduct(Product product) async {
    final hasHistory = widget.store.hasLogItemsForProduct(product.id);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete product?'),
          content: Text(
            hasHistory
                ? 'Esto elimina ${product.name} de productos guardados. Los registros existentes mantienen sus macros.'
                : 'Esto elimina ${product.name} de productos guardados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }
    await widget.store.deleteProduct(product.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.name} eliminado')));
  }

  Future<void> _selectProduct(Product product) async {
    final loggedItem = await Navigator.of(context).push<LogItem>(
      MaterialPageRoute<LogItem>(
        builder: (_) => AddFoodQuantityScreen(
          store: widget.store,
          product: product,
          initialMealType: widget.initialMealType,
          initialConsumedOn: widget.initialConsumedOn,
        ),
      ),
    );
    if (!mounted || loggedItem == null) {
      return;
    }
    if (!widget.isProductTab) {
      Navigator.of(context).pop();
    }
  }
}

class _FrequentPlate extends StatelessWidget {
  const _FrequentPlate({required this.products, required this.onTap});

  final List<Product> products;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    final visible = products.take(4).toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.clamp(250.0, 340.0);
        const positions = <Alignment>[
          Alignment(-0.58, -0.58),
          Alignment(0.58, -0.58),
          Alignment(-0.58, 0.58),
          Alignment(0.58, 0.58),
        ];
        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: const Color(0xFFE1DED7)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F2F3E),
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              children: [
                for (var index = 0; index < visible.length; index++)
                  Align(
                    alignment: positions[index],
                    child: _FrequentProduct(
                      product: visible[index],
                      onTap: () => onTap(visible[index]),
                    ),
                  ),
                if (visible.length < 4)
                  const Center(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF9AA7AD),
                      size: 34,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FrequentProduct extends StatelessWidget {
  const _FrequentProduct({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _productColor(product);
    return SizedBox(
      width: 112,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(_productIcon(product), color: color, size: 34),
            ),
            const SizedBox(height: 5),
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductEntryActions extends StatelessWidget {
  const _ProductEntryActions({
    required this.isLookingUpBarcode,
    required this.onBarcode,
    required this.onOcr,
    required this.onGemini,
    required this.onCreate,
  });

  final bool isLookingUpBarcode;
  final VoidCallback onBarcode;
  final VoidCallback onOcr;
  final VoidCallback onGemini;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              width: width,
              icon: Icons.qr_code_scanner,
              label: 'Código',
              onPressed: isLookingUpBarcode ? null : onBarcode,
            ),
            _ActionButton(
              width: width,
              icon: Icons.document_scanner_outlined,
              label: 'Etiqueta',
              onPressed: onOcr,
            ),
            _ActionButton(
              width: width,
              icon: Icons.auto_awesome_outlined,
              label: 'Gemini',
              onPressed: onGemini,
            ),
            _ActionButton(
              width: width,
              icon: Icons.add_box_outlined,
              label: 'Crear producto',
              onPressed: onCreate,
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final costPerServing = const FoodCostCalculator().costPerServing(product);
    final costPer100 = const FoodCostCalculator().costPer100(product);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => onTap(product),
        leading: const Icon(Icons.restaurant_outlined),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            if (product.brand?.isNotEmpty == true) product.brand!,
            '${formatMacro(product.caloriesPer100)} kcal / 100${product.baseUnitLabel}',
            if (product.servingLabel != null) 'Porción ${product.servingLabel}',
            if (costPerServing != null)
              'Costo por porción ${formatClp(costPerServing)}'
            else if (costPer100 != null)
              'Costo por 100${product.baseUnitLabel} ${formatClp(costPer100)}',
          ].join(' - '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<_ProductAction>(
              tooltip: 'Acciones del producto',
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onSelected: (action) {
                switch (action) {
                  case _ProductAction.edit:
                    onEdit(product);
                    break;
                  case _ProductAction.delete:
                    onDelete(product);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ProductAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                  ),
                ),
                PopupMenuItem(
                  value: _ProductAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Eliminar'),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
        Text(
          subtitle,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No hay productos todavía', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Crea alimentos reutilizables con macros por 100 g o 100 ml.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Crear producto'),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 42,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay productos coincidentes',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Crear producto'),
          ),
        ],
      ),
    );
  }
}

Color _productColor(Product product) {
  final index = product.name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
  const colors = <Color>[
    Color(0xFF4F8B63),
    Color(0xFFE78942),
    Color(0xFFE0B332),
    Color(0xFFA95066),
    Color(0xFF2C6E8A),
  ];
  return colors[index % colors.length];
}

IconData _productIcon(Product product) {
  final name = product.name.toLowerCase();
  if (name.contains('leche') ||
      name.contains('yogur') ||
      name.contains('yogurt')) {
    return Icons.local_drink_outlined;
  }
  if (name.contains('pan') ||
      name.contains('avena') ||
      name.contains('arroz')) {
    return Icons.bakery_dining_outlined;
  }
  if (name.contains('pollo') ||
      name.contains('carne') ||
      name.contains('huevo')) {
    return Icons.egg_alt_outlined;
  }
  if (name.contains('manzana') ||
      name.contains('plátano') ||
      name.contains('platano') ||
      name.contains('fruta')) {
    return Icons.apple_outlined;
  }
  return Icons.restaurant_outlined;
}
