-- Calendar date of consumption. This deliberately uses PostgreSQL's `date`
-- type so it is not shifted by a device or server time zone.
alter table public.log_items
add column if not exists consumed_on date;

update public.log_items
set consumed_on = (created_at at time zone 'UTC')::date
where consumed_on is null;

alter table public.log_items
alter column consumed_on set not null;

create index if not exists log_items_user_consumed_on_idx
on public.log_items (user_id, consumed_on desc);
