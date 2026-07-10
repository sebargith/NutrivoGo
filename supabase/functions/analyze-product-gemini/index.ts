const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const defaultModel = "gemini-2.5-flash-lite";
const validModes = new Set(["generic_food", "nutrition_label_image"]);
const validBasis = new Set(["per_100g", "per_100ml", "per_serving", "unknown"]);
const validConfidence = new Set(["high", "medium", "low"]);

const responseSchema = {
  type: "object",
  properties: {
    status: { type: "string", enum: ["ok", "not_found", "uncertain", "error"] },
    source_mode: {
      type: "string",
      enum: ["generic_food", "nutrition_label_image"],
    },
    product: {
      type: "object",
      properties: {
        name: { type: "string" },
        brand: { type: "string" },
        barcode: { type: "string" },
        serving_size: { type: "number" },
        serving_unit: { type: "string" },
        units_per_serving: { type: "number" },
        servings_per_package: { type: "number" },
        base_unit: { type: "string", enum: ["g", "ml"] },
        basis: {
          type: "string",
          enum: ["per_100g", "per_100ml", "per_serving", "unknown"],
        },
        calories_per_100: { type: "number" },
        protein_per_100: { type: "number" },
        carbs_per_100: { type: "number" },
        fat_per_100: { type: "number" },
        saturated_fat_per_100: { type: "number" },
        sugar_per_100: { type: "number" },
        sodium_per_100: { type: "number" },
        fiber_per_100: { type: "number" },
        calories_kcal: { type: "number" },
        protein_g: { type: "number" },
        carbs_g: { type: "number" },
        fat_g: { type: "number" },
        sugar_g: { type: "number" },
        saturated_fat_g: { type: "number" },
        sodium_mg: { type: "number" },
        fiber_g: { type: "number" },
        per_serving: {
          type: "object",
          properties: {
            calories_kcal: { type: "number" },
            protein_g: { type: "number" },
            carbs_g: { type: "number" },
            fat_g: { type: "number" },
            sugar_g: { type: "number" },
            saturated_fat_g: { type: "number" },
            sodium_mg: { type: "number" },
            fiber_g: { type: "number" },
          },
        },
      },
    },
    confidence: { type: "string", enum: ["high", "medium", "low"] },
    warnings: { type: "array", items: { type: "string" } },
    assumptions: { type: "array", items: { type: "string" } },
    explanation: { type: "string" },
  },
  required: ["status", "source_mode", "confidence", "warnings", "assumptions", "explanation"],
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authError = await verifySupabaseUser(req);
  if (authError != null) {
    return json({ error: authError }, 401);
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) {
    return json({ error: "Falta configurar Gemini" }, 500);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch (_error) {
    return json({ error: "Request JSON inválido" }, 400);
  }

  const mode = stringValue(body.mode);
  if (!mode || !validModes.has(mode)) {
    return json({ error: "Modo Gemini inválido" }, 400);
  }

  const validationError = validateBody(body, mode);
  if (validationError != null) {
    return json({ error: validationError }, 400);
  }

  const model = Deno.env.get("GEMINI_MODEL") || defaultModel;
  const modelPath = model.startsWith("models/") ? model : `models/${model}`;
  const prompt = buildPrompt(body, mode);
  const parts: Record<string, unknown>[] = [{ text: prompt }];

  if (mode === "nutrition_label_image") {
    parts.push({
      inlineData: {
        mimeType: stringValue(body.image_mime_type) || "image/jpeg",
        data: stringValue(body.image_base64),
      },
    });
  }

  const geminiResponse = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/${modelPath}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ text: systemInstruction }],
        },
        contents: [
          {
            role: "user",
            parts,
          },
        ],
        generationConfig: {
          temperature: 0.1,
          responseMimeType: "application/json",
          responseSchema: responseSchema,
        },
      }),
    },
  );

  if (!geminiResponse.ok) {
    const message = await safeResponseText(geminiResponse);
    if (geminiResponse.status === 429) {
      return json({ error: "Límite de Gemini alcanzado" }, 429);
    }
    return json(
      { error: `No se pudo analizar con Gemini: ${message}` },
      geminiResponse.status,
    );
  }

  const geminiJson = await geminiResponse.json();
  const text = extractText(geminiJson);
  if (!text) {
    return json({ error: "Gemini no devolvió JSON analizable" }, 502);
  }

  try {
    const parsed = JSON.parse(text) as Record<string, unknown>;
    const normalized = normalizeAnalysis(parsed, mode, body);
    if (body.debug === true) {
      normalized.debug = {
        mode,
        query: mode === "generic_food" ? stringValue(body.query) : undefined,
        gemini_raw_json: parsed,
        normalized_response: { ...normalized },
      };
    }
    return json(normalized, 200);
  } catch (_error) {
    return json({ error: "Gemini devolvió JSON inválido" }, 502);
  }
});

const systemInstruction = `
You extract food product nutrition data for a Chilean Spanish nutrition tracker.
Return only strict JSON matching the schema.
Never include markdown.
Never invent barcode, brand, or package facts that are not visible or implied by the user query.
Use kcal for calories, grams for macros, and mg for sodium.
Normalize decimal commas to numbers.
For Chilean labels, recognize Información nutricional, Energía, Calorías, kcal, Proteínas, Grasa total, Grasas saturadas, H. de C. Disp., Carbohidratos, Hidratos de carbono, Azúcares totales, Sodio, Fibra, Porción, Por 100 g, Por 100 ml, and 1 porción.
Prefer per 100 g or per 100 ml values when visible.
If only per-serving values are visible, set basis to per_serving and add a warning. Do not silently normalize to per 100.
If values are approximate or inferred, add an assumption and lower confidence.
`;

function buildPrompt(body: Record<string, unknown>, mode: string): string {
  if (mode === "generic_food") {
    return `
Mode: generic_food.
Locale: ${stringValue(body.locale) || "Chile"}.
User query: ${stringValue(body.query)}.
Return approximate common nutrition for the edible food normalized per 100 g or per 100 ml.
For common solid foods, use per 100 g.
Calories must be kcal per 100 g/ml.
Protein, carbs, fat, sugar, saturated fat, and fiber must be grams per 100 g/ml.
Sodium must be mg per 100 g/ml.
Do not return only per-serving values.
If giving a serving size, serving size is separate from per-100 nutrition.
For common foods like plátano, huevo, arroz cocido, pollo cocido, manzana, pan, avena, and leche, include calories_per_100, protein_per_100, carbs_per_100, and fat_per_100 if possible.
Only return units_per_serving when a natural countable unit clearly applies, such as 1 egg or 1 banana. Do not invent physical units for rice, oil, flour, milk, or sugar. Keep servings_per_package null for generic foods unless the user explicitly describes a package. If a natural unit weight is estimated, add a Spanish assumption warning.
If a value is unknown, use null instead of omitting the key.
Do not put nutrients only in explanation text.
Set source_mode to generic_food.
Set status to not_found when this is not a food.
Use product.basis per_100g or per_100ml.
Return explanation, warnings, and assumptions in Spanish.
Preferred product fields: calories_per_100, protein_per_100, carbs_per_100, fat_per_100, saturated_fat_per_100, sugar_per_100, sodium_per_100, fiber_per_100.
`;
  }

  return `
Mode: nutrition_label_image.
Set source_mode to nutrition_label_image.
Analyze the attached nutrition label image.
Optional OCR text from the device:
${stringValue(body.raw_ocr_text) || "(none)"}
Optional user hint:
${stringValue(body.hint) || "(none)"}
Extract only visible nutrition label data.
If both kJ and kcal are visible, use kcal.
Return per-serving values in product.per_serving when visible, but product calories/protein/carbs/fat fields must follow product.basis.
Distinguish physical units per serving (for example, 6 unidades) from serving size in grams/ml and servings per package (for example, 4,5 porciones por envase). Never convert a unit count into grams. Return units_per_serving and servings_per_package only when the label supports them.
Return explanation, warnings, and assumptions in Spanish.
`;
}

async function verifySupabaseUser(req: Request): Promise<string | null> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return "Inicia sesión para usar Gemini.";
  }
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !anonKey) {
    return "Falta configurar Supabase para Gemini.";
  }
  const response = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: {
      Authorization: authHeader,
      apikey: anonKey,
    },
  });
  if (!response.ok) {
    return "Inicia sesión para usar Gemini.";
  }
  return null;
}

function validateBody(body: Record<string, unknown>, mode: string): string | null {
  if (mode === "generic_food") {
    const query = stringValue(body.query);
    if (!query || query.trim().length < 2) {
      return "Describe el alimento";
    }
    return null;
  }

  const imageBase64 = stringValue(body.image_base64);
  if (!imageBase64) {
    return "Falta la imagen para analizar";
  }
  if (imageBase64.length > 7_000_000) {
    return "La imagen es demasiado grande para Gemini";
  }
  return null;
}

function normalizeAnalysis(
  value: Record<string, unknown>,
  mode: string,
  requestBody: Record<string, unknown>,
): Record<string, unknown> {
  const product = objectValue(value.product);
  const normalizedProduct = product == null
    ? null
    : normalizeProduct(product, mode, requestBody);
  const status = stringValue(value.status);
  const confidence = stringValue(value.confidence);
  const warnings = stringArray(value.warnings);
  if (mode === "generic_food" && product != null && usedGenericBasisFallback(product)) {
    warnings.push("Se asumieron valores por 100 g/ml para este alimento genérico. Revisa antes de guardar.");
  }
  return {
    status: ["ok", "not_found", "uncertain", "error"].includes(status || "")
      ? status
      : normalizedProduct == null
      ? "uncertain"
      : "ok",
    source_mode: mode,
    product: normalizedProduct,
    confidence: validConfidence.has(confidence || "") ? confidence : "low",
    warnings: uniqueStrings(warnings),
    assumptions: stringArray(value.assumptions),
    explanation: stringValue(value.explanation) || "",
  };
}

function normalizeProduct(
  value: Record<string, unknown>,
  mode: string,
  requestBody: Record<string, unknown>,
): Record<string, unknown> {
  const baseUnitInput = stringValue(value.base_unit);
  const basis = normalizeBasis(value.basis, mode, baseUnitInput);
  const baseUnit = baseUnitInput === "ml" || basis === "per_100ml" ? "ml" : "g";
  const fallbackName = mode === "generic_food"
    ? stringValue(requestBody.query) || "Producto Gemini"
    : "Producto Gemini";

  const product: Record<string, unknown> = {
    name: stringValue(value.name) || fallbackName,
    base_unit: baseUnit,
    basis,
  };
  assignString(product, "brand", value.brand);
  assignString(product, "barcode", value.barcode);
  assignNumber(product, "serving_size", value.serving_size);
  assignString(product, "serving_unit", value.serving_unit);
  assignNumber(product, "units_per_serving", value.units_per_serving);
  assignNumber(product, "servings_per_package", value.servings_per_package);
  const valuesArePer100 = basis === "per_100g" || basis === "per_100ml" ||
    mode === "generic_food";
  assignNumber(
    product,
    "calories_per_100",
    nutritionNumber(value, {
      explicitKeys: [
        "calories_per_100",
        "calories_kcal_per_100",
        "energy_kcal_per_100",
        "kcal_per_100",
      ],
      basisKeys: ["calories_kcal", "calories", "energy_kcal", "kcal"],
      valuesArePer100,
    }),
  );
  assignNumber(
    product,
    "protein_per_100",
    nutritionNumber(value, {
      explicitKeys: ["protein_per_100", "protein_g_per_100"],
      basisKeys: ["protein_g", "protein", "proteins", "proteinas", "proteínas"],
      valuesArePer100,
    }),
  );
  assignNumber(
    product,
    "carbs_per_100",
    nutritionNumber(value, {
      explicitKeys: [
        "carbs_per_100",
        "carbohydrate_per_100",
        "carbohydrates_per_100",
        "carbs_g_per_100",
      ],
      basisKeys: [
        "carbs_g",
        "carbohydrates_g",
        "carbs",
        "carbohydrates",
        "carbohidratos",
        "hidratos_de_carbono",
      ],
      valuesArePer100,
    }),
  );
  assignNumber(
    product,
    "fat_per_100",
    nutritionNumber(value, {
      explicitKeys: ["fat_per_100", "fat_g_per_100", "total_fat_per_100"],
      basisKeys: ["fat_g", "fat", "total_fat", "grasa_total", "grasas"],
      valuesArePer100,
    }),
  );
  assignNumber(
    product,
    "saturated_fat_per_100",
    nutritionNumber(value, {
      explicitKeys: [
        "saturated_fat_per_100",
        "saturated_fat_g_per_100",
      ],
      basisKeys: [
        "saturated_fat_g",
        "saturated_fat",
        "grasa_saturada",
        "grasas_saturadas",
      ],
      valuesArePer100,
    }),
  );
  assignNumber(
    product,
    "sugar_per_100",
    nutritionNumber(value, {
      explicitKeys: ["sugar_per_100", "sugars_per_100", "sugar_g_per_100"],
      basisKeys: ["sugar_g", "sugars_g", "sugar", "sugars", "azucares", "azúcares"],
      valuesArePer100,
    }),
  );
  assignNumber(
    product,
    "sodium_per_100",
    nutritionNumber(value, {
      explicitKeys: ["sodium_per_100", "sodium_mg_per_100"],
      basisKeys: ["sodium_mg", "sodium", "sodio"],
      valuesArePer100,
    }),
  );
  assignNumber(
    product,
    "fiber_per_100",
    nutritionNumber(value, {
      explicitKeys: ["fiber_per_100", "fibre_per_100", "fiber_g_per_100"],
      basisKeys: ["fiber_g", "fibre_g", "fiber", "fibre", "fibra"],
      valuesArePer100,
    }),
  );

  const perServing = objectValue(value.per_serving);
  if (perServing != null) {
    product.per_serving = normalizePerServing(perServing);
  }
  return product;
}

function normalizeBasis(
  value: unknown,
  mode: string,
  baseUnitInput: string | null,
): string {
  const normalized = stringValue(value)
    ?.trim()
    .toLowerCase()
    .replace(/[\s-]+/g, "_");
  const alias = normalized === "per100g" || normalized === "per_100_g" ||
      normalized === "100g" || normalized === "100_g"
    ? "per_100g"
    : normalized === "per100ml" || normalized === "per_100_ml" ||
        normalized === "100ml" || normalized === "100_ml"
    ? "per_100ml"
    : normalized === "serving" || normalized === "por_porcion"
    ? "per_serving"
    : normalized;
  if (alias != null && validBasis.has(alias)) {
    return alias;
  }
  if (mode === "generic_food") {
    return baseUnitInput === "ml" ? "per_100ml" : "per_100g";
  }
  return "unknown";
}

function usedGenericBasisFallback(product: Record<string, unknown>): boolean {
  const basis = stringValue(product.basis);
  if (basis == null || basis.trim() === "") {
    return true;
  }
  return normalizeBasis(basis, "nutrition_label_image", stringValue(product.base_unit)) === "unknown";
}

function normalizePerServing(value: Record<string, unknown>): Record<string, number> {
  const result: Record<string, number> = {};
  assignNumber(result, "calories_kcal", value.calories_kcal);
  assignNumber(result, "protein_g", value.protein_g);
  assignNumber(result, "carbs_g", value.carbs_g);
  assignNumber(result, "fat_g", value.fat_g);
  assignNumber(result, "sugar_g", value.sugar_g);
  assignNumber(result, "saturated_fat_g", value.saturated_fat_g);
  assignNumber(result, "sodium_mg", value.sodium_mg);
  assignNumber(result, "fiber_g", value.fiber_g);
  return result;
}

function extractText(value: Record<string, unknown>): string | null {
  const candidates = Array.isArray(value.candidates) ? value.candidates : [];
  const first = objectValue(candidates[0]);
  const content = objectValue(first?.content);
  const parts = Array.isArray(content?.parts) ? content.parts : [];
  const text = parts
    .map((part) => stringValue(objectValue(part)?.text))
    .filter((partText) => partText != null && partText.trim().length > 0)
    .join("\n")
    .trim();
  return text.length === 0 ? null : text;
}

async function safeResponseText(response: Response): Promise<string> {
  try {
    const text = await response.text();
    return text.slice(0, 500);
  } catch (_error) {
    return response.statusText;
  }
}

function json(value: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(value), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function nutritionNumber(
  source: Record<string, unknown>,
  options: {
    explicitKeys: string[];
    basisKeys: string[];
    valuesArePer100: boolean;
  },
): number | null {
  const sources = nutritionSources(source);
  const explicit = numberFromSources(sources, options.explicitKeys);
  if (explicit != null) {
    return explicit;
  }
  if (!options.valuesArePer100) {
    return null;
  }
  return numberFromSources(sources, options.basisKeys);
}

function nutritionSources(
  source: Record<string, unknown>,
): Record<string, unknown>[] {
  const nestedKeys = [
    "nutrition",
    "nutrients",
    "nutrients_per_100g",
    "nutrients_per_100ml",
    "per_100g",
    "per_100ml",
    "per100",
    "per100g",
    "per100ml",
  ];
  const sources = [source];
  for (const key of nestedKeys) {
    const nested = objectValue(source[key]);
    if (nested != null) {
      sources.push(nested);
    }
  }
  return sources;
}

function numberFromSources(
  sources: Record<string, unknown>[],
  keys: string[],
): number | null {
  const normalizedKeys = new Set(keys.map(normalizeKey));
  for (const source of sources) {
    for (const [key, value] of Object.entries(source)) {
      if (!normalizedKeys.has(normalizeKey(key))) {
        continue;
      }
      const parsed = numberValue(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

function normalizeKey(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[\s.-]+/g, "_");
}

function assignString(
  target: Record<string, unknown>,
  key: string,
  value: unknown,
) {
  const parsed = stringValue(value);
  if (parsed != null && parsed.trim() !== "") {
    target[key] = parsed.trim();
  }
}

function assignNumber(
  target: Record<string, unknown>,
  key: string,
  value: unknown,
) {
  const parsed = numberValue(value);
  if (parsed != null && Number.isFinite(parsed) && parsed >= 0) {
    target[key] = parsed;
  }
}

function objectValue(value: unknown): Record<string, unknown> | null {
  if (value == null || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" ? value : null;
}

function numberValue(value: unknown): number | null {
  if (typeof value === "number") {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number(value.replace(",", "."));
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function stringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((item) => String(item).trim())
    .filter((item) => item.length > 0);
}

function uniqueStrings(values: string[]): string[] {
  return [...new Set(values)];
}
