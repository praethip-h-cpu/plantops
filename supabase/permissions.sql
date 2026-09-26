-- Run this if schema.sql was already applied before the explicit grants were added.
-- RLS policies still control which rows and operations each role may access.
grant usage on schema public to authenticated;
grant select on public.profiles to authenticated;
grant update (full_name) on public.profiles to authenticated;
grant select, insert, update, delete on public.machines to authenticated;
grant select, insert, update, delete on public.alarms to authenticated;
grant select, insert, update, delete on public.maintenance_records to authenticated;
