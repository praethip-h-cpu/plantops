-- PlantOps database schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'Technician' check (role in ('Admin','Technician')),
  created_at timestamptz not null default now()
);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''), 'Technician');
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
create table if not exists public.machines (
  id text primary key,
  name text not null,
  machine_type text not null,
  location text not null,
  status text not null default 'Running' check (status in ('Running','Stop','Alarm','Maintenance')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.alarms (
  id uuid primary key default gen_random_uuid(),
  machine_id text not null references public.machines(id) on delete cascade,
  alarm_code text not null,
  description text not null,
  occurred_at timestamptz not null default now(),
  cause text not null default '',
  status text not null default 'Open' check (status in ('Open','In Progress','Closed')),
  severity text not null default 'Warning' check (severity in ('Critical','Warning','Info')),
  created_by uuid references public.profiles(id), created_at timestamptz not null default now()
);
create table if not exists public.maintenance_records (
  id uuid primary key default gen_random_uuid(),
  machine_id text not null references public.machines(id) on delete cascade,
  maintenance_type text not null check (maintenance_type in ('Preventive','Corrective','Inspection')),
  problem text not null,
  action_taken text not null default '',
  technician_id uuid references public.profiles(id),
  technician_name text not null default '',
  performed_at date not null default current_date,
  status text not null default 'Scheduled' check (status in ('Scheduled','In Progress','Completed')),
  created_at timestamptz not null default now()
);

create or replace function public.current_role() returns text language sql stable security definer set search_path=public as $$
  select role from public.profiles where id=auth.uid()
$$;
alter table public.profiles enable row level security;
alter table public.machines enable row level security;
alter table public.alarms enable row level security;
alter table public.maintenance_records enable row level security;
drop policy if exists "Authenticated users can read profiles" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Authenticated users can read machines" on public.machines;
drop policy if exists "Admins manage machines" on public.machines;
drop policy if exists "Authenticated users can read alarms" on public.alarms;
drop policy if exists "Authenticated users create alarms" on public.alarms;
drop policy if exists "Authenticated users update alarms" on public.alarms;
drop policy if exists "Admins delete alarms" on public.alarms;
drop policy if exists "Admins manage alarms" on public.alarms;
drop policy if exists "Technicians update alarm status" on public.alarms;
drop policy if exists "Authenticated users can read maintenance" on public.maintenance_records;
drop policy if exists "Authenticated users create maintenance" on public.maintenance_records;
drop policy if exists "Authenticated users update maintenance" on public.maintenance_records;
drop policy if exists "Admins delete maintenance" on public.maintenance_records;
drop policy if exists "Admins manage maintenance" on public.maintenance_records;
drop policy if exists "Technicians create maintenance" on public.maintenance_records;
drop policy if exists "Technicians update maintenance" on public.maintenance_records;
create policy "Authenticated users can read profiles" on public.profiles for select to authenticated using (true);
create policy "Users can update own profile" on public.profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());
-- A user must not be able to promote themselves by editing their own role.
revoke update on public.profiles from authenticated;
grant update (full_name) on public.profiles to authenticated;
create policy "Authenticated users can read machines" on public.machines for select to authenticated using (true);
create policy "Admins manage machines" on public.machines for all to authenticated using (public.current_role()='Admin') with check (public.current_role()='Admin');
create policy "Authenticated users can read alarms" on public.alarms for select to authenticated using (true);
create policy "Admins manage alarms" on public.alarms for all to authenticated using (public.current_role()='Admin') with check (public.current_role()='Admin');
create policy "Technicians update alarm status" on public.alarms for update to authenticated using (public.current_role()='Technician') with check (public.current_role()='Technician');

-- RLS checks row access, not changed columns. Keep technicians limited to alarm status.
create or replace function public.guard_alarm_update()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  if public.current_role() is distinct from 'Admin'
     and row(new.id, new.machine_id, new.alarm_code, new.description, new.occurred_at,
             new.cause, new.severity, new.created_by, new.created_at)
         is distinct from
         row(old.id, old.machine_id, old.alarm_code, old.description, old.occurred_at,
             old.cause, old.severity, old.created_by, old.created_at) then
    raise exception 'Technicians may only change alarm status';
  end if;
  return new;
end;
$$;
drop trigger if exists guard_alarm_update on public.alarms;
create trigger guard_alarm_update before update on public.alarms
for each row execute function public.guard_alarm_update();

create policy "Authenticated users can read maintenance" on public.maintenance_records for select to authenticated using (true);
create policy "Admins manage maintenance" on public.maintenance_records for all to authenticated using (public.current_role()='Admin') with check (public.current_role()='Admin');
create policy "Technicians create maintenance" on public.maintenance_records for insert to authenticated with check (public.current_role()='Technician');
create policy "Technicians update maintenance" on public.maintenance_records for update to authenticated using (public.current_role()='Technician') with check (public.current_role()='Technician');

-- Explicit table privileges are required because automatic exposure of new tables is disabled.
grant usage on schema public to authenticated;
grant select on public.profiles to authenticated;
grant select, insert, update, delete on public.machines to authenticated;
grant select, insert, update, delete on public.alarms to authenticated;
grant select, insert, update, delete on public.maintenance_records to authenticated;

-- Promote the first supervisor profile to Admin in the table editor:
-- update public.profiles set role='Admin' where id='AUTH_USER_UUID';
