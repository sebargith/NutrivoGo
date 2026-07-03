import '../../products/domain/product.dart';
import '../domain/nutrition_label_ocr_draft.dart';

class NutritionLabelOcrParser {
  const NutritionLabelOcrParser();

  NutritionLabelOcrDraft parse(String rawText) {
    final lines = rawText
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final normalizedText = _normalize(rawText);
    final basis = _detectBasis(normalizedText);
    final serving = _detectServing(lines);
    final servingBeforePer100 = _servingColumnBeforePer100(lines);
    final sourceValues = _parseValues(
      lines,
      takeLastValue:
          servingBeforePer100 &&
          (basis == OcrNutritionBasis.per100g ||
              basis == OcrNutritionBasis.per100ml),
    );

    final baseUnit = switch (basis) {
      OcrNutritionBasis.per100ml => BaseUnit.milliliters,
      OcrNutritionBasis.per100g => BaseUnit.grams,
      _ => serving.unit == 'ml' ? BaseUnit.milliliters : BaseUnit.grams,
    };

    if (basis == OcrNutritionBasis.perServing) {
      final canNormalize =
          serving.size != null && serving.size! > 0 && serving.unit != null;
      final normalized = canNormalize
          ? _normalizeServingValues(sourceValues, serving.size!)
          : const OcrNutritionValues();
      return NutritionLabelOcrDraft(
        rawText: rawText,
        servingSize: serving.size,
        servingUnit: serving.unit,
        baseUnit: baseUnit,
        caloriesPer100: normalized.calories,
        proteinPer100: normalized.protein,
        carbsPer100: normalized.carbs,
        fatPer100: normalized.fat,
        sugarPer100: normalized.sugar,
        saturatedFatPer100: normalized.saturatedFat,
        sodiumPer100: normalized.sodium,
        fiberPer100: normalized.fiber,
        detectedBasis: basis,
        perServingValues: sourceValues,
        normalizedFromServing: canNormalize,
      );
    }

    return NutritionLabelOcrDraft(
      rawText: rawText,
      servingSize: serving.size,
      servingUnit: serving.unit,
      baseUnit: baseUnit,
      caloriesPer100: sourceValues.calories,
      proteinPer100: sourceValues.protein,
      carbsPer100: sourceValues.carbs,
      fatPer100: sourceValues.fat,
      sugarPer100: sourceValues.sugar,
      saturatedFatPer100: sourceValues.saturatedFat,
      sodiumPer100: sourceValues.sodium,
      fiberPer100: sourceValues.fiber,
      detectedBasis: basis,
    );
  }

  OcrNutritionBasis _detectBasis(String normalizedText) {
    final hasPer100ml = RegExp(r'(por\s*)?100\s*ml').hasMatch(normalizedText);
    final hasPer100g = RegExp(r'(por\s*)?100\s*g').hasMatch(normalizedText);
    if (hasPer100ml) {
      return OcrNutritionBasis.per100ml;
    }
    if (hasPer100g) {
      return OcrNutritionBasis.per100g;
    }
    if (normalizedText.contains('por porcion') ||
        normalizedText.contains('por 1 porcion') ||
        normalizedText.contains('por racion')) {
      return OcrNutritionBasis.perServing;
    }
    return OcrNutritionBasis.unknown;
  }

  _Serving _detectServing(List<String> lines) {
    for (final line in lines) {
      final normalized = _normalize(line);
      if (!normalized.contains('porcion') && !normalized.contains('racion')) {
        continue;
      }
      final match = RegExp(
        r'(\d+(?:[\.,]\d+)?)\s*(g|gr|gramos|ml|cc)',
      ).firstMatch(normalized);
      if (match == null) {
        continue;
      }
      return _Serving(
        size: _parseNumber(match.group(1)),
        unit: _normalizeUnit(match.group(2)),
      );
    }
    return const _Serving();
  }

  bool _servingColumnBeforePer100(List<String> lines) {
    for (final line in lines) {
      final normalized = _normalize(line);
      if (!normalized.contains('100') || !normalized.contains('porcion')) {
        continue;
      }
      return normalized.indexOf('porcion') < normalized.indexOf('100');
    }
    return false;
  }

  OcrNutritionValues _parseValues(
    List<String> lines, {
    required bool takeLastValue,
  }) {
    return OcrNutritionValues(
      calories: _findValue(lines, _Nutrient.calories, takeLastValue),
      protein: _findValue(lines, _Nutrient.protein, takeLastValue),
      carbs: _findValue(lines, _Nutrient.carbs, takeLastValue),
      fat: _findValue(lines, _Nutrient.fat, takeLastValue),
      sugar: _findValue(lines, _Nutrient.sugar, takeLastValue),
      saturatedFat: _findValue(lines, _Nutrient.saturatedFat, takeLastValue),
      sodium: _findValue(lines, _Nutrient.sodium, takeLastValue),
      fiber: _findValue(lines, _Nutrient.fiber, takeLastValue),
    );
  }

  double? _findValue(
    List<String> lines,
    _Nutrient nutrient,
    bool takeLastValue,
  ) {
    for (final line in lines) {
      final normalized = _normalize(line);
      if (!_matchesNutrient(normalized, nutrient)) {
        continue;
      }
      if (nutrient == _Nutrient.calories) {
        final kcalValue = _extractKcalValue(normalized, takeLastValue);
        if (kcalValue != null) {
          return kcalValue;
        }
      }
      final numbers = _extractNumbers(normalized);
      if (numbers.isEmpty) {
        continue;
      }
      if (nutrient == _Nutrient.calories &&
          numbers.length >= 2 &&
          numbers.first > 1000 &&
          numbers[1] < 1000) {
        return numbers[1];
      }
      return takeLastValue ? numbers.last : numbers.first;
    }
    return null;
  }

  bool _matchesNutrient(String line, _Nutrient nutrient) {
    return switch (nutrient) {
      _Nutrient.calories =>
        line.contains('energia') ||
            line.contains('caloria') ||
            line.contains('kcal'),
      _Nutrient.protein => line.contains('proteina'),
      _Nutrient.carbs =>
        line.contains('carbohidrato') || line.contains('hidratos'),
      _Nutrient.sugar => line.contains('azucar'),
      _Nutrient.saturatedFat =>
        line.contains('grasa') && line.contains('saturad'),
      _Nutrient.fat =>
        (line.contains('grasa') || line.contains('lipido')) &&
            !line.contains('saturad'),
      _Nutrient.sodium => line.contains('sodio'),
      _Nutrient.fiber => line.contains('fibra'),
    };
  }

  double? _extractKcalValue(String line, bool takeLastValue) {
    final matches = RegExp(
      r'(\d+(?:[\.,]\d+)?)\s*kcal',
    ).allMatches(line).toList(growable: false);
    if (matches.isEmpty) {
      return null;
    }
    return _parseNumber(
      (takeLastValue ? matches.last : matches.first).group(1),
    );
  }

  List<double> _extractNumbers(String line) {
    return RegExp(r'\d+(?:[\.,]\d+)?')
        .allMatches(line)
        .map((match) => _parseNumber(match.group(0)))
        .whereType<double>()
        .toList(growable: false);
  }

  OcrNutritionValues _normalizeServingValues(
    OcrNutritionValues values,
    double servingSize,
  ) {
    double? normalize(double? value) {
      if (value == null) {
        return null;
      }
      return value * 100 / servingSize;
    }

    return OcrNutritionValues(
      calories: normalize(values.calories),
      protein: normalize(values.protein),
      carbs: normalize(values.carbs),
      fat: normalize(values.fat),
      sugar: normalize(values.sugar),
      saturatedFat: normalize(values.saturatedFat),
      sodium: normalize(values.sodium),
      fiber: normalize(values.fiber),
    );
  }

  double? _parseNumber(String? value) {
    return double.tryParse(value?.replaceAll(',', '.') ?? '');
  }

  String? _normalizeUnit(String? value) {
    if (value == null) {
      return null;
    }
    if (value == 'ml' || value == 'cc') {
      return 'ml';
    }
    return 'g';
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[áàäâã]'), 'a')
        .replaceAll(RegExp('[éèëê]'), 'e')
        .replaceAll(RegExp('[íìïî]'), 'i')
        .replaceAll(RegExp('[óòöôõ]'), 'o')
        .replaceAll(RegExp('[úùüû]'), 'u')
        .replaceAll('ñ', 'n');
  }
}

enum _Nutrient {
  calories,
  protein,
  carbs,
  fat,
  sugar,
  saturatedFat,
  sodium,
  fiber,
}

class _Serving {
  const _Serving({this.size, this.unit});

  final double? size;
  final String? unit;
}
