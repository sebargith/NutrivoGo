import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    if (analysis.status == GeminiProductStatus.error) {
      throw GeminiProductException(_friendlyError(decoded['error'] as String?));
    }
    return analysis;
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
