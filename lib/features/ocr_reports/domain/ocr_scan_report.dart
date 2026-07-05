import 'dart:convert';

import '../../../core/sync/record_sync_status.dart';

class OcrScanReport {
  const OcrScanReport({
    required this.id,
    required this.rawOcrText,
    required this.parsedJson,
    required this.createdAt,
    required this.updatedAt,
    required this.platform,
    this.correctedJson,
    this.detectedBasis,
    this.parserWarnings,
    this.parserConfidence,
    this.wasParserCorrect,
    this.userFeedback,
    this.productId,
    this.productName,
    this.barcode,
    this.source = 'ocr',
    this.appVersion,
    this.imageSaved = false,
    this.imageStoragePath,
    this.imageCropStoragePath,
    this.imagePathLocal,
    this.deletedAt,
    this.userId,
    this.syncStatus = RecordSyncStatus.pending,
    this.lastSyncedAt,
  });

  final String id;
  final String rawOcrText;
  final String parsedJson;
  final String? correctedJson;
  final String? detectedBasis;
  final String? parserWarnings;
  final double? parserConfidence;
  final bool? wasParserCorrect;
  final String? userFeedback;
  final String? productId;
  final String? productName;
  final String? barcode;
  final String source;
  final String platform;
  final String? appVersion;
  final bool imageSaved;
  final String? imageStoragePath;
  final String? imageCropStoragePath;
  final String? imagePathLocal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;
  final RecordSyncStatus syncStatus;
  final DateTime? lastSyncedAt;

  String get statusLabel {
    return switch (wasParserCorrect) {
      true => 'Correct',
      false => 'Incorrect',
      null => 'Unsure',
    };
  }

  String get displayName {
    final name = productName?.trim();
    if (name == null || name.isEmpty) {
      return 'OCR report';
    }
    return name;
  }

  Map<String, dynamic> get parsedMap => _decodeMap(parsedJson);

  Map<String, dynamic>? get correctedMap {
    final value = correctedJson;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return _decodeMap(value);
  }

  List<dynamic>? get warningList {
    final value = parserWarnings;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(value);
    return decoded is List ? decoded : null;
  }

  Map<String, dynamic> toExportJson() {
    return {
      'created_at': createdAt.toUtc().toIso8601String(),
      'platform': platform,
      'raw_ocr_text': rawOcrText,
      'parsed_json': parsedMap,
      'corrected_json': correctedMap,
      'was_parser_correct': wasParserCorrect,
      'user_feedback': userFeedback,
      'detected_basis': detectedBasis,
      'parser_warnings': warningList,
      'parser_confidence': parserConfidence,
      'product_name': productName,
      'barcode': barcode,
      'image_saved': imageSaved,
      'image_storage_path': imageStoragePath,
      'image_crop_storage_path': imageCropStoragePath,
    };
  }

  static Map<String, dynamic> _decodeMap(String value) {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}
