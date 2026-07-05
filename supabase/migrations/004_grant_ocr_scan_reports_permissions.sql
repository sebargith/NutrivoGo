grant usage on schema public to authenticated;

grant select, insert, update, delete
on table public.ocr_scan_reports
to authenticated;

grant usage, select
on all sequences in schema public
to authenticated;
