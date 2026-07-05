# OCR Scan Reports

NutrivoGo stores OCR scan reports to build a private debugging dataset for Chilean nutrition labels.

An OCR report is not a food log and is not included in daily calories or macros. It exists only to improve the label parser over time.

## What is stored

Each report stores:

- Raw ML Kit OCR text from the scanned label.
- Parsed JSON from the parser before the user edits values.
- Corrected JSON with the final values saved by the user.
- Parser basis, warnings, and confidence when available.
- User feedback: correct, incorrect, or unsure.
- Optional user comment explaining what went wrong.
- Linked product id/name when the OCR product was saved.
- Platform and app version.
- Optional image metadata for the scanned nutrition table.

Raw OCR text, parsed JSON, and corrected JSON are all kept because they answer different questions:

- Raw OCR text shows what ML Kit actually detected.
- Parsed JSON shows how NutrivoGo interpreted that text.
- Corrected JSON shows what the user decided was correct after review.

## Image handling

Images are useful when the parser fails because table layout, lighting, blur, or crop issues are often visible only in the image.

Image blobs are not stored in Postgres. NutrivoGo stores image paths in `ocr_scan_reports` and uploads images to the private Supabase Storage bucket `ocr-debug-images` when sync is available.

The default setting is:

`Solo cuando OCR estuvo incorrecto`

The available settings are:

- `Nunca`: do not keep OCR image metadata for upload.
- `Solo cuando OCR estuvo incorrecto`: keep images only for incorrect or unsure reports.
- `Siempre`: keep image metadata for every OCR report.

If image upload fails, the OCR report is still saved and synced without blocking product saving.

## Privacy and sync

OCR reports sync through Supabase using the same personal account model as products and logs. Row Level Security requires `user_id = auth.uid()`.

Storage policies keep `ocr-debug-images` private and limit access to each user's own folder:

`user_id/report_id/original.jpg`

Cropped table images are not implemented yet. For now, NutrivoGo stores the captured OCR image path when the setting allows it. Cropped-table uploads are a future improvement.

## Exporting cases

Open Settings, then OCR Reports, then use `Export OCR cases`.

The app copies JSON to the clipboard. The export includes:

- `created_at`
- `platform`
- `raw_ocr_text`
- `parsed_json`
- `corrected_json`
- `was_parser_correct`
- `user_feedback`
- `detected_basis`
- `parser_warnings`
- `parser_confidence`
- `product_name`
- `barcode`
- `image_saved`
- `image_storage_path`
- `image_crop_storage_path`

Use exported failed cases to add parser regression tests before changing the Chilean nutrition parser.
