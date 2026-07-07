import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../products/domain/product.dart';
import '../domain/product_import_draft.dart';

class OpenFoodFactsClient {
  OpenFoodFactsClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<ProductLookupResult> lookupBarcode(String barcode) async {
    final normalized = barcode.trim();
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$normalized.json',
      {
        'fields': [
          'code',
          'status',
          'product_name',
          'product_name_es',
          'brands',
          'serving_size',
          'quantity',
          'nutrition_data_per',
          'nutriments',
        ].join(','),
      },
    );

    final response = await _httpClient.get(
      uri,
      headers: const {
        'User-Agent': 'NutrivoGo - https://github.com/sebargith/NutrivoGo',
      },
    );
    if (response.statusCode == 404) {
      return ProductLookupResult.notFound(normalized);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OpenFoodFactsException(
        'Open Food Facts returned HTTP ${response.statusCode}.',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const OpenFoodFactsException(
        'Open Food Facts returned an unexpected response.',
      );
    }
    return OpenFoodFactsParser.parse(body, fallbackBarcode: normalized);
  }

  void close() {
    _httpClient.close();
  }
}

class OpenFoodFactsParser {
  const OpenFoodFactsParser._();

  static ProductLookupResult parse(
    Map<String, dynamic> body, {
    required String fallbackBarcode,
  }) {
    final status = body['status'];
    if (status == 0 || status == '0') {
      return ProductLookupResult.notFound(fallbackBarcode);
    }

    final product = body['product'];
    if (product is! Map<String, dynamic>) {
      return ProductLookupResult.notFound(fallbackBarcode);
    }

    final nutriments = product['nutriments'] is Map<String, dynamic>
        ? product['nutriments'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final barcode =
        _string(product['code']) ?? _string(body['code']) ?? fallbackBarcode;
    final name =
        _string(product['product_name_es']) ??
        _string(product['product_name']) ??
        '';
    final serving = _parseServing(_string(product['serving_size']));
    final baseUnit = _inferBaseUnit(
      serving.unit ?? _string(product['quantity']),
      nutriments,
      _string(product['nutrition_data_per']),
    );
    final suffix = baseUnit == BaseUnit.milliliters ? '100ml' : '100g';
    final calories =
        _number(nutriments['energy-kcal_$suffix']) ??
        _number(nutriments['energy-kcal_100g']) ??
        _energyKilojoulesToCalories(_number(nutriments['energy_$suffix'])) ??
        _energyKilojoulesToCalories(_number(nutriments['energy_100g']));

    final draft = ProductImportDraft(
      barcode: barcode,
      name: name,
      brand: _string(product['brands']),
      servingSize: serving.amount,
      servingUnit: serving.unit,
      baseUnit: baseUnit,
      caloriesPer100: calories,
      proteinPer100:
          _number(nutriments['proteins_$suffix']) ??
          _number(nutriments['proteins_100g']),
      carbsPer100:
          _number(nutriments['carbohydrates_$suffix']) ??
          _number(nutriments['carbohydrates_100g']),
      fatPer100:
          _number(nutriments['fat_$suffix']) ?? _number(nutriments['fat_100g']),
      sugarPer100:
          _number(nutriments['sugars_$suffix']) ??
          _number(nutriments['sugars_100g']),
      saturatedFatPer100:
          _number(nutriments['saturated-fat_$suffix']) ??
          _number(nutriments['saturated-fat_100g']),
      sodiumPer100:
          _number(nutriments['sodium_$suffix']) ??
          _number(nutriments['sodium_100g']),
      fiberPer100:
          _number(nutriments['fiber_$suffix']) ??
          _number(nutriments['fiber_100g']),
    );

    return ProductLookupResult(
      status: draft.hasRequiredNutrition
          ? ProductLookupStatus.found
          : ProductLookupStatus.incomplete,
      barcode: barcode,
      draft: draft,
      message: draft.hasRequiredNutrition
          ? null
          : 'Open Food Facts found this product, but nutrition data is incomplete.',
    );
  }

  static _Serving _parseServing(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return const _Serving();
    }

    final baseUnitMatches = RegExp(
      r'([0-9]+(?:[\.,][0-9]+)?)\s*(g|gr|gramos?|ml|mililitros?)\b',
      caseSensitive: false,
    ).allMatches(text);
    if (baseUnitMatches.isNotEmpty) {
      final baseUnitMatch = baseUnitMatches.last;
      final amount = double.tryParse(
        baseUnitMatch.group(1)!.replaceAll(',', '.'),
      );
      final unit = _normalizeServingUnit(baseUnitMatch.group(2));
      return _Serving(amount: amount, unit: unit);
    }

    return const _Serving();
  }

  static BaseUnit _inferBaseUnit(
    String? unitText,
    Map<String, dynamic> nutriments,
    String? nutritionDataPer,
  ) {
    final normalized = '${unitText ?? ''} ${nutritionDataPer ?? ''}'
        .toLowerCase();
    if (normalized.contains('ml') ||
        nutriments.containsKey('energy-kcal_100ml') ||
        nutriments.containsKey('energy_100ml')) {
      return BaseUnit.milliliters;
    }
    return BaseUnit.grams;
  }

  static double? _energyKilojoulesToCalories(double? kilojoules) {
    if (kilojoules == null) {
      return null;
    }
    return kilojoules / 4.184;
  }

  static String? _string(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double? _number(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }

  static String? _normalizeServingUnit(String? value) {
    final unit = value?.trim().toLowerCase();
    if (unit == null || unit.isEmpty) {
      return null;
    }
    if (unit == 'ml' || unit.startsWith('mililitro')) {
      return 'ml';
    }
    return 'g';
  }
}

class _Serving {
  const _Serving({this.amount, this.unit});

  final double? amount;
  final String? unit;
}

class OpenFoodFactsException implements Exception {
  const OpenFoodFactsException(this.message);

  final String message;

  @override
  String toString() => message;
}
