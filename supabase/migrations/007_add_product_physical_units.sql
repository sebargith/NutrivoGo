alter table public.products
  add column if not exists units_per_serving double precision check (
    units_per_serving is null or units_per_serving > 0
  ),
  add column if not exists servings_per_package double precision check (
    servings_per_package is null or servings_per_package > 0
  );

alter table public.log_items
  add column if not exists base_quantity_snapshot double precision check (
    base_quantity_snapshot is null or base_quantity_snapshot > 0
  ),
  add column if not exists serving_size_snapshot double precision check (
    serving_size_snapshot is null or serving_size_snapshot > 0
  ),
  add column if not exists units_per_serving_snapshot double precision check (
    units_per_serving_snapshot is null or units_per_serving_snapshot > 0
  ),
  add column if not exists base_quantity_per_unit_snapshot double precision check (
    base_quantity_per_unit_snapshot is null or base_quantity_per_unit_snapshot > 0
  );

grant usage on schema public to authenticated;

grant select, insert, update, delete
on table public.products, public.log_items
to authenticated;

grant usage, select
on all sequences in schema public
to authenticated;
