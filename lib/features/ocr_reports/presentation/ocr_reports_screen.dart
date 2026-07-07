import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../food_log/application/nutrivo_go_store.dart';
import '../application/ocr_report_exporter.dart';
import '../domain/ocr_scan_report.dart';

enum _ReportFilter { all, incorrect, unsure, correct }

class OcrReportsScreen extends StatefulWidget {
  const OcrReportsScreen({required this.store, super.key});

  final NutrivoGoStore store;

  @override
  State<OcrReportsScreen> createState() => _OcrReportsScreenState();
}

class _OcrReportsScreenState extends State<OcrReportsScreen> {
  _ReportFilter _filter = _ReportFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes OCR'),
        actions: [
          IconButton(
            tooltip: 'Exportar casos OCR',
            onPressed: _exportReports,
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.store,
          builder: (context, _) {
            final reports = _filteredReports(widget.store.ocrScanReports);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    SegmentedButton<_ReportFilter>(
                      segments: const [
                        ButtonSegment(
                          value: _ReportFilter.all,
                          label: Text('All'),
                        ),
                        ButtonSegment(
                          value: _ReportFilter.incorrect,
                          label: Text('Incorrect'),
                        ),
                        ButtonSegment(
                          value: _ReportFilter.unsure,
                          label: Text('Unsure'),
                        ),
                        ButtonSegment(
                          value: _ReportFilter.correct,
                          label: Text('Correct'),
                        ),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (selection) {
                        setState(() => _filter = selection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (reports.isEmpty)
                      const _EmptyReports()
                    else
                      for (final report in reports)
                        _ReportTile(
                          report: report,
                          onTap: () => _openReport(report),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<OcrScanReport> _filteredReports(List<OcrScanReport> reports) {
    return switch (_filter) {
      _ReportFilter.all => reports,
      _ReportFilter.incorrect =>
        reports.where((report) => report.wasParserCorrect == false).toList(),
      _ReportFilter.unsure =>
        reports.where((report) => report.wasParserCorrect == null).toList(),
      _ReportFilter.correct =>
        reports.where((report) => report.wasParserCorrect == true).toList(),
    };
  }

  Future<void> _exportReports() async {
    final json = const OcrReportExporter().exportJson(
      widget.store.ocrScanReports,
    );
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Casos OCR copiados como JSON')),
    );
  }

  void _openReport(OcrScanReport report) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => OcrReportDetailScreen(report: report),
      ),
    );
  }
}

class OcrReportDetailScreen extends StatelessWidget {
  const OcrReportDetailScreen({required this.report, super.key});

  final OcrScanReport report;

  @override
  Widget build(BuildContext context) {
    final imagePath = report.imagePathLocal;
    final localImage = imagePath == null ? null : File(imagePath);
    final hasLocalImage = localImage?.existsSync() == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte OCR')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SummaryCard(report: report),
                const SizedBox(height: 12),
                if (hasLocalImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(localImage!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                ],
                _TextCard(title: 'Texto OCR crudo', text: report.rawOcrText),
                const SizedBox(height: 12),
                _TextCard(
                  title: 'Valores interpretados',
                  text: _prettyJson(report.parsedMap),
                ),
                const SizedBox(height: 12),
                _TextCard(
                  title: 'Valores corregidos',
                  text: report.correctedMap == null
                      ? 'No hay valores corregidos guardados.'
                      : _prettyJson(report.correctedMap!),
                ),
                const SizedBox(height: 12),
                _TextCard(
                  title: 'Advertencias del parser',
                  text: report.warningList == null
                      ? 'Ninguna'
                      : _prettyJson(report.warningList!),
                ),
                const SizedBox(height: 12),
                _TextCard(
                  title: 'Comentario del usuario',
                  text: report.userFeedback?.trim().isNotEmpty == true
                      ? report.userFeedback!
                      : 'Sin comentario.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.onTap});

  final OcrScanReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warnings = report.warningList;
    final warningSummary = warnings == null || warnings.isEmpty
        ? 'No parser warnings'
        : warnings.take(2).join(' ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(_statusIcon(report.wasParserCorrect)),
        title: Text(
          report.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            _formatTimestamp(context, report.createdAt),
            report.statusLabel,
            if (report.parserConfidence != null)
              'confianza ${report.parserConfidence!.toStringAsFixed(2)}',
            warningSummary,
            report.syncStatus.storageValue,
          ].join(' - '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});

  final OcrScanReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Fecha',
              value: _formatTimestamp(context, report.createdAt),
            ),
            _SummaryRow(label: 'Estado', value: report.statusLabel),
            _SummaryRow(
              label: 'Base detectada',
              value: report.detectedBasis ?? 'Unknown',
            ),
            _SummaryRow(
              label: 'Confianza',
              value: report.parserConfidence?.toStringAsFixed(2) ?? 'Sin dato',
            ),
            _SummaryRow(
              label: 'Producto id',
              value: report.productId ?? 'Ninguno',
            ),
            _SummaryRow(label: 'Código', value: report.barcode ?? 'Ninguno'),
            _SummaryRow(label: 'Plataforma', value: report.platform),
            _SummaryRow(label: 'Sync', value: report.syncStatus.storageValue),
            _SummaryRow(
              label: 'Imagen',
              value: report.imageSaved
                  ? report.imageStoragePath ?? 'Guardada'
                  : report.imagePathLocal == null
                  ? 'No guardada'
                  : 'Subida pendiente',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: title == 'Texto OCR crudo',
        leading: const Icon(Icons.notes_outlined),
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(alignment: Alignment.centerLeft, child: SelectableText(text)),
        ],
      ),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 42,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reportes OCR todavía',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Scan and save an OCR product to collect parser debug cases.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(bool? wasParserCorrect) {
  return switch (wasParserCorrect) {
    true => Icons.check_circle_outline,
    false => Icons.error_outline,
    null => Icons.help_outline,
  };
}

String _formatTimestamp(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final material = MaterialLocalizations.of(context);
  final date = material.formatShortDate(local);
  final time = material.formatTimeOfDay(TimeOfDay.fromDateTime(local));
  return '$date $time';
}

String _prettyJson(Object value) {
  return const JsonEncoder.withIndent('  ').convert(value);
}
