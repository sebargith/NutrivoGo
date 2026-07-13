# Historial y gasto

NutrivoGo guarda cada consumo en `log_items`. El campo `consumed_on` es una
fecha calendario (`YYYY-MM-DD`), independiente de `created_at`. Por eso un
alimento agregado para un dia pasado se mantiene en ese dia en Android,
Windows y Supabase, sin desplazamientos por zona horaria.

## Datos historicos

El Historial deriva los totales diarios, semanales y mensuales directamente de
los registros locales sincronizados. No hay una tabla adicional de resumen.
Los macros y el gasto se obtienen de los snapshots del log, asi que editar el
producto actual no modifica consumos anteriores.

Los promedios de macros usan los dias con registros. El gasto registrado solo
suma alimentos que tienen un snapshot de precio; los alimentos sin precio se
informan por separado y nunca se cuentan como `$0`.

## Migracion remota

Aplica `supabase/migrations/008_add_log_consumed_on.sql` antes de usar la
sincronizacion de historial. La migracion rellena filas existentes usando
`created_at`, agrega el indice `(user_id, consumed_on)` y conserva todos los
registros actuales.
