# Unidades físicas y porciones

NutrivoGo trata una porción y una unidad física como medidas distintas.

## Modelo

Los campos de unidades son opcionales:

- `Tamaño de la porción`: cantidad normalizada en g o ml.
- `Unidades por porción`: cantidad de piezas que forman una porción.
- `Porciones por envase`: cantidad de porciones del envase.
- `Cantidad total del producto/envase`: cantidad base manual o calculada.

Para un producto con 100 g por porción, 6 unidades por porción y 4,5
porciones por envase:

- `1 unidad = 100 / 6 = 16,67 g` aproximadamente.
- `4,5 porciones = 450 g`.
- `4,5 x 6 = 27 unidades`.

La cantidad total se estima automáticamente cuando existen tamaño de porción y
porciones por envase. El usuario puede editarla y recalcularla manualmente.
Una cantidad editada no se sobrescribe con cambios posteriores hasta usar
`Recalcular`.

## Registro de consumo

El selector ofrece únicamente las medidas compatibles con el producto:

- `g` para productos de base gramos.
- `ml` para productos de base mililitros.
- `porción(es)` cuando existe tamaño de porción.
- `unidad(es)` cuando existen tamaño de porción y unidades por porción válidas.

Antes de calcular, NutrivoGo convierte todo a la unidad base:

```text
gramos o ml = cantidad ingresada
porciones   = cantidad ingresada x tamaño de porción
unidades    = cantidad ingresada x (tamaño de porción / unidades por porción)
```

Los macros y el costo se guardan como snapshots en el registro. También se
guarda la medida ingresada y la cantidad base, por lo que una edición posterior
del producto no cambia el historial.

## Costos

Cuando hay precio y cantidad de envase, el costo por unidad base se calcula
como `precio / cantidad de envase`. Si además hay porciones o unidades, se
muestran estimaciones de costo por porción y por unidad. Si faltan datos, el
producto se puede guardar y el costo queda desconocido.

## Importaciones

Barcode/Open Food Facts y Gemini usan únicamente datos confiables de porción,
unidades o cantidad de envase. ML Kit OCR busca expresiones como `Porción: 6
unidades` y `Porciones por envase: 4,5`. La extracción se mantiene editable y
nunca guarda un producto sin confirmación.

## Compatibilidad y migración

Los campos son nullable. Los productos existentes continúan funcionando como
antes con g/ml y porciones. La base local aumenta a la versión 6 mediante una
migración no destructiva. Supabase usa la migración
`007_add_product_physical_units.sql`, que agrega columnas opcionales y conserva
RLS, grants y datos existentes.
