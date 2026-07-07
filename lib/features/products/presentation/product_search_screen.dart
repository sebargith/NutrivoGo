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
  });

  final NutrivoGoStore store;
  final MealType? initialMealType;

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
          widget.initialMealType == null
              ? 'Agregar alimento'
              : 'Agregar a ${widget.initialMealType!.label}',
        ),
        actions: [
          IconButton(
            tooltip: 'Escanear código de barras',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _isLookingUpBarcode ? null : _scanBarcode,
          ),
          IconButton(
            tooltip: 'Escanear etiqueta nutricional',
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: _scanNutritionLabel,
          ),
          IconButton(
            tooltip: 'Crear producto',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _createProduct,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProduct,
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
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
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Buscar productos',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BarcodeActionBar(
                      isLoading: _isLookingUpBarcode,
                      onScan: _scanBarcode,
                    ),
                    const SizedBox(height: 12),
                    _OcrActionBar(onScan: _scanNutritionLabel),
                    const SizedBox(height: 16),
                    if (widget.store.products.isEmpty)
                      _EmptyProducts(onCreate: _createProduct)
                    else if (products.isEmpty)
                      _NoResults(onCreate: _createProduct)
                    else ...[
                      if (frequentProducts.isNotEmpty) ...[
                        _SectionHeader(
                          title:
                              'Frecuentes en ${widget.initialMealType!.label}',
                          subtitle: 'Usados en esta comida',
                        ),
                        const SizedBox(height: 8),
                        for (final product in frequentProducts)
                          _ProductTile(
                            product: product,
                            onTap: _selectProduct,
                            onEdit: _editProduct,
                            onDelete: _confirmDeleteProduct,
                          ),
                        const SizedBox(height: 12),
                      ],
                      if (recentProducts.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Recientes',
                          subtitle: 'Agrega rápido alimentos usados antes',
                        ),
                        const SizedBox(height: 8),
                        for (final product in recentProducts)
                          _ProductTile(
                            product: product,
                            onTap: _selectProduct,
                            onEdit: _editProduct,
                            onDelete: _confirmDeleteProduct,
                          ),
                        const SizedBox(height: 12),
                      ],
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
        builder: (_) =>
            OcrProductConfirmationScreen(store: widget.store, draft: draft),
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
        ),
      ),
    );
    if (!mounted || loggedItem == null) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _OcrActionBar extends StatelessWidget {
  const _OcrActionBar({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.document_scanner_outlined),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Escanear etiqueta nutricional',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Escanear'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodeActionBar extends StatelessWidget {
  const _BarcodeActionBar({required this.isLoading, required this.onScan});

  final bool isLoading;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.qr_code_scanner),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isLoading
                    ? 'Buscando código de barras...'
                    : 'Escanea o ingresa un código',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: isLoading ? null : onScan,
              icon: Icon(isLoading ? Icons.hourglass_top : Icons.camera_alt),
              label: Text(isLoading ? 'Buscando' : 'Escanear'),
            ),
          ],
        ),
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
