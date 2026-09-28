-- Tighten role enforcement for an existing PlantOps database.
-- Safe to run repeatedly; this changes policies/functions only and preserves data.
begin;

create or replace function public.current_role() returns text
language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid()
$$;

alter table public.profiles enable row level security;
alter table public.machines enable row level security;
alter table public.alarms enable row level security;
alter table public.maintenance_records enable row level security;

drop policy if exists "Authenticated users can read profiles" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Authenticated users can read profiles"
  on public.profiles for select to authenticated using (true);
create policy "Users can update own profile"
  on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());
revoke update on public.profiles from authenticated;
grant select on public.profiles to authenticated;
grant update (full_name) on public.profiles to authenticated;

drop policy if exists "Authenticated users can read machines" on public.machines;
drop policy if exists "Admins manage machines" on public.machines;
create policy "Authenticated users can read machines"
  on public.machines for select to authenticated using (true);
create policy "Admins manage machines"
  on public.machines for all to authenticated
  using (public.current_role() = 'Admin')
  with check (public.current_role() = 'Admin');

drop policy if exists "Authenticated users can read alarms" on public.alarms;
drop policy if exists "Authenticated users create alarms" on public.alarms;
drop policy if exists "Authenticated users update alarms" on public.alarms;
drop policy if exists "Admins delete alarms" on public.alarms;
drop policy if exists "Admins manage alarms" on public.alarms;
drop policy if exists "Technicians update alarm status" on public.alarms;
create policy "Authenticated users can read alarms"
  on public.alarms for select to authenticated using (true);
create policy "Admins manage alarms"
  on public.alarms for all to authenticated
  using (public.current_role() = 'Admin')
  with check (public.current_role() = 'Admin');
create policy "Technicians update alarm status"
  on public.alarms for update to authenticated
  using (public.current_role() = 'Technician')
  with check (public.current_role() = 'Technician');

-- RLS checks row access, not which columns changed. This trigger makes sure a
-- Technician can change only status even if a client sends extra fields.
create or replace function public.guard_alarm_update()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if public.current_role() is distinct from 'Admin'
     and row(new.id, new.machine_id, new.alarm_code, new.description,
             new.occurred_at, new.cause, new.severity, new.created_by,
             new.created_at)
         is distinct from
         row(old.id, old.machine_id, old.alarm_code, old.description,
             old.occurred_at, old.cause, old.severity, old.created_by,
             old.created_at) then
    raise exception 'Technicians may only change alarm status';
  end if;
  return new;
end;
$$;
drop trigger if exists guard_alarm_update on public.alarms;
create trigger guard_alarm_update
  before update on public.alarms
  for each row execute function public.guard_alarm_update();

drop policy if exists "Authenticated users can read maintenance" on public.maintenance_records;
drop policy if exists "Authenticated users create maintenance" on public.maintenance_records;
drop policy if exists "Authenticated users update maintenance" on public.maintenance_records;
drop policy if exists "Admins delete maintenance" on public.maintenance_records;
drop policy if exists "Admins manage maintenance" on public.maintenance_records;
drop policy if exists "Technicians create maintenance" on public.maintenance_records;
drop policy if exists "Technicians update maintenance" on public.maintenance_records;
create policy "Authenticated users can read maintenance"
  on public.maintenance_records for select to authenticated using (true);
create policy "Admins manage maintenance"
  on public.maintenance_records for all to authenticated
  using (public.current_role() = 'Admin')
  with check (public.current_role() = 'Admin');
create policy "Technicians create maintenance"
  on public.maintenance_records for insert to authenticated
  with check (public.current_role() = 'Technician');
create policy "Technicians update maintenance"
  on public.maintenance_records for update to authenticated
  using (public.current_role() = 'Technician')
  with check (public.current_role() = 'Technician');

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.machines to authenticated;
grant select, insert, update, delete on public.alarms to authenticated;
grant select, insert, update, delete on public.maintenance_records to authenticated;

commit;
