import 'dart:convert';

import '../domain/ocr_scan_report.dart';

class OcrReportExporter {
  const OcrReportExporter();

  String exportJson(Iterable<OcrScanReport> reports) {
    final rows = [for (final report in reports) report.toExportJson()];
    return const JsonEncoder.withIndent('  ').convert(rows);
  }
}
