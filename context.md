# MacroTracker — Codex Project Context

## Project Goal

Build a fast, simple, cross-platform app to register and track daily food macros.

The app should allow the user to:

- Track daily calories and macros.
- Add foods/products to meals.
- Reuse saved products.
- Scan a product's nutrition label from a photo.
- Store scanned products for future use.
- Select a saved product and enter the quantity eaten.
- Automatically add the calculated macros to the current day.
- Sync data between mobile and desktop.
- Keep the app fast, easy to launch, and easy to manage.

The app should be built incrementally with Codex. The first goal is a clean working MVP, not a giant unfinished app.

---

## Recommended Stack

### App Framework

Use **Flutter**.

Reason:

- One codebase for Android, iOS, Windows, macOS, Linux, and web.
- Good UI performance.
- Suitable for a fast mobile + desktop app.
- Codex can work well with Flutter project structure.

### Local Database

Use **Drift + SQLite**.

Reason:

- Local-first app.
- Fast startup.
- Works offline.
- Good for storing products, daily logs, and log items.
- Later sync can push/pull local data with the cloud.

### Backend / Cloud Sync

Use **Supabase**.

Reason:

- Postgres database.
- Authentication.
- Row Level Security.
- Realtime support if needed later.
- Simple enough for solo development.
- Avoids building a full custom backend too early.

### OCR

Use **Google ML Kit Text Recognition** for nutrition label OCR.

Reason:

- Works well on mobile.
- Good enough for reading nutrition facts from package photos.
- Returns structured text blocks/lines/words.
- OCR should never auto-save without user confirmation.

### Barcode/Product Lookup

Use **Open Food Facts** as an optional product lookup source.

Reason:

- Many products already exist by barcode.
- Faster than OCR when available.
- Can provide initial product data, which the user can confirm/edit.

---

## Core Principle

Do not make OCR the core of the app.

The core is:

```text
products -> quantities -> meal logs -> daily macro totals -> sync
```

OCR and barcode scanning are just input methods for creating products faster.

The app should still work perfectly if the user only enters products manually.

---

## Product Input Priority

When adding a new packaged food, use this order:

```text
1. Try barcode scan
2. Search local saved products
3. Search Open Food Facts
4. If product is not found, scan nutrition label with OCR
5. Show confirmation/edit screen
6. Save product
```

Never trust OCR automatically.

The user must always confirm the detected nutrition values before saving.

---

## Main User Flow

### Example Flow

The user wants to log lunch.

```text
Open app
-> Today screen
-> Add Food
-> Search/select saved product
-> Enter quantity eaten
-> Choose meal: Lunch
-> Save
-> App updates today's calories, protein, carbs, and fat
```

### Example Product Scan Flow

```text
Add Product
-> Scan barcode
-> Product not found
-> Take photo of nutrition label
-> OCR reads label
-> Parser extracts calories/protein/carbs/fat/etc.
-> User confirms or edits values
-> Save product
-> Product is now reusable
```

---

## Main Screens

### 1. Today Dashboard

This is the most important screen.

It should show:

- Current date.
- Calories eaten / target.
- Protein eaten / target.
- Carbs eaten / target.
- Fat eaten / target.
- Meal sections:
  - Breakfast
  - Lunch
  - Dinner
  - Snacks
- List of logged foods for each meal.
- Fast button: **Add Food**.
- Optional quick actions:
  - Add recent food.
  - Copy yesterday.
  - Add quick macros.

### 2. Add Food

Fast entry screen.

Options:

- Search product.
- Recent products.
- Favorites.
- Scan barcode.
- Scan nutrition label.
- Create manual product.
- Quick add calories/macros.

### 3. Product Search

Search local products first.

Should support:

- Product name.
- Brand.
- Barcode.
- Recent/favorite status.

### 4. Create/Edit Product

Allows manual creation or correction of products.

Fields:

- Product name.
- Brand.
- Barcode.
- Serving size.
- Serving unit.
- Base unit.
- Calories per 100g or 100ml.
- Protein per 100g or 100ml.
- Carbs per 100g or 100ml.
- Fat per 100g or 100ml.
- Optional:
  - Fiber.
  - Sugar.
  - Sodium.
  - Saturated fat.

### 5. Quantity / Log Item Screen

After selecting a product, the user enters how much they are eating.

Must support:

- Grams.
- Milliliters.
- Serving.
- Unit/piece.
- Custom quantity.
- Meal type.

Example:

```text
Product: Greek Yogurt
Quantity: 250 g
Meal: Lunch
```

The app calculates and stores the macro snapshot.

---

## Nutrition Data Rule

Store product nutrition normalized per 100g or 100ml whenever possible.

Example:

```text
Product: Greek Yogurt
Base unit: g
Calories per 100g: 59
Protein per 100g: 10
Carbs per 100g: 3.6
Fat per 100g: 0.4
Serving size: 170g
```

When the user logs 250g:

```text
calories = calories_per_100 * 250 / 100
protein = protein_per_100 * 250 / 100
carbs = carbs_per_100 * 250 / 100
fat = fat_per_100 * 250 / 100
```

This is the canonical calculation model.

Avoid using only "per serving" as the base because serving sizes vary and can be confusing.

---

## Important Historical Snapshot Rule

When a product is logged, store the calculated macros inside the log item.

Do not rely only on the current product values.

Reason:

If the user edits a product later, old food history should not change unexpectedly.

Example:

```text
Product: Yogurt
Logged on: 2026-06-30
Quantity: 250g
Calories snapshot: 147.5
Protein snapshot: 25
Carbs snapshot: 9
Fat snapshot: 1
```

If the product is edited later, this old logged item should keep its original values.

---

## Data Model

### products

Reusable food/product records.

```sql
products
- id
- user_id
- name
- brand
- barcode
- source              -- manual, barcode, ocr
- serving_size
- serving_unit        -- g, ml, serving, unit, slice, etc.
- base_unit           -- g or ml usually
- calories_per_100
- protein_per_100
- carbs_per_100
- fat_per_100
- fiber_per_100
- sugar_per_100
- saturated_fat_per_100
- sodium_per_100
- is_favorite
- created_at
- updated_at
- deleted_at
```

### daily_logs

One row per user per day.

```sql
daily_logs
- id
- user_id
- date
- calorie_target
- protein_target
- carbs_target
- fat_target
- created_at
- updated_at
```

### log_items

Each food entry logged in a meal.

```sql
log_items
- id
- user_id
- daily_log_id
- product_id
- meal_type           -- breakfast, lunch, dinner, snack
- quantity
- unit                -- g, ml, serving, unit
- calories
- protein
- carbs
- fat
- fiber
- sugar
- sodium
- created_at
- updated_at
- deleted_at
```

The macros in `log_items` are snapshots calculated at log time.

### ocr_scans

Optional but useful for debugging OCR.

```sql
ocr_scans
- id
- user_id
- image_path
- raw_ocr_text
- parsed_json
- confidence
- created_at
```

### recipes

Add later, not in the MVP.

```sql
recipes
- id
- user_id
- name
- created_at
- updated_at
- deleted_at
```

### recipe_items

Add later, not in the MVP.

```sql
recipe_items
- id
- recipe_id
- product_id
- quantity
- unit
```

---

## Sync Strategy

Use a local-first model.

```text
Flutter app
-> Drift/SQLite local database
-> Sync service
-> Supabase Postgres
-> Other devices pull changes
```

### Syncable Tables

The following should sync eventually:

- products
- daily_logs
- log_items
- recipes
- recipe_items

Each syncable table should include:

```text
user_id
created_at
updated_at
deleted_at
sync_status
```

### Initial Sync Strategy

Keep it simple first:

```text
1. App starts.
2. Pull remote changes from Supabase.
3. Merge into local SQLite.
4. User makes local changes.
5. Push local changes to Supabase when online.
6. Mark records as synced.
```

### Conflict Resolution

For the first version:

```text
last updated_at wins
```

Later, improve conflict handling if needed.

### Offline Behavior

The app should work offline.

When offline:

- User can still add products.
- User can still log food.
- User can still edit/delete local entries.
- Changes are marked as pending sync.

When online again:

- Pending changes are pushed to Supabase.

---

## Supabase Notes

Use Supabase Auth.

Every table should have `user_id`.

Enable Row Level Security.

General policy idea:

```sql
user_id = auth.uid()
```

The user should only be able to read/write their own data.

---

## OCR Flow

### Nutrition Label Scan Flow

```text
Take photo
-> Crop/rotate if needed
-> Run OCR
-> Get raw text
-> Parse nutrition fields
-> Show confirmation/edit form
-> Save product
```

### Fields to Detect

The parser should try to recognize:

```text
Energy
Calories
kcal
Protein
Proteínas
Carbohydrate
Carbohidratos
Sugars
Azúcares
Fat
Grasas
Saturated fat
Grasas saturadas
Fiber
Fibra
Sodium
Sodio
Salt
Serving size
Porción
Per 100g
Por 100 g
Per serving
Por porción
```

Support both English and Spanish labels.

### OCR Safety Rule

OCR values must be treated as suggestions.

The user must confirm before saving.

Good UX:

```text
Detected values:

Calories: 250 kcal / 100g
Protein: 8g / 100g
Carbs: 30g / 100g
Fat: 9g / 100g

[Edit] [Save Product]
```

---

## Barcode Flow

### Barcode Scan Flow

```text
Scan barcode
-> Search local product by barcode
-> If found, open product
-> If not found, query Open Food Facts
-> If found, show confirmation screen
-> Save locally
-> If not found, offer OCR/manual entry
```

Barcode lookup should be faster than OCR when possible.

---

## MVP Roadmap

## Phase 1 — Manual Macro Tracker

No OCR.
No barcode.
No cloud sync.

Build:

- Product CRUD.
- Search products.
- Add product to today's log.
- Quantity input.
- Daily macro totals.
- Meal sections.
- Edit/delete log items.
- Recent products.
- Clean calculation logic.

Goal:

A fully usable local macro tracker.

---

## Phase 2 — Local Database and Architecture

Add/clean:

- Drift/SQLite.
- Repository layer.
- Product service.
- Food log service.
- Macro calculation service.
- Unit conversion helper.
- Tests for calculations.

Goal:

A stable local-first base.

---

## Phase 3 — Supabase Sync

Add:

- User login.
- Supabase database schema.
- Supabase migrations.
- Row Level Security.
- Push/pull sync.
- Pending sync state.
- Same account across mobile and desktop.

Goal:

Data sync between devices.

---

## Phase 4 — Barcode Scanning

Add:

- Barcode scanner.
- Local barcode lookup.
- Open Food Facts lookup.
- Product confirmation screen.
- Save scanned product locally.

Goal:

Fast product creation by barcode.

---

## Phase 5 — Nutrition Label OCR

Add:

- Camera capture.
- Image preprocessing if useful.
- ML Kit OCR.
- Nutrition text parser.
- Confirmation/edit screen.
- Save OCR product.

Goal:

Create reusable products from package nutrition labels.

---

## Phase 6 — Speed and Quality-of-Life Features

Add:

- Favorites.
- Copy yesterday's meals.
- Meal templates.
- Quick quantity buttons:
  - 50g
  - 100g
  - 150g
  - 1 serving
- Recent foods.
- Desktop keyboard shortcuts.
- Better search.
- Product categories.
- Export data.
- Import data.

---

## Features to Avoid Early

Do not build these in the MVP:

- AI meal photo recognition.
- Social features.
- Nutrition coaching.
- Complex recipe system.
- Advanced analytics.
- Perfect sync conflict engine.
- Full web dashboard.
- Complex subscription/payment system.
- Multi-user family sharing.
- Wearable integration.

These can be added later.

---

## Suggested Flutter Project Structure

```text
macro_tracker/
  app/
    lib/
      main.dart
      app.dart

      core/
        database/
        sync/
        auth/
        utils/
        errors/

      features/
        products/
          data/
          domain/
          presentation/

        food_log/
          data/
          domain/
          presentation/

        scanner/
          barcode/
          ocr/
          parser/
          presentation/

        dashboard/
          presentation/

        settings/
          presentation/

      shared/
        widgets/
        models/
        theme/

  supabase/
    migrations/
    seed.sql
    policies.sql

  docs/
    AGENTS.md
    ARCHITECTURE.md
    DATABASE.md
    OCR_LABEL_PARSING.md
    MVP_ROADMAP.md
```

---

## Suggested Domain Models

### Product

```dart
class Product {
  final String id;
  final String userId;
  final String name;
  final String? brand;
  final String? barcode;
  final ProductSource source;

  final double? servingSize;
  final String? servingUnit;
  final String baseUnit;

  final double caloriesPer100;
  final double proteinPer100;
  final double carbsPer100;
  final double fatPer100;

  final double? fiberPer100;
  final double? sugarPer100;
  final double? saturatedFatPer100;
  final double? sodiumPer100;

  final bool isFavorite;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
```

### LogItem

```dart
class LogItem {
  final String id;
  final String userId;
  final String dailyLogId;
  final String productId;

  final MealType mealType;
  final double quantity;
  final String unit;

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  final double? fiber;
  final double? sugar;
  final double? sodium;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
```

### MealType

```dart
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}
```

### ProductSource

```dart
enum ProductSource {
  manual,
  barcode,
  ocr,
}
```

---

## Macro Calculation Logic

Create a dedicated service for this.

Example:

```dart
class MacroCalculator {
  MacroSnapshot calculateFromProduct({
    required Product product,
    required double quantity,
    required String unit,
  }) {
    // Convert quantity to base unit if needed.
    // For MVP, support g/ml and serving.
    // Calculate: per100 * quantity / 100.
  }
}
```

### MVP Unit Support

Start with:

```text
g
ml
serving
unit
```

For serving:

```text
quantity_in_base_unit = serving_count * product.serving_size
```

Example:

```text
2 servings * 170g = 340g
```

Then:

```text
macro = macro_per_100 * 340 / 100
```

---

## UI/UX Direction

The app should feel:

- Fast.
- Minimal.
- Practical.
- Clean.
- Easy to launch.
- Easy to use one-handed on mobile.
- Comfortable on desktop.

Suggested style:

- Modern dark theme.
- Clear macro cards.
- Big Add Food button.
- Compact meal sections.
- Search-first product selection.
- Recent products visible immediately.
- No excessive animations.
- No complex onboarding in MVP.

---

## Desktop-Specific UX

Desktop should support:

- Fast search.
- Keyboard shortcuts.
- Wider Today layout.
- Product table/list view.
- Quick add from recent products.
- Resizable window.
- Optional tray behavior later.

Possible keyboard shortcuts later:

```text
Ctrl+K: Search food
Ctrl+N: New product
Ctrl+L: Add log item
Ctrl+T: Go to Today
```

---

## Mobile-Specific UX

Mobile should support:

- Fast camera access.
- Bottom navigation.
- Big touch targets.
- Quick quantity input.
- Recent/favorite foods.
- Barcode scan from Add Food.
- OCR scan from Add Product.

---

## Testing Priorities

Tests should focus first on:

- Macro calculations.
- Unit conversion.
- Quantity by serving.
- Daily total aggregation.
- Product edit not changing old log snapshots.
- Soft delete behavior.
- Sync conflict handling later.

Example tests:

```text
Given product has 100 kcal per 100g
When user logs 250g
Then log item calories = 250 kcal
```

```text
Given product has 10g protein per 100g and serving size 170g
When user logs 2 servings
Then protein = 34g
```

```text
Given a logged item has 200 kcal snapshot
When product calories are edited later
Then old logged item still has 200 kcal
```

---

## First Codex Task

Use this as the first direct Codex prompt:

```text
Build a Flutter app called MacroTracker.

Goal:
Create a fast local-first macro tracking app for daily food logging.

Initial scope:
- No OCR yet.
- No barcode yet.
- No cloud sync yet.
- Implement product CRUD.
- Implement daily food logging.
- Implement macro calculations.
- Implement Today dashboard.
- Use clean architecture by feature.
- Use Drift/SQLite for local persistence.
- Store nutrition values normalized per 100g or 100ml.
- When a product is logged, store a snapshot of calculated macros in the log item so old history does not change if the product is edited later.

Main entities:
Product, DailyLog, LogItem.

Screens:
1. Today dashboard
2. Add Food
3. Product Search
4. Create/Edit Product
5. Log Item Quantity Screen

UX priorities:
Fast add flow, recent products, simple quantity input, minimal clicks.

Do not implement OCR, barcode, Supabase, recipes, or advanced analytics yet.
Focus on a working MVP with clean code and tests for macro calculations.
```

---

## Later Codex Tasks

### Task: Add Barcode Support

```text
Add barcode scanning to MacroTracker.

Requirements:
- Add scanner feature module.
- Allow scanning product barcode from Add Food.
- First search local products by barcode.
- If not found, query Open Food Facts.
- Show a confirmation/edit screen before saving imported product.
- Save imported product locally.
- Do not auto-log the product unless the user confirms quantity.
```

### Task: Add OCR Nutrition Label Scan

```text
Add nutrition label OCR to MacroTracker.

Requirements:
- Add camera capture flow.
- Run OCR using ML Kit Text Recognition.
- Store raw OCR text temporarily.
- Parse calories, protein, carbs, fat, fiber, sugar, sodium, serving size, and per-100g/per-serving values.
- Support English and Spanish labels.
- Show detected values in an editable confirmation screen.
- Save confirmed result as a Product.
- Never save OCR results without user confirmation.
```

### Task: Add Supabase Sync

```text
Add Supabase sync to MacroTracker.

Requirements:
- Add Supabase Auth.
- Add remote tables for products, daily_logs, and log_items.
- Enable Row Level Security.
- Each table must use user_id.
- Implement push/pull sync between local Drift database and Supabase.
- App must remain usable offline.
- Use updated_at for simple first-version conflict resolution.
- Use soft deletes with deleted_at.
```

---

## Final Architecture Summary

Recommended approach:

```text
Flutter
+ Drift/SQLite local-first storage
+ Supabase auth and sync
+ barcode lookup before OCR
+ ML Kit OCR for nutrition labels
+ manual confirmation always
```

Build order:

```text
1. Manual local macro tracker
2. Local database and clean architecture
3. Supabase sync
4. Barcode scanning
5. OCR nutrition label scanning
6. Speed features and quality-of-life improvements
```

Main rule:

```text
Normalize products to per 100g/ml.
Log consumed quantity.
Store macro snapshot in the log item.
Keep OCR/barcode as product creation shortcuts.
```

This keeps the app realistic, useful, and buildable with Codex.
