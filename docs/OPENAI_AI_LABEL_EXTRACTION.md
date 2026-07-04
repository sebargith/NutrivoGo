# OpenAI AI Label Extraction

NutrivoGo keeps ML Kit OCR as the default nutrition label flow. The optional `Improve with AI` button sends the captured label image to a Supabase Edge Function, which calls OpenAI from the backend and returns structured nutrition data for the existing editable confirmation screen.

## Security Model

- Flutter never calls OpenAI directly.
- The OpenAI API key is never stored in Flutter, Android, Windows, GitHub, or client-side code.
- Store the key only as a Supabase Edge Function secret named `OPENAI_API_KEY`.
- Optional model override: `OPENAI_LABEL_MODEL`.
- The app never auto-saves AI results. The user must review and tap Save Product.

## Edge Function

Function path:

```text
supabase/functions/analyze-nutrition-label/index.ts
```

Deploy:

```powershell
supabase functions deploy analyze-nutrition-label
```

Set secrets:

```powershell
supabase secrets set OPENAI_API_KEY=your_openai_api_key
supabase secrets set OPENAI_LABEL_MODEL=gpt-4.1-mini
```

The function expects:

```json
{
  "image_base64": "...",
  "mime_type": "image/jpeg",
  "ocr_text": "raw ML Kit OCR text",
  "current_values": {}
}
```

The function returns:

```json
{
  "result": {
    "product_name": null,
    "brand": null,
    "serving_size": 140,
    "serving_unit": "g",
    "basis": "per_100g",
    "calories_kcal": 65,
    "protein_g": 8.8,
    "carbs_g": 5.9,
    "fat_g": 0.7,
    "sugar_g": 5.9,
    "saturated_fat_g": 0.4,
    "sodium_mg": 65,
    "fiber_g": null,
    "per_serving": null,
    "warnings": ["Review inferred values before saving."],
    "confidence": 0.8
  }
}
```

## User Flow

1. Scan nutrition label with ML Kit OCR.
2. Review the normal OCR confirmation screen.
3. Tap `Improve with AI`.
4. The app shows upload/analyze/result/failure states.
5. AI values are merged into the editable fields only on success.
6. If AI fails, existing OCR/manual values remain unchanged.
7. The user reviews and saves manually.

## Validation Rules

- Decimal commas are normalized, for example `8,8` becomes `8.8`.
- Sodium stays in `mg`.
- Calories stay in `kcal`; if kJ and kcal are visible, prefer kcal.
- If only per-serving values are found, NutrivoGo shows them as per-serving and does not silently normalize them.
- Low confidence or inferred values produce warnings.

## OpenAI References

- Responses API create response: https://developers.openai.com/api/reference/resources/responses/methods/create/
- Images and vision: https://developers.openai.com/api/docs/guides/images-vision
- Structured outputs: https://developers.openai.com/api/docs/guides/structured-outputs
