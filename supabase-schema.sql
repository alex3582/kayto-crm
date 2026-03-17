-- ─────────────────────────────────────────────────────────────────
-- Kayto Tech CRM — Supabase Schema (Multi-User with Roles)
-- Paste this entire file into the Supabase SQL Editor and click Run
-- ─────────────────────────────────────────────────────────────────

create extension if not exists "pgcrypto";

-- ── USER ROLES ────────────────────────────────────────────────────
-- Stores each authorised user and their role (admin or user)
-- Add rows here to grant access. Remove rows to revoke access.
create table if not exists user_roles (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade unique,
  email      text not null,
  role       text not null default 'user' check (role in ('admin','user')),
  created_at timestamptz default now()
);

alter table user_roles enable row level security;

-- Anyone authenticated can read their own role (needed for the app to check permissions)
create policy "Users can read own role"
  on user_roles for select
  using (auth.uid() = user_id);

-- Only admins can insert/update/delete roles
create policy "Admins manage roles"
  on user_roles for all
  using (
    exists (
      select 1 from user_roles
      where user_id = auth.uid() and role = 'admin'
    )
  );

-- ── HELPER FUNCTION ───────────────────────────────────────────────
-- Returns the current user's role — used in all RLS policies below
create or replace function current_user_role()
returns text as $$
  select role from user_roles where user_id = auth.uid();
$$ language sql security definer stable;

-- ── CLIENTS ───────────────────────────────────────────────────────
create table if not exists clients (
  id          uuid primary key default gen_random_uuid(),
  company     text not null,
  industry    text,
  contact     text,
  email       text,
  phone       text,
  status      text default 'Active',
  created_by  uuid references auth.users(id),
  created_at  timestamptz default now()
);

alter table clients enable row level security;

-- All authorised users can read
create policy "Authorised users read clients"
  on clients for select
  using (
    exists (select 1 from user_roles where user_id = auth.uid())
  );

-- Only admins can write
create policy "Admins write clients"
  on clients for insert
  with check (current_user_role() = 'admin');

create policy "Admins update clients"
  on clients for update
  using (current_user_role() = 'admin');

create policy "Admins delete clients"
  on clients for delete
  using (current_user_role() = 'admin');

-- ── CONTACTS ─────────────────────────────────────────────────────
create table if not exists contacts (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  title       text,
  company     text,
  email       text,
  phone       text,
  created_by  uuid references auth.users(id),
  created_at  timestamptz default now()
);

alter table contacts enable row level security;

create policy "Authorised users read contacts"
  on contacts for select
  using (
    exists (select 1 from user_roles where user_id = auth.uid())
  );

create policy "Admins write contacts"
  on contacts for insert
  with check (current_user_role() = 'admin');

create policy "Admins update contacts"
  on contacts for update
  using (current_user_role() = 'admin');

create policy "Admins delete contacts"
  on contacts for delete
  using (current_user_role() = 'admin');

-- ── OPPORTUNITIES ─────────────────────────────────────────────────
create table if not exists opportunities (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  company       text,
  value         numeric default 0,
  stage         text default 'qualify',
  prob          integer default 25,
  cost_rate     numeric,
  sell_rate     numeric,
  rate_unit     text default 'day',
  duration      numeric,
  duration_unit text default 'days',
  gp_amount     numeric,
  gp_percent    numeric,
  notes         text,
  created_by    uuid references auth.users(id),
  created_at    timestamptz default now()
);

alter table opportunities enable row level security;

create policy "Authorised users read opportunities"
  on opportunities for select
  using (
    exists (select 1 from user_roles where user_id = auth.uid())
  );

create policy "Admins write opportunities"
  on opportunities for insert
  with check (current_user_role() = 'admin');

create policy "Admins update opportunities"
  on opportunities for update
  using (current_user_role() = 'admin');

create policy "Admins delete opportunities"
  on opportunities for delete
  using (current_user_role() = 'admin');

-- ── RESOLVED DEALS ────────────────────────────────────────────────
create table if not exists resolved_deals (
  id             uuid primary key default gen_random_uuid(),
  name           text,
  company        text,
  original_value numeric,
  closed_value   numeric,
  outcome        text,
  gp_amount      numeric,
  gp_percent     numeric,
  created_by     uuid references auth.users(id),
  closed_at      timestamptz default now()
);

alter table resolved_deals enable row level security;

create policy "Authorised users read resolved deals"
  on resolved_deals for select
  using (
    exists (select 1 from user_roles where user_id = auth.uid())
  );

create policy "Admins write resolved deals"
  on resolved_deals for insert
  with check (current_user_role() = 'admin');

create policy "Admins update resolved deals"
  on resolved_deals for update
  using (current_user_role() = 'admin');

create policy "Admins delete resolved deals"
  on resolved_deals for delete
  using (current_user_role() = 'admin');
