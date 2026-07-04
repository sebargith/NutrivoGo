const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const schema = {
  type: "object",
  additionalProperties: false,
  required: [
    "product_name",
    "brand",
    "serving_size",
    "serving_unit",
    "basis",
    "calories_kcal",
    "protein_g",
    "carbs_g",
    "fat_g",
    "sugar_g",
    "saturated_fat_g",
    "sodium_mg",
    "fiber_g",
    "per_serving",
    "warnings",
    "confidence",
  ],
  properties: {
    product_name: { type: ["string", "null"] },
    brand: { type: ["string", "null"] },
    serving_size: { type: ["number", "null"] },
    serving_unit: { type: ["string", "null"], enum: ["g", "ml", null] },
    basis: {
      type: "string",
      enum: ["per_100g", "per_100ml", "per_serving", "unknown"],
    },
    calories_kcal: { type: ["number", "null"] },
    protein_g: { type: ["number", "null"] },
    carbs_g: { type: ["number", "null"] },
    fat_g: { type: ["number", "null"] },
    sugar_g: { type: ["number", "null"] },
    saturated_fat_g: { type: ["number", "null"] },
    sodium_mg: { type: ["number", "null"] },
    fiber_g: { type: ["number", "null"] },
    per_serving: {
      type: ["object", "null"],
      additionalProperties: false,
      required: [
        "calories_kcal",
        "protein_g",
        "carbs_g",
        "fat_g",
        "sugar_g",
        "saturated_fat_g",
        "sodium_mg",
        "fiber_g",
      ],
      properties: {
        calories_kcal: { type: ["number", "null"] },
        protein_g: { type: ["number", "null"] },
        carbs_g: { type: ["number", "null"] },
        fat_g: { type: ["number", "null"] },
        sugar_g: { type: ["number", "null"] },
        saturated_fat_g: { type: ["number", "null"] },
        sodium_mg: { type: ["number", "null"] },
        fiber_g: { type: ["number", "null"] },
      },
    },
    warnings: { type: "array", items: { type: "string" } },
    confidence: { type: "number", minimum: 0, maximum: 1 },
  },
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) {
    return json({ error: "OPENAI_API_KEY is not configured." }, 500);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON body." }, 400);
  }

  const imageBase64 = stringValue(body.image_base64);
  const mimeType = stringValue(body.mime_type) ?? "image/jpeg";
  const ocrText = stringValue(body.ocr_text);
  if (!imageBase64) {
    return json({ error: "image_base64 is required." }, 400);
  }
  if (!["image/jpeg", "image/png", "image/webp"].includes(mimeType)) {
    return json({ error: "Unsupported image mime type." }, 400);
  }

  const model = Deno.env.get("OPENAI_LABEL_MODEL") ?? "gpt-4.1-mini";
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      store: false,
      input: [
        {
          role: "developer",
          content: [
            {
              type: "input_text",
              text:
                "Extract Chilean/Spanish nutrition label data. Return only schema fields. Preserve sodium in mg and calories in kcal. Prefer kcal over kJ. Prefer per 100 g/ml values. If only per-serving values are visible, set basis per_serving and do not infer per-100 silently. Add warnings for inferred or uncertain values.",
            },
          ],
        },
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: [
                "Analyze this nutrition label image.",
                "Recognize: Información nutricional, Energía/Calorías/kcal, Proteínas, Grasa total, Grasas saturadas, H. de C. Disp., Carbohidratos, Hidratos de carbono, Azúcares totales, Sodio, Fibra, Porción, Por 100 g, Por 100 ml, 1 porción.",
                ocrText ? `Raw ML Kit OCR text:\n${ocrText}` : "",
              ].join("\n\n"),
            },
            {
              type: "input_image",
              image_url: `data:${mimeType};base64,${imageBase64}`,
            },
          ],
        },
      ],
      text: {
        format: {
          type: "json_schema",
          name: "nutrition_label_extraction",
          strict: true,
          schema,
        },
      },
    }),
  });

  const data = await response.json();
  if (!response.ok) {
    return json({ error: "OpenAI request failed.", details: data }, 502);
  }

  const outputText = data.output_text ?? extractOutputText(data);
  if (!outputText) {
    return json({ error: "OpenAI returned no structured output.", details: data }, 502);
  }

  try {
    return json({ result: JSON.parse(outputText) });
  } catch {
    return json({ error: "OpenAI returned invalid JSON.", raw: outputText }, 502);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : null;
}

function extractOutputText(data: Record<string, unknown>): string | null {
  const output = Array.isArray(data.output) ? data.output : [];
  for (const item of output) {
    if (!item || typeof item !== "object") continue;
    const content = Array.isArray((item as { content?: unknown }).content)
      ? (item as { content: unknown[] }).content
      : [];
    for (const contentItem of content) {
      if (!contentItem || typeof contentItem !== "object") continue;
      const text = (contentItem as { text?: unknown }).text;
      if (typeof text === "string" && text.trim().length > 0) {
        return text;
      }
    }
  }
  return null;
}
