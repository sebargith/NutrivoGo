create table if not exists public.ocr_scan_reports (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  raw_ocr_text text not null,
  parsed_json jsonb not null,
  corrected_json jsonb,
  detected_basis text,
  parser_warnings jsonb,
  parser_confidence double precision,
  was_parser_correct boolean,
  user_feedback text,
  product_id text,
  product_name text,
  barcode text,
  source text not null default 'ocr',
  platform text not null,
  app_version text,
  image_saved boolean not null default false,
  image_storage_path text,
  image_crop_storage_path text,
  image_path_local text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create index if not exists ocr_scan_reports_user_idx
  on public.ocr_scan_reports (user_id);

create index if not exists ocr_scan_reports_user_created_idx
  on public.ocr_scan_reports (user_id, created_at desc);

create index if not exists ocr_scan_reports_user_correct_idx
  on public.ocr_scan_reports (user_id, was_parser_correct);

create index if not exists ocr_scan_reports_user_product_idx
  on public.ocr_scan_reports (user_id, product_id);

alter table public.ocr_scan_reports enable row level security;

create policy "Users can read their OCR scan reports"
  on public.ocr_scan_reports for select
  using (auth.uid() = user_id);

create policy "Users can insert their OCR scan reports"
  on public.ocr_scan_reports for insert
  with check (auth.uid() = user_id);

create policy "Users can update their OCR scan reports"
  on public.ocr_scan_reports for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their OCR scan reports"
  on public.ocr_scan_reports for delete
  using (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('ocr-debug-images', 'ocr-debug-images', false)
on conflict (id) do update
set public = false;

create policy "Users can read their OCR debug images"
  on storage.objects for select
  using (
    bucket_id = 'ocr-debug-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can upload their OCR debug images"
  on storage.objects for insert
  with check (
    bucket_id = 'ocr-debug-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their OCR debug images"
  on storage.objects for update
  using (
    bucket_id = 'ocr-debug-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'ocr-debug-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can delete their OCR debug images"
  on storage.objects for delete
  using (
    bucket_id = 'ocr-debug-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
