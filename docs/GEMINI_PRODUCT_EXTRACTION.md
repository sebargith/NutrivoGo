# Gemini product extraction

NutrivoGo can optionally use Gemini to help create products. This is a fallback and review tool, not a source of truth.

## Architecture

- Flutter never calls Gemini directly.
- Flutter sends the request to the Supabase Edge Function `analyze-product-gemini`.
- The Edge Function verifies the signed-in Supabase user.
- The Edge Function reads `GEMINI_API_KEY` from Supabase secrets.
- The Edge Function calls Gemini and returns structured JSON.
- Flutter opens the existing editable confirmation screen.
- Nothing is saved until the user confirms.

Supported modes:

- `generic_food`: user writes a food description such as `plátano`, `huevo`, or `arroz cocido`.
- `nutrition_label_image`: user sends a captured nutrition label image, optionally with the local OCR text.

## Setup

Set the Gemini secret in Supabase:

```bash
supabase secrets set GEMINI_API_KEY=your_api_key_here
```

Optional model override:

```bash
supabase secrets set GEMINI_MODEL=gemini-2.5-flash-lite
```

Deploy the function:

```bash
supabase functions deploy analyze-product-gemini
```

Or with `npx`:

```bash
npx supabase functions deploy analyze-product-gemini
```

The Flutter app uses the normal Supabase publishable key and the active user session. Do not put the Gemini key in Flutter, Android, Windows, GitHub, or any client-side file.

## Manual testing

1. Log in to personal sync in NutrivoGo.
2. Open `Agregar alimento`.
3. Tap `Agregar con Gemini`.
4. Enter a generic food, for example `plátano`.
5. Review the generated product values.
6. Save only after checking the fields.

For label images:

1. Open `Agregar alimento`.
2. Scan a nutrition label with OCR.
3. On the confirmation screen, tap `Analizar con Gemini`.
4. Review confidence, warnings, assumptions, and all nutrition values.
5. Save only after checking the fields.

## Expected JSON contract

The function returns:

- `status`
- `source_mode`
- `product`
- `confidence`
- `warnings`
- `assumptions`
- `explanation`

Product fields include:

- `name`
- `brand`
- `serving_size`
- `serving_unit`
- `base_unit`
- `basis`
- `calories_per_100`
- `protein_per_100`
- `carbs_per_100`
- `fat_per_100`
- `saturated_fat_per_100`
- `sugar_per_100`
- `sodium_per_100`
- `fiber_per_100`
- optional `per_serving`

If the label only has per-serving values, the function should return `basis: per_serving` and warnings. Flutter will not silently normalize those values to per 100 g/ml.

## Debugging generic foods

In Flutter debug builds, the client sends `debug: true` to the Edge Function. The function response includes:

- `debug.mode`
- `debug.query`
- `debug.gemini_raw_json`
- `debug.normalized_response`

Flutter also prints a sanitized debug log with:

- request mode/query
- Flutter received JSON
- final Flutter product draft

The debug log does not include auth tokens, `GEMINI_API_KEY`, or image base64. For image mode, Flutter removes `image_base64` before logging.

For generic foods with empty macro fields, inspect the JSON path in this order:

1. `gemini_raw_json`: whether Gemini returned calories/protein/carbs/fat and where.
2. `normalized_response.product`: whether the Edge Function preserved them as `*_per_100`.
3. `flutter_draft`: whether Flutter mapped them into `caloriesPer100`, `proteinPer100`, `carbsPer100`, and `fatPer100`.

## Troubleshooting

- `Falta configurar Gemini`: set `GEMINI_API_KEY` as a Supabase secret and redeploy the function.
- `Límite de Gemini alcanzado`: wait for quota/rate limits to reset or use a different configured model.
- `Inicia sesión para usar Gemini`: log in to personal sync first.
- Incomplete values: fill the missing fields manually before saving.
- Generic foods show name but empty calories/protein/carbs/fat: deploy the latest Edge Function, then retest in a debug build and inspect the debug JSON path above.
- Flutter changes alone are not enough when the bug is in `supabase/functions/analyze-product-gemini/index.ts`; redeploy the function after backend changes.

References:

- Google Gemini structured output docs: https://ai.google.dev/gemini-api/docs/structured-output
- Google Gemini image input docs: https://ai.google.dev/gemini-api/docs/image-understanding
- Google Gemini generateContent API docs: https://ai.google.dev/api/generate-content
