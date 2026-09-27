-- PlantOps sample data. Run after schema.sql in Supabase SQL Editor.
-- Safe to run more than once: machines, alarms, and work orders use stable IDs.
-- The records are illustrative training data, not live plant measurements.

insert into public.machines (id, name, machine_type, location, status) values
  ('PMP-001', 'Cooling Water Pump A', 'Centrifugal Pump', 'Utility · Zone A', 'Running'),
  ('MTR-014', 'Main Drive Motor', 'Induction Motor', 'Production · Line 1', 'Alarm'),
  ('CMP-003', 'Air Compressor 03', 'Air Compressor', 'Utility · Zone B', 'Maintenance'),
  ('CNV-008', 'Transfer Conveyor', 'Belt Conveyor', 'Production · Line 2', 'Running'),
  ('FAN-021', 'Exhaust Fan 21', 'Axial Fan', 'Finishing · Zone C', 'Stop')
on conflict (id) do update set
  name = excluded.name,
  machine_type = excluded.machine_type,
  location = excluded.location,
  status = excluded.status,
  updated_at = now();

insert into public.alarms
  (id, machine_id, alarm_code, description, occurred_at, cause, status, severity)
values
  ('10000000-0000-4000-8000-000000000001', 'MTR-014', 'OVR-042', 'Motor overcurrent detected', current_date - 1 + time '09:42', 'Possible bearing friction; inspect motor current and bearing condition', 'Open', 'Critical'),
  ('10000000-0000-4000-8000-000000000002', 'FAN-021', 'TMP-018', 'High winding temperature', current_date - 1 + time '09:18', 'Cooling path inspection required', 'In Progress', 'Warning'),
  ('10000000-0000-4000-8000-000000000003', 'PMP-001', 'PRS-006', 'Discharge pressure fluctuation', current_date - 1 + time '08:56', 'Pressure sensor signal variation; check transmitter wiring', 'In Progress', 'Warning'),
  ('10000000-0000-4000-8000-000000000004', 'CNV-008', 'VIB-103', 'Vibration above threshold', current_date - 2 + time '16:34', 'Alignment check recommended', 'Closed', 'Info')
on conflict (id) do update set
  machine_id = excluded.machine_id,
  alarm_code = excluded.alarm_code,
  description = excluded.description,
  occurred_at = excluded.occurred_at,
  cause = excluded.cause,
  status = excluded.status,
  severity = excluded.severity;

insert into public.maintenance_records
  (id, machine_id, maintenance_type, problem, action_taken, technician_name, performed_at, status)
values
  ('20000000-0000-4000-8000-000000000001', 'CMP-003', 'Preventive', 'Quarterly service and filter replacement', 'Inspecting compressor stages; replace filter and record pressure readings', 'Narin S.', current_date - 1, 'In Progress'),
  ('20000000-0000-4000-8000-000000000002', 'MTR-014', 'Corrective', 'Investigate overcurrent alarm OVR-042', 'Pending current measurement and bearing inspection', 'Kanya P.', current_date, 'Scheduled'),
  ('20000000-0000-4000-8000-000000000003', 'FAN-021', 'Inspection', 'Inspect cooling and winding temperature', 'Cleaned inlet grille; verify temperature after restart', 'Somchai T.', current_date - 2, 'Completed')
on conflict (id) do update set
  machine_id = excluded.machine_id,
  maintenance_type = excluded.maintenance_type,
  problem = excluded.problem,
  action_taken = excluded.action_taken,
  technician_name = excluded.technician_name,
  performed_at = excluded.performed_at,
  status = excluded.status;
