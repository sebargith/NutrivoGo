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
    final reconstructedTable = _parseReconstructedTable(lines, serving);
    final servingBeforePer100 = _servingColumnBeforePer100(lines);
    final sourceValues =
        reconstructedTable?.per100Values ??
        _parseValues(
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
        warnings: reconstructedTable?.warnings ?? const <String>[],
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
      perServingValues: reconstructedTable?.perServingValues,
      warnings: reconstructedTable?.warnings ?? const <String>[],
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
    if (_hasServingHeader(normalizedText) ||
        normalizedText.contains('por porcion') ||
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

  _ReconstructedTable? _parseReconstructedTable(
    List<String> lines,
    _Serving serving,
  ) {
    final rows = <_TableRow>[];
    var per100HeaderIndex = -1;

    for (var index = 0; index < lines.length; index++) {
      final normalized = _normalize(lines[index]);
      if (_isPer100Header(normalized)) {
        per100HeaderIndex = index;
        break;
      }
      final row = _tableRowFor(normalized);
      if (row != null) {
        rows.add(row);
      }
    }

    if (per100HeaderIndex == -1 || rows.length < 4) {
      return null;
    }

    final servingHeaderIndex = _findServingHeaderIndex(
      lines,
      startIndex: per100HeaderIndex + 1,
    );
    final per100Numbers = _collectStandaloneNumbers(
      lines,
      startIndex: per100HeaderIndex + 1,
      endIndex: servingHeaderIndex == -1 ? lines.length : servingHeaderIndex,
    );
    if (per100Numbers.length < 4) {
      return null;
    }

    final warnings = <String>[
      'Values were inferred from reconstructed OCR table order. Review before saving.',
    ];
    final per100Values = _assignColumnValues(
      rows: rows,
      numbers: per100Numbers,
      warnings: warnings,
    );

    OcrNutritionValues? perServingValues;
    if (servingHeaderIndex != -1) {
      final servingNumbers = _collectStandaloneNumbers(
        lines,
        startIndex: servingHeaderIndex + 1,
        endIndex: lines.length,
        stopAtNonNutritionSection: true,
      );
      if (servingNumbers.isNotEmpty) {
        perServingValues = _assignColumnValues(
          rows: rows,
          numbers: servingNumbers,
          warnings: warnings,
          expectedFromPer100: per100Values,
          servingSize: serving.size,
        );
      }
    }

    return _ReconstructedTable(
      per100Values: per100Values,
      perServingValues: perServingValues,
      warnings: warnings,
    );
  }

  int _findServingHeaderIndex(List<String> lines, {required int startIndex}) {
    for (var index = startIndex; index < lines.length; index++) {
      if (_isPerServingHeader(_normalize(lines[index]))) {
        return index;
      }
    }
    return -1;
  }

  List<double> _collectStandaloneNumbers(
    List<String> lines, {
    required int startIndex,
    required int endIndex,
    bool stopAtNonNutritionSection = false,
  }) {
    final numbers = <double>[];
    for (var index = startIndex; index < endIndex; index++) {
      final normalized = _normalize(lines[index]);
      if (stopAtNonNutritionSection && _isNonNutritionSection(normalized)) {
        break;
      }
      if (_isPer100Header(normalized) || _isPerServingHeader(normalized)) {
        break;
      }
      final match = RegExp(r'^\s*\d+(?:[\.,]\d+)?\s*$').firstMatch(normalized);
      if (match == null) {
        if (numbers.isNotEmpty && stopAtNonNutritionSection) {
          break;
        }
        continue;
      }
      final value = _parseNumber(match.group(0));
      if (value != null) {
        numbers.add(value);
      }
    }
    return numbers;
  }

  OcrNutritionValues _assignColumnValues({
    required List<_TableRow> rows,
    required List<double> numbers,
    required List<String> warnings,
    OcrNutritionValues? expectedFromPer100,
    double? servingSize,
  }) {
    final values = <_Nutrient, double>{};
    var cursor = 0;

    for (final row in rows) {
      if (cursor >= numbers.length) {
        break;
      }

      final nutrient = row.nutrient;
      if (nutrient == null) {
        if (_shouldConsumeIgnoredValue(row.ignored, numbers[cursor])) {
          cursor += 1;
        } else {
          warnings.add(
            'Skipped likely missing zero for ${row.label} while reconstructing OCR table.',
          );
        }
        continue;
      }

      if (expectedFromPer100 != null && servingSize != null) {
        final expected = _expectedServingValue(
          nutrient,
          expectedFromPer100,
          servingSize,
        );
        if (expected != null &&
            cursor + 1 < numbers.length &&
            _isCloser(numbers[cursor + 1], numbers[cursor], expected)) {
          warnings.add(
            'Skipped ${numbers[cursor]} before ${row.label}; next value matched serving-size expectation better.',
          );
          cursor += 1;
        }
      }

      values[nutrient] = numbers[cursor];
      cursor += 1;
    }

    return OcrNutritionValues(
      calories: values[_Nutrient.calories],
      protein: values[_Nutrient.protein],
      carbs: values[_Nutrient.carbs],
      fat: values[_Nutrient.fat],
      sugar: values[_Nutrient.sugar],
      saturatedFat: values[_Nutrient.saturatedFat],
      sodium: values[_Nutrient.sodium],
      fiber: values[_Nutrient.fiber],
    );
  }

  bool _shouldConsumeIgnoredValue(_IgnoredRow ignored, double nextValue) {
    return switch (ignored) {
      _IgnoredRow.transFat => nextValue <= 1,
      _IgnoredRow.sucrose => nextValue <= 0.05,
      _ => true,
    };
  }

  bool _isCloser(double candidate, double current, double expected) {
    return (candidate - expected).abs() + 0.05 < (current - expected).abs();
  }

  double? _expectedServingValue(
    _Nutrient nutrient,
    OcrNutritionValues per100Values,
    double servingSize,
  ) {
    final per100 = switch (nutrient) {
      _Nutrient.calories => per100Values.calories,
      _Nutrient.protein => per100Values.protein,
      _Nutrient.carbs => per100Values.carbs,
      _Nutrient.fat => per100Values.fat,
      _Nutrient.sugar => per100Values.sugar,
      _Nutrient.saturatedFat => per100Values.saturatedFat,
      _Nutrient.sodium => per100Values.sodium,
      _Nutrient.fiber => per100Values.fiber,
    };
    if (per100 == null) {
      return null;
    }
    return per100 * servingSize / 100;
  }

  _TableRow? _tableRowFor(String line) {
    if (line.contains('edulcorante') ||
        line.contains('sucralosa') ||
        line.contains('estevia') ||
        line.contains('esteviol') ||
        line.contains('i.d.a') ||
        line.contains('ingesta diaria')) {
      return null;
    }
    if (_matchesNutrient(line, _Nutrient.calories)) {
      return const _TableRow.nutrient(_Nutrient.calories, 'Energía');
    }
    if (_matchesNutrient(line, _Nutrient.protein)) {
      return const _TableRow.nutrient(_Nutrient.protein, 'Proteínas');
    }
    if (_matchesNutrient(line, _Nutrient.saturatedFat)) {
      return const _TableRow.nutrient(_Nutrient.saturatedFat, 'Grasa saturada');
    }
    if (line.contains('monoinsat')) {
      return const _TableRow.ignored(
        _IgnoredRow.monounsaturatedFat,
        'Grasa monoinsaturada',
      );
    }
    if (line.contains('poliinsat')) {
      return const _TableRow.ignored(
        _IgnoredRow.polyunsaturatedFat,
        'Grasa poliinsaturada',
      );
    }
    if (line.contains('trans')) {
      return const _TableRow.ignored(_IgnoredRow.transFat, 'Grasas trans');
    }
    if (_matchesNutrient(line, _Nutrient.fat)) {
      return const _TableRow.nutrient(_Nutrient.fat, 'Grasa total');
    }
    if (line.contains('colesterol')) {
      return const _TableRow.ignored(_IgnoredRow.cholesterol, 'Colesterol');
    }
    if (_matchesNutrient(line, _Nutrient.carbs)) {
      return const _TableRow.nutrient(_Nutrient.carbs, 'Carbohidratos');
    }
    if (line.contains('sacarosa')) {
      return const _TableRow.ignored(_IgnoredRow.sucrose, 'Azúcar sacarosa');
    }
    if (line.contains('lactosa')) {
      return const _TableRow.ignored(_IgnoredRow.lactose, 'Lactosa');
    }
    if (_matchesNutrient(line, _Nutrient.sugar)) {
      return const _TableRow.nutrient(_Nutrient.sugar, 'Azúcares');
    }
    if (_matchesNutrient(line, _Nutrient.sodium)) {
      return const _TableRow.nutrient(_Nutrient.sodium, 'Sodio');
    }
    if (_matchesNutrient(line, _Nutrient.fiber)) {
      return const _TableRow.nutrient(_Nutrient.fiber, 'Fibra');
    }
    if (line.contains('calcio')) {
      return const _TableRow.ignored(_IgnoredRow.calcium, 'Calcio');
    }
    return null;
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
        line.contains('carbohidrato') ||
            line.contains('hidratos') ||
            line.contains('h. de c') ||
            line.contains('h de c'),
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
    final withoutUnitMistakes = line.replaceAll(
      RegExp(r'\((?:g|9|a|mg|ng|kcal)\)'),
      '',
    );
    return RegExp(r'\d+(?:[\.,]\d+)?')
        .allMatches(withoutUnitMistakes)
        .map((match) => _parseNumber(match.group(0)))
        .whereType<double>()
        .toList(growable: false);
  }

  bool _isPer100Header(String line) {
    return RegExp(r'(^|\s)100\s*(g|ml)($|\s)').hasMatch(line);
  }

  bool _isPerServingHeader(String line) {
    return _hasServingHeader(line);
  }

  bool _hasServingHeader(String line) {
    return RegExp(
      r'(^|\s)1\s*(porcion|pordon|pocon|porcon)($|\s)',
    ).hasMatch(line);
  }

  bool _isNonNutritionSection(String line) {
    return line.contains('% en relacion') ||
        line.contains('dosis de edulcorantes') ||
        line.contains('edulcorante') ||
        line.contains('sucralosa') ||
        line.contains('estevia') ||
        line.contains('esteviol') ||
        line.contains('admisible');
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

enum _IgnoredRow {
  monounsaturatedFat,
  polyunsaturatedFat,
  transFat,
  cholesterol,
  sucrose,
  lactose,
  calcium,
}

class _TableRow {
  const _TableRow.nutrient(this.nutrient, this.label)
    : ignored = _IgnoredRow.calcium;

  const _TableRow.ignored(this.ignored, this.label) : nutrient = null;

  final _Nutrient? nutrient;
  final _IgnoredRow ignored;
  final String label;
}

class _ReconstructedTable {
  const _ReconstructedTable({
    required this.per100Values,
    required this.warnings,
    this.perServingValues,
  });

  final OcrNutritionValues per100Values;
  final OcrNutritionValues? perServingValues;
  final List<String> warnings;
}

class _Serving {
  const _Serving({this.size, this.unit});

  final double? size;
  final String? unit;
}
