import 'package:flutter/material.dart';

import '../application/gemini_product_client.dart';
import '../domain/gemini_product_analysis.dart';

class GeminiGenericProductScreen extends StatefulWidget {
  const GeminiGenericProductScreen({required this.client, super.key});

  final GeminiProductClient client;

  @override
  State<GeminiGenericProductScreen> createState() =>
      _GeminiGenericProductScreenState();
}

class _GeminiGenericProductScreenState
    extends State<GeminiGenericProductScreen> {
  final _queryController = TextEditingController();
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar con Gemini')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Gemini puede equivocarse. Revisa antes de guardar.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _queryController,
                  enabled: !_isAnalyzing,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _analyze(),
                  decoration: const InputDecoration(
                    labelText: 'Describe el alimento',
                    hintText: 'Ejemplo: plátano, huevo, arroz cocido',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _isAnalyzing ? null : _analyze,
                  icon: Icon(
                    _isAnalyzing
                        ? Icons.hourglass_top
                        : Icons.auto_awesome_outlined,
                  ),
                  label: Text(
                    _isAnalyzing ? 'Generando producto' : 'Generar producto',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() => _errorMessage = 'Describe el alimento');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });
    try {
      final analysis = await widget.client.analyzeGenericFood(query: query);
      if (!mounted) {
        return;
      }
      if (!analysis.hasDraft) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'No se pudo analizar con Gemini';
        });
        return;
      }
      Navigator.of(context).pop<GeminiProductAnalysis>(analysis);
    } on GeminiProductException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isAnalyzing = false;
        _errorMessage = error.message;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'No se pudo analizar con Gemini';
      });
    }
  }
}
