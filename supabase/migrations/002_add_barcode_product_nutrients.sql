alter table public.products
  add column if not exists barcode text,
  add column if not exists source text,
  add column if not exists sugar_per_100 double precision check (
    sugar_per_100 is null or sugar_per_100 >= 0
  ),
  add column if not exists saturated_fat_per_100 double precision check (
    saturated_fat_per_100 is null or saturated_fat_per_100 >= 0
  ),
  add column if not exists sodium_per_100 double precision check (
    sodium_per_100 is null or sodium_per_100 >= 0
  ),
  add column if not exists fiber_per_100 double precision check (
    fiber_per_100 is null or fiber_per_100 >= 0
  );

create index if not exists products_user_barcode_idx
  on public.products (user_id, barcode)
  where barcode is not null;
