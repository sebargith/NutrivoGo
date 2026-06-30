import 'package:flutter/material.dart';

import '../../../shared/utils/macro_formatters.dart';
import '../../food_log/application/nutrivo_go_store.dart';
import '../../food_log/domain/log_item.dart';
import '../../food_log/presentation/add_food_quantity_screen.dart';
import '../domain/product.dart';
import 'create_product_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({required this.store, super.key});

  final NutrivoGoStore store;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        actions: [
          IconButton(
            tooltip: 'Create product',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _createProduct,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProduct,
        icon: const Icon(Icons.add),
        label: const Text('Product'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.store,
          builder: (context, _) {
            final products = _filteredProducts(widget.store.products);
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
                        hintText: 'Search products',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.store.products.isEmpty)
                      _EmptyProducts(onCreate: _createProduct)
                    else if (products.isEmpty)
                      const _NoResults()
                    else
                      for (final product in products)
                        _ProductTile(product: product, onTap: _selectProduct),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Product> _filteredProducts(List<Product> products) {
    if (_query.isEmpty) {
      return products;
    }
    return products
        .where((product) {
          final haystack = '${product.name} ${product.brand ?? ''}'
              .toLowerCase();
          return haystack.contains(_query);
        })
        .toList(growable: false);
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

  Future<void> _selectProduct(Product product) async {
    final loggedItem = await Navigator.of(context).push<LogItem>(
      MaterialPageRoute<LogItem>(
        builder: (_) =>
            AddFoodQuantityScreen(store: widget.store, product: product),
      ),
    );
    if (!mounted || loggedItem == null) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            if (product.servingLabel != null) 'Serving ${product.servingLabel}',
          ].join(' - '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
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
          Text('No products yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create Product'),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Text(
          'No matching products',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
