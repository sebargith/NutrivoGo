alter table public.log_items
  drop constraint if exists log_items_meal_type_check;

alter table public.log_items
  add constraint log_items_meal_type_check
  check (meal_type in ('breakfast', 'lunch', 'afternoon', 'dinner', 'snack'));
