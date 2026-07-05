enum OcrImageSavingMode {
  never('never'),
  incorrectOnly('incorrect_only'),
  always('always');

  const OcrImageSavingMode(this.storageValue);

  final String storageValue;

  static OcrImageSavingMode fromStorage(String? value) {
    return OcrImageSavingMode.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => OcrImageSavingMode.incorrectOnly,
    );
  }

  String get label {
    return switch (this) {
      OcrImageSavingMode.never => 'Nunca',
      OcrImageSavingMode.incorrectOnly => 'Solo cuando OCR estuvo incorrecto',
      OcrImageSavingMode.always => 'Siempre',
    };
  }
}
