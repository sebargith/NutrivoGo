import 'dart:io';

import 'package:supabase/supabase.dart';

class OcrReportImageUploadResult {
  const OcrReportImageUploadResult({required this.storagePath});

  final String storagePath;
}

abstract class SyncRemoteDataSource {
  String? get currentUserId;

  String? get currentUserEmail;

  Future<List<Map<String, dynamic>>> fetchProducts(String userId);

  Future<List<Map<String, dynamic>>> fetchLogItems(String userId);

  Future<List<Map<String, dynamic>>> fetchOcrScanReports(String userId);

  Future<void> upsertProduct(Map<String, dynamic> row);

  Future<void> upsertLogItem(Map<String, dynamic> row);

  Future<void> upsertOcrScanReport(Map<String, dynamic> row);

  Future<OcrReportImageUploadResult?> uploadOcrReportImage({
    required String userId,
    required String reportId,
    required String imagePathLocal,
  });
}

class SupabaseSyncRemoteDataSource implements SyncRemoteDataSource {
  const SupabaseSyncRemoteDataSource({required this.client});

  final SupabaseClient client;
  static const _ocrImageBucket = 'ocr-debug-images';

  @override
  String? get currentUserId => client.auth.currentUser?.id;

  @override
  String? get currentUserEmail => client.auth.currentUser?.email;

  @override
  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    final rows = await client.from('products').select().eq('user_id', userId);
    return [for (final row in rows) Map<String, dynamic>.from(row)];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLogItems(String userId) async {
    final rows = await client.from('log_items').select().eq('user_id', userId);
    return [for (final row in rows) Map<String, dynamic>.from(row)];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchOcrScanReports(String userId) async {
    final rows = await client
        .from('ocr_scan_reports')
        .select()
        .eq('user_id', userId);
    return [for (final row in rows) Map<String, dynamic>.from(row)];
  }

  @override
  Future<void> upsertProduct(Map<String, dynamic> row) async {
    await client.from('products').upsert(row, onConflict: 'id');
  }

  @override
  Future<void> upsertLogItem(Map<String, dynamic> row) async {
    await client.from('log_items').upsert(row, onConflict: 'id');
  }

  @override
  Future<void> upsertOcrScanReport(Map<String, dynamic> row) async {
    await client.from('ocr_scan_reports').upsert(row, onConflict: 'id');
  }

  @override
  Future<OcrReportImageUploadResult?> uploadOcrReportImage({
    required String userId,
    required String reportId,
    required String imagePathLocal,
  }) async {
    final file = File(imagePathLocal);
    if (!await file.exists()) {
      return null;
    }
    final storagePath = '$userId/$reportId/original.jpg';
    final bytes = await file.readAsBytes();
    await client.storage
        .from(_ocrImageBucket)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return OcrReportImageUploadResult(storagePath: storagePath);
  }
}
