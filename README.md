# PlantOps — Alarm & Maintenance Management

PlantOps is a Next.js web application concept for monitoring factory equipment, alarms, and maintenance work. The interface includes an operations dashboard, machine master, alarm records, maintenance work orders, search/filter, CSV export, and a responsive layout.

## Technology

- Next.js 14, React, TypeScript, Tailwind CSS
- Supabase (Postgres and Auth schema prepared)
- GitHub Actions build workflow
- Vercel deployment target
- AI-assisted development: AI was used to interpret the assignment, draft the UI, data model, SQL, and documentation. A developer should review configuration and connect external services before production use.

## Database structure

Run [`supabase/schema.sql`](supabase/schema.sql) in the Supabase SQL Editor. It creates `profiles`, `machines`, `alarms`, and `maintenance_records`, their relationships, constraints, grants, and row-level security policies. If you already ran the earlier schema version, run [`supabase/permissions.sql`](supabase/permissions.sql) once to apply the required API grants. New signups receive the `Technician` role; promote a trusted supervisor to `Admin` from the SQL Editor.

## Run locally

1. Install Node.js 20 or later.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local` and fill in the Supabase project URL and publishable key.
4. Run `npm run dev`, then open http://localhost:3000.

When Supabase environment variables are present, the app uses Supabase Auth and reads/writes the four database tables. If the variables are absent, the app starts with demo data saved in the browser. Row-level security enforces Admin-only machine management; role display in the app comes from `profiles`.

Create an account from the app's sign-in screen. New accounts default to `Technician`. To make the first supervisor an administrator, copy that account's UUID from **Authentication → Users**, then run `update public.profiles set role='Admin' where id='USER_UUID';` in the Supabase SQL Editor. The password stays with the user and is never stored in the project source.

## GitHub Actions

The workflow in `.github/workflows/ci.yml` installs dependencies and builds on pushes and pull requests to `main`.

## Deploy to Vercel

Import the repository in Vercel, set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in project environment variables, and deploy. Add the resulting Vercel URL here: **Not deployed yet**.

## Submission checklist

- GitHub repository URL: **Not connected yet**
- Vercel URL: **Not deployed yet**
- Supabase schema: `supabase/schema.sql`
- Screenshots: capture the dashboard and each record page after launching locally
- AI usage report: see the AI-assisted development note above
