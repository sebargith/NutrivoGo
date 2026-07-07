alter table public.products
  add column if not exists package_price_clp double precision check (
    package_price_clp is null or package_price_clp >= 0
  ),
  add column if not exists package_quantity double precision check (
    package_quantity is null or package_quantity > 0
  ),
  add column if not exists package_quantity_unit text check (
    package_quantity_unit is null or package_quantity_unit in ('g', 'ml')
  );

alter table public.log_items
  add column if not exists cost_snapshot_clp double precision check (
    cost_snapshot_clp is null or cost_snapshot_clp >= 0
  ),
  add column if not exists cost_per_100_snapshot_clp double precision check (
    cost_per_100_snapshot_clp is null or cost_per_100_snapshot_clp >= 0
  ),
  add column if not exists cost_per_serving_snapshot_clp double precision check (
    cost_per_serving_snapshot_clp is null or cost_per_serving_snapshot_clp >= 0
  ),
  add column if not exists package_price_snapshot_clp double precision check (
    package_price_snapshot_clp is null or package_price_snapshot_clp >= 0
  ),
  add column if not exists package_quantity_snapshot double precision check (
    package_quantity_snapshot is null or package_quantity_snapshot > 0
  );

grant usage on schema public to authenticated;

grant select, insert, update, delete
on table public.products, public.log_items
to authenticated;

grant usage, select
on all sequences in schema public
to authenticated;
