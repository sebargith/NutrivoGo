# OCR Label Testing

NutrivoGo OCR is mobile-first. Android can scan nutrition labels with the camera. Windows shows an unsupported OCR message and keeps manual product creation available.

Use OCR Reports to collect real failed cases before changing the parser:

1. Scan the label on Android.
2. Review and correct values in the OCR confirmation screen.
3. Mark whether the parser was correct, incorrect, or unsure.
4. Add a short comment when the parser failed.
5. Open Settings > OCR Reports.
6. Export OCR cases before asking Codex to improve the parser.

Parser fixes should use real exported failed cases as regression tests.

## Android Flow

1. Open Add Food.
2. Tap Scan nutrition label.
3. Frame the label clearly with good lighting.
4. Tap Capture Label.
5. Review the confirmation screen before saving.
6. Edit product name, serving size, base unit, or nutrition values as needed.
7. Save Product.
8. Confirm the product appears in the food log quantity flow.
9. Confirm Settings shows the product pending briefly, then synced if logged in.

## What To Check

- Labels with `Por 100 g` should prefill per-100 gram values.
- Labels with `Por 100 ml` should prefill per-100 milliliter values.
- Labels with only `Por porción` should show detected per-serving values and normalized per-100 values if the serving size was detected.
- Incomplete OCR results should remain editable and should not save until required macro fields are filled.
- OCR results are never saved automatically; the confirmation screen must be accepted first.

## Windows Flow

1. Open Add Food on Windows.
2. Tap Scan nutrition label.
3. Confirm the unsupported OCR message appears.
4. Return to Add Food and use Create Product for manual entry.

## Useful Chilean Label Terms

- Energía / Calorías / kcal
- Proteínas
- Carbohidratos / Hidratos de carbono
- Azúcares
- Grasas / Lípidos
- Grasas saturadas
- Sodio
- Fibra
- Porción
- Por 100 g / Por 100 ml / Por porción
