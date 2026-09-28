-- Bonus capabilities migration: Viewer role, Waiting Part status and audit history.
-- Safe to run more than once; existing records are preserved.
begin;

alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('Admin','Technician','Viewer'));

alter table public.maintenance_records drop constraint if exists maintenance_records_status_check;
alter table public.maintenance_records add constraint maintenance_records_status_check
  check (status in ('Scheduled','In Progress','Waiting Part','Completed'));

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id) on delete set null,
  actor_role text,
  action text not null,
  entity_type text not null,
  entity_id text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
alter table public.audit_logs enable row level security;
drop policy if exists "Admins read audit logs" on public.audit_logs;
create policy "Admins read audit logs" on public.audit_logs
  for select to authenticated using (public.current_role() = 'Admin');
grant select on public.audit_logs to authenticated;

create or replace function public.write_audit_log()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  old_row jsonb;
  new_row jsonb;
  row_id text;
  event_action text;
begin
  old_row := case when tg_op = 'INSERT' then null else to_jsonb(old) end;
  new_row := case when tg_op = 'DELETE' then null else to_jsonb(new) end;
  row_id := coalesce(new_row->>'id', old_row->>'id', new_row->>'machine_id', old_row->>'machine_id');
  event_action := case when tg_op = 'INSERT' then 'created'
    when tg_op = 'DELETE' then 'deleted'
    when (old_row - 'status' - 'updated_at') = (new_row - 'status' - 'updated_at')
      and old_row->>'status' is distinct from new_row->>'status' then 'status_changed'
    else 'updated' end;
  insert into public.audit_logs(actor_id, actor_role, action, entity_type, entity_id, details)
  values (auth.uid(), public.current_role(), event_action, tg_table_name, coalesce(row_id, 'unknown'),
    jsonb_build_object('before', old_row, 'after', new_row));
  return coalesce(new, old);
end;
$$;

drop trigger if exists audit_machines on public.machines;
create trigger audit_machines after insert or update or delete on public.machines
  for each row execute function public.write_audit_log();
drop trigger if exists audit_alarms on public.alarms;
create trigger audit_alarms after insert or update or delete on public.alarms
  for each row execute function public.write_audit_log();
drop trigger if exists audit_maintenance on public.maintenance_records;
create trigger audit_maintenance after insert or update or delete on public.maintenance_records
  for each row execute function public.write_audit_log();

commit;
