create table if not exists public.products (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  brand text,
  serving_size double precision,
  serving_unit text,
  base_unit text not null check (base_unit in ('g', 'ml')),
  calories_per_100 double precision not null check (calories_per_100 >= 0),
  protein_per_100 double precision not null check (protein_per_100 >= 0),
  carbs_per_100 double precision not null check (carbs_per_100 >= 0),
  fat_per_100 double precision not null check (fat_per_100 >= 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create index if not exists products_user_updated_idx
  on public.products (user_id, updated_at);

alter table public.products enable row level security;

create policy "Users can read their products"
  on public.products for select
  to authenticated
  using (user_id = auth.uid());

create policy "Users can insert their products"
  on public.products for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can update their products"
  on public.products for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can delete their products"
  on public.products for delete
  to authenticated
  using (user_id = auth.uid());

create table if not exists public.log_items (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null,
  meal_type text not null check (
    meal_type in ('breakfast', 'lunch', 'dinner', 'snack')
  ),
  quantity double precision not null check (quantity > 0),
  unit text not null,
  calories double precision not null check (calories >= 0),
  protein double precision not null check (protein >= 0),
  carbs double precision not null check (carbs >= 0),
  fat double precision not null check (fat >= 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create index if not exists log_items_user_updated_idx
  on public.log_items (user_id, updated_at);

create index if not exists log_items_user_created_idx
  on public.log_items (user_id, created_at);

alter table public.log_items enable row level security;

create policy "Users can read their log items"
  on public.log_items for select
  to authenticated
  using (user_id = auth.uid());

create policy "Users can insert their log items"
  on public.log_items for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can update their log items"
  on public.log_items for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can delete their log items"
  on public.log_items for delete
  to authenticated
  using (user_id = auth.uid());
