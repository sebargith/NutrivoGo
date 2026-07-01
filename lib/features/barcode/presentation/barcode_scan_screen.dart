import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key, this.isScannerSupportedOverride});

  final bool? isScannerSupportedOverride;

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _manualController = TextEditingController();
  bool _didReturnBarcode = false;

  bool get _isScannerSupported {
    return widget.isScannerSupportedOverride ??
        BarcodeScannerSupport.isSupported(defaultTargetPlatform);
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (_isScannerSupported)
                  _ScannerPane(onBarcode: _returnBarcode),
                if (!_isScannerSupported) _UnsupportedScannerPane(),
                const SizedBox(height: 16),
                _ManualBarcodeEntry(
                  controller: _manualController,
                  onSubmit: _returnManualBarcode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _returnManualBarcode() {
    _returnBarcode(_manualController.text);
  }

  void _returnBarcode(String? value) {
    final barcode = value?.trim();
    if (barcode == null || barcode.isEmpty || _didReturnBarcode) {
      return;
    }
    _didReturnBarcode = true;
    Navigator.of(context).pop(barcode);
  }
}

class BarcodeScannerSupport {
  const BarcodeScannerSupport._();

  static bool isSupported(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => false,
    };
  }
}

class _ScannerPane extends StatelessWidget {
  const _ScannerPane({required this.onBarcode});

  final ValueChanged<String?> onBarcode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MobileScanner(
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      if (barcode.rawValue?.isNotEmpty == true) {
                        onBarcode(barcode.rawValue);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Apunta la cámara al código de barras.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnsupportedScannerPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.no_photography_outlined, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanner not supported on this platform',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barcode camera scanning is available on Android. On Windows, enter the barcode manually.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualBarcodeEntry extends StatelessWidget {
  const _ManualBarcodeEntry({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Barcode',
                prefixIcon: Icon(Icons.qr_code_2_outlined),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.search),
              label: const Text('Search Barcode'),
            ),
          ],
        ),
      ),
    );
  }
}
