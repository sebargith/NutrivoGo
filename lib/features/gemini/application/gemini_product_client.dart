import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import '../../../core/supabase/supabase_config.dart';
import '../domain/gemini_product_analysis.dart';

class GeminiProductException implements Exception {
  const GeminiProductException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class GeminiProductClient {
  Future<GeminiProductAnalysis> analyzeGenericFood({
    required String query,
    String locale = 'Chile',
    String? baseUnitPreference,
  });

  Future<GeminiProductAnalysis> analyzeNutritionLabelImage({
    required String imagePath,
    String? rawOcrText,
    String? hint,
  });
}

class SupabaseGeminiProductClient implements GeminiProductClient {
  SupabaseGeminiProductClient({required this.client, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final SupabaseClient client;
  final http.Client _httpClient;

  Uri get _functionUri {
    return Uri.parse(
      '${SupabaseConfig.url}/functions/v1/analyze-product-gemini',
    );
  }

  @override
  Future<GeminiProductAnalysis> analyzeGenericFood({
    required String query,
    String locale = 'Chile',
    String? baseUnitPreference,
  }) {
    final body = <String, Object?>{
      'mode': GeminiProductMode.genericFood.storageValue,
      'query': query,
      'locale': locale,
      if (kDebugMode) 'debug': true,
    };
    if (baseUnitPreference != null) {
      body['base_unit_preference'] = baseUnitPreference;
    }
    return _invoke(body);
  }

  @override
  Future<GeminiProductAnalysis> analyzeNutritionLabelImage({
    required String imagePath,
    String? rawOcrText,
    String? hint,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw const GeminiProductException('No se encontró la imagen.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      throw const GeminiProductException(
        'La imagen es demasiado grande para analizar con Gemini.',
      );
    }
    return _invoke({
      'mode': GeminiProductMode.nutritionLabelImage.storageValue,
      'image_base64': base64Encode(bytes),
      'image_mime_type': _mimeTypeForPath(imagePath),
      if (kDebugMode) 'debug': true,
      if (rawOcrText?.trim().isNotEmpty == true) 'raw_ocr_text': rawOcrText,
      if (hint?.trim().isNotEmpty == true) 'hint': hint,
    });
  }

  Future<GeminiProductAnalysis> _invoke(Map<String, Object?> body) async {
    final session = client.auth.currentSession;
    final accessToken = session?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw const GeminiProductException('Inicia sesión para usar Gemini.');
    }

    http.Response response;
    try {
      response = await _httpClient
          .post(
            _functionUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
              'apikey': SupabaseConfig.publishableKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw const GeminiProductException(
        'No se pudo analizar con Gemini: tiempo de espera agotado.',
      );
    } on SocketException {
      throw const GeminiProductException(
        'No se pudo analizar con Gemini: sin conexión.',
      );
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } on Object {
      throw const GeminiProductException(
        'Gemini devolvió una respuesta inválida.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GeminiProductException(_friendlyError(decoded['error'] as String?));
    }

    final analysis = GeminiProductAnalysis.fromJson(decoded);
    _debugLogGeminiResponse(body, decoded, analysis);
    if (analysis.status == GeminiProductStatus.error) {
      throw GeminiProductException(_friendlyError(decoded['error'] as String?));
    }
    return analysis;
  }

  void _debugLogGeminiResponse(
    Map<String, Object?> requestBody,
    Map<String, dynamic> responseBody,
    GeminiProductAnalysis analysis,
  ) {
    if (!kDebugMode || responseBody['debug'] == null) {
      return;
    }
    final sanitizedRequest = Map<String, Object?>.from(requestBody)
      ..remove('image_base64');
    final draft = analysis.draft;
    final draftJson = draft == null
        ? null
        : {
            'name': draft.name,
            'brand': draft.brand,
            'barcode': draft.barcode,
            'serving_size': draft.servingSize,
            'serving_unit': draft.servingUnit,
            'base_unit': draft.baseUnit.label,
            'calories_per_100': draft.caloriesPer100,
            'protein_per_100': draft.proteinPer100,
            'carbs_per_100': draft.carbsPer100,
            'fat_per_100': draft.fatPer100,
            'saturated_fat_per_100': draft.saturatedFatPer100,
            'sugar_per_100': draft.sugarPer100,
            'sodium_per_100': draft.sodiumPer100,
            'fiber_per_100': draft.fiberPer100,
            'source': draft.source,
          };
    const encoder = JsonEncoder.withIndent('  ');
    debugPrint(
      'Gemini product debug:\n'
      '${encoder.convert({'request': sanitizedRequest, 'flutter_received_json': responseBody, 'flutter_draft': draftJson})}',
      wrapWidth: 1024,
    );
  }

  String _friendlyError(String? value) {
    final message = value?.trim();
    if (message == null || message.isEmpty) {
      return 'No se pudo analizar con Gemini.';
    }
    if (message.toLowerCase().contains('config')) {
      return 'Falta configurar Gemini.';
    }
    if (message.toLowerCase().contains('quota') ||
        message.toLowerCase().contains('rate')) {
      return 'Límite de Gemini alcanzado.';
    }
    return message;
  }

  String _mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
