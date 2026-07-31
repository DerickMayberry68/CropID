-- CropID baseline schema.
-- Fresh-project migration for Auth profiles, fields, spray planning,
-- notifications, service discovery, Storage, and Realtime.

begin;

create extension if not exists postgis with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Shared trigger helpers
-- ---------------------------------------------------------------------------

create or replace function private.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke all on function private.set_updated_at() from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text not null,
  phone_number text,
  farm_name text,
  farm_latitude double precision,
  farm_longitude double precision,
  avatar_url text,
  field_sharing_enabled boolean not null default false,
  gdpr_consent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  consent_at timestamptz;
begin
  begin
    consent_at :=
      nullif(new.raw_user_meta_data ->> 'gdpr_consent_at', '')::timestamptz;
  exception
    when invalid_datetime_format then
      consent_at := null;
  end;

  insert into public.profiles (
    id,
    email,
    full_name,
    gdpr_consent_at
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    consent_at
  )
  on conflict (id) do update
  set
    email = excluded.email,
    full_name = coalesce(
      nullif(excluded.full_name, ''),
      public.profiles.full_name
    ),
    gdpr_consent_at = coalesce(
      public.profiles.gdpr_consent_at,
      excluded.gdpr_consent_at
    ),
    updated_at = now();

  return new;
end;
$$;

revoke all on function private.handle_new_user()
  from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Reference data
-- ---------------------------------------------------------------------------

create table public.crops (
  id text primary key,
  name text not null,
  scientific_name text,
  icon_url text,
  sensitive_to text[] not null default '{}',
  tags text[] not null default '{}'
);

create table public.chemicals (
  id text primary key,
  name text not null,
  common_name text,
  manufacturer text,
  toxicity_level text not null default 'moderate'
    check (toxicity_level in ('low', 'moderate', 'high', 'extreme')),
  dangerous_to_crop_ids text[] not null default '{}',
  dangerous_to_crop_names text[] not null default '{}',
  incompatible_with_chemical_ids text[] not null default '{}',
  withdrawal_period_days text,
  notes text
);

-- ---------------------------------------------------------------------------
-- Farmer fields and spatial discovery
-- ---------------------------------------------------------------------------

create table public.fields (
  id uuid primary key default gen_random_uuid(),
  farmer_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  boundary extensions.geography(polygon, 4326),
  boundary_points jsonb not null default '[]'::jsonb,
  current_crop_id text references public.crops(id),
  current_crop_name text,
  visibility text not null default 'private'
    check (visibility in ('private', 'anonymous', 'public')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index fields_boundary_idx
  on public.fields using gist (boundary);
create index fields_farmer_id_idx
  on public.fields (farmer_id);
create index fields_current_crop_id_idx
  on public.fields (current_crop_id);
create index fields_visibility_idx
  on public.fields (visibility);

create trigger fields_set_updated_at
  before update on public.fields
  for each row execute function private.set_updated_at();

create or replace function public.fields_within_radius(
  lat double precision,
  lng double precision,
  radius_m double precision default 500
)
returns setof public.fields
language sql
stable
security invoker
set search_path = ''
as $$
  select f.*
  from public.fields as f
  where f.visibility <> 'private'
    and f.boundary is not null
    and extensions.st_dwithin(
      f.boundary,
      extensions.st_setsrid(
        extensions.st_makepoint(lng, lat),
        4326
      )::extensions.geography,
      radius_m
    );
$$;

revoke all on function public.fields_within_radius(
  double precision,
  double precision,
  double precision
) from public, anon;

-- ---------------------------------------------------------------------------
-- Spray planning
-- ---------------------------------------------------------------------------

create table public.spray_plans (
  id uuid primary key default gen_random_uuid(),
  farmer_id uuid not null references public.profiles(id) on delete cascade,
  field_id uuid not null references public.fields(id) on delete cascade,
  field_name text,
  status text not null default 'draft'
    check (status in ('draft', 'scheduled', 'completed', 'cancelled')),
  dangerous_adjacent_field_ids uuid[] not null default '{}',
  notes text,
  scheduled_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index spray_plans_farmer_id_idx
  on public.spray_plans (farmer_id);
create index spray_plans_field_id_idx
  on public.spray_plans (field_id);
create index spray_plans_farmer_created_at_idx
  on public.spray_plans (farmer_id, created_at desc);

create trigger spray_plans_set_updated_at
  before update on public.spray_plans
  for each row execute function private.set_updated_at();

create table public.spray_plan_chemicals (
  spray_plan_id uuid not null
    references public.spray_plans(id) on delete cascade,
  chemical_id text not null
    references public.chemicals(id) on delete restrict,
  primary key (spray_plan_id, chemical_id)
);

create index spray_plan_chemicals_chemical_id_idx
  on public.spray_plan_chemicals (chemical_id);

-- ---------------------------------------------------------------------------
-- Neighbor risk notifications
-- ---------------------------------------------------------------------------

create table public.danger_notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_farmer_id uuid not null
    references public.profiles(id) on delete cascade,
  sender_farmer_id uuid not null
    references public.profiles(id) on delete cascade,
  spray_plan_id uuid not null
    references public.spray_plans(id) on delete cascade,
  affected_field_id uuid not null
    references public.fields(id) on delete cascade,
  affected_field_name text,
  sender_farm_name text,
  dangerous_chemical_names text[] not null default '{}',
  spray_scheduled_date date,
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  unique (recipient_farmer_id, spray_plan_id, affected_field_id)
);

create index danger_notifications_recipient_created_at_idx
  on public.danger_notifications (recipient_farmer_id, created_at desc);
create index danger_notifications_recipient_unread_idx
  on public.danger_notifications (recipient_farmer_id, is_read)
  where is_read = false;
create index danger_notifications_sender_farmer_id_idx
  on public.danger_notifications (sender_farmer_id);
create index danger_notifications_spray_plan_id_idx
  on public.danger_notifications (spray_plan_id);
create index danger_notifications_affected_field_id_idx
  on public.danger_notifications (affected_field_id);

-- ---------------------------------------------------------------------------
-- Public crop-duster directory
-- ---------------------------------------------------------------------------

create table public.crop_duster_services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  email text,
  website text,
  latitude double precision,
  longitude double precision,
  address text,
  state text,
  service_radius_miles integer
    check (service_radius_miles is null or service_radius_miles > 0),
  location extensions.geography(point, 4326),
  is_active boolean not null default true
);

create index crop_duster_services_location_idx
  on public.crop_duster_services using gist (location);
create index crop_duster_services_active_name_idx
  on public.crop_duster_services (name)
  where is_active = true;

-- ---------------------------------------------------------------------------
-- Row-level security
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.crops enable row level security;
alter table public.fields enable row level security;
alter table public.chemicals enable row level security;
alter table public.spray_plans enable row level security;
alter table public.spray_plan_chemicals enable row level security;
alter table public.danger_notifications enable row level security;
alter table public.crop_duster_services enable row level security;

create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using ((select auth.uid()) = id);

create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy crops_read
  on public.crops
  for select
  to anon, authenticated
  using (true);

create policy chemicals_read
  on public.chemicals
  for select
  to anon, authenticated
  using (true);

create policy fields_select_own
  on public.fields
  for select
  to authenticated
  using ((select auth.uid()) = farmer_id);

create policy fields_select_shared
  on public.fields
  for select
  to authenticated
  using (visibility <> 'private');

create policy fields_insert_own
  on public.fields
  for insert
  to authenticated
  with check ((select auth.uid()) = farmer_id);

create policy fields_update_own
  on public.fields
  for update
  to authenticated
  using ((select auth.uid()) = farmer_id)
  with check ((select auth.uid()) = farmer_id);

create policy fields_delete_own
  on public.fields
  for delete
  to authenticated
  using ((select auth.uid()) = farmer_id);

create policy spray_plans_select_own
  on public.spray_plans
  for select
  to authenticated
  using ((select auth.uid()) = farmer_id);

create policy spray_plans_insert_own
  on public.spray_plans
  for insert
  to authenticated
  with check (
    (select auth.uid()) = farmer_id
    and exists (
      select 1
      from public.fields as f
      where f.id = field_id
        and f.farmer_id = (select auth.uid())
    )
  );

create policy spray_plans_update_own
  on public.spray_plans
  for update
  to authenticated
  using ((select auth.uid()) = farmer_id)
  with check (
    (select auth.uid()) = farmer_id
    and exists (
      select 1
      from public.fields as f
      where f.id = field_id
        and f.farmer_id = (select auth.uid())
    )
  );

create policy spray_plans_delete_own
  on public.spray_plans
  for delete
  to authenticated
  using ((select auth.uid()) = farmer_id);

create policy spray_plan_chemicals_select_own
  on public.spray_plan_chemicals
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.spray_plans as sp
      where sp.id = spray_plan_id
        and sp.farmer_id = (select auth.uid())
    )
  );

create policy spray_plan_chemicals_insert_own
  on public.spray_plan_chemicals
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.spray_plans as sp
      where sp.id = spray_plan_id
        and sp.farmer_id = (select auth.uid())
    )
  );

create policy spray_plan_chemicals_delete_own
  on public.spray_plan_chemicals
  for delete
  to authenticated
  using (
    exists (
      select 1
      from public.spray_plans as sp
      where sp.id = spray_plan_id
        and sp.farmer_id = (select auth.uid())
    )
  );

create policy danger_notifications_select_own
  on public.danger_notifications
  for select
  to authenticated
  using ((select auth.uid()) = recipient_farmer_id);

create policy danger_notifications_mark_read_own
  on public.danger_notifications
  for update
  to authenticated
  using ((select auth.uid()) = recipient_farmer_id)
  with check ((select auth.uid()) = recipient_farmer_id);

create policy crop_duster_services_read_active
  on public.crop_duster_services
  for select
  to anon, authenticated
  using (is_active = true);

-- ---------------------------------------------------------------------------
-- Explicit Data API privileges
-- ---------------------------------------------------------------------------

revoke all on table public.profiles from anon, authenticated;
revoke all on table public.crops from anon, authenticated;
revoke all on table public.fields from anon, authenticated;
revoke all on table public.chemicals from anon, authenticated;
revoke all on table public.spray_plans from anon, authenticated;
revoke all on table public.spray_plan_chemicals from anon, authenticated;
revoke all on table public.danger_notifications from anon, authenticated;
revoke all on table public.crop_duster_services from anon, authenticated;

grant usage on schema public to anon, authenticated, service_role;

grant select, update on table public.profiles to authenticated;
grant select on table public.crops to anon, authenticated;
grant select, insert, update, delete on table public.fields to authenticated;
grant select on table public.chemicals to anon, authenticated;
grant select, insert, update, delete on table public.spray_plans
  to authenticated;
grant select, insert, delete on table public.spray_plan_chemicals
  to authenticated;
grant select on table public.danger_notifications to authenticated;
grant update (is_read) on table public.danger_notifications to authenticated;
grant select on table public.crop_duster_services to anon, authenticated;

grant all privileges on table public.profiles to service_role;
grant all privileges on table public.crops to service_role;
grant all privileges on table public.fields to service_role;
grant all privileges on table public.chemicals to service_role;
grant all privileges on table public.spray_plans to service_role;
grant all privileges on table public.spray_plan_chemicals to service_role;
grant all privileges on table public.danger_notifications to service_role;
grant all privileges on table public.crop_duster_services to service_role;

grant execute on function public.fields_within_radius(
  double precision,
  double precision,
  double precision
) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Avatar Storage
-- ---------------------------------------------------------------------------

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'avatars',
  'avatars',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy avatar_objects_select_own
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'avatars'
    and owner_id = (select auth.uid()::text)
  );

create policy avatar_objects_insert_own
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

create policy avatar_objects_update_own
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and owner_id = (select auth.uid()::text)
  )
  with check (
    bucket_id = 'avatars'
    and owner_id = (select auth.uid()::text)
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

create policy avatar_objects_delete_own
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and owner_id = (select auth.uid()::text)
  );

-- ---------------------------------------------------------------------------
-- Realtime publication
-- ---------------------------------------------------------------------------

do $$
begin
  if exists (
    select 1
    from pg_publication
    where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'fields'
  ) then
    alter publication supabase_realtime add table public.fields;
  end if;

  if exists (
    select 1
    from pg_publication
    where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'danger_notifications'
  ) then
    alter publication supabase_realtime
      add table public.danger_notifications;
  end if;
end
$$;

commit;
