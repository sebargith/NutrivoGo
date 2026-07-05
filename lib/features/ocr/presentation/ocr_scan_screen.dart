import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../application/nutrition_label_ocr_parser.dart';
import '../domain/nutrition_label_ocr_draft.dart';

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({
    super.key,
    this.isScannerSupportedOverride,
    this.parser = const NutritionLabelOcrParser(),
  });

  final bool? isScannerSupportedOverride;
  final NutritionLabelOcrParser parser;

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  CameraController? _controller;
  bool _isInitializing = false;
  bool _isProcessing = false;
  String? _errorMessage;

  bool get _isSupported =>
      widget.isScannerSupportedOverride ??
      OcrScannerSupport.isSupported(defaultTargetPlatform);

  @override
  void initState() {
    super.initState();
    if (_isSupported) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Nutrition Label')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _isSupported ? _buildScanner(context) : _UnsupportedOcr(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanner(BuildContext context) {
    final controller = _controller;
    final isReady = controller?.value.isInitialized == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: isReady
                  ? CameraPreview(controller!)
                  : Center(
                      child: _errorMessage == null
                          ? const CircularProgressIndicator()
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Frame the nutrition label as flat and well lit as possible.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: isReady && !_isProcessing ? _captureAndReadText : null,
          icon: Icon(
            _isProcessing ? Icons.hourglass_top : Icons.document_scanner,
          ),
          label: Text(_isProcessing ? 'Reading label' : 'Capture Label'),
        ),
      ],
    );
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera was found on this device.');
      }
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Could not start the camera. $error';
      });
    }
  }

  Future<void> _captureAndReadText() async {
    final controller = _controller;
    if (controller == null || _isProcessing || _isInitializing) {
      return;
    }
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final image = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await recognizer.processImage(inputImage);
      final rawText = recognizedText.text.trim();
      if (rawText.isEmpty) {
        throw StateError('No readable nutrition text was detected.');
      }
      final draft = widget.parser
          .parse(rawText)
          .copyWith(imagePathLocal: image.path);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop<NutritionLabelOcrDraft>(draft);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = 'Could not read the label. $error');
    } finally {
      await recognizer.close();
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

class OcrScannerSupport {
  const OcrScannerSupport._();

  static bool isSupported(TargetPlatform platform) {
    return platform == TargetPlatform.android;
  }
}

class _UnsupportedOcr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Nutrition label OCR is not supported on this platform',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use Android to scan labels. On Windows, create the product manually.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Create manually'),
            ),
          ],
        ),
      ),
    );
  }
}
