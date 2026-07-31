-- Claimable USDA field boundaries and seasonal crop history.

begin;

create table public.csb_fields (
  csb_id text primary key,
  state text not null,
  county_fips text,
  boundary extensions.geography(polygon, 4326) not null,
  boundary_points jsonb not null default '[]'::jsonb,
  acres numeric(10, 2) check (acres is null or acres >= 0),
  crop_year integer,
  predicted_crop_id text references public.crops(id) on delete set null
);

create index csb_fields_boundary_idx
  on public.csb_fields using gist (boundary);
create index csb_fields_state_county_idx
  on public.csb_fields (state, county_fips);
create index csb_fields_predicted_crop_id_idx
  on public.csb_fields (predicted_crop_id);

alter table public.fields
  add column source text not null default 'manual'
    check (source in ('manual', 'csb', 'clu', 'oauth')),
  add column csb_id text references public.csb_fields(csb_id) on delete set null,
  add column clu_id text,
  add column acres numeric(10, 2) check (acres is null or acres >= 0);

create unique index fields_csb_id_unique_idx
  on public.fields (csb_id)
  where csb_id is not null;

create or replace function public.csb_fields_near(
  lat double precision,
  lng double precision,
  radius_m double precision default 1000
)
returns setof public.csb_fields
language sql
stable
security invoker
set search_path = ''
as $$
  select c.*
  from public.csb_fields as c
  where extensions.st_dwithin(
    c.boundary,
    extensions.st_setsrid(
      extensions.st_makepoint(lng, lat),
      4326
    )::extensions.geography,
    radius_m
  )
  and not exists (
    select 1
    from public.fields as f
    where f.csb_id = c.csb_id
  );
$$;

create or replace function public.claim_csb_field(
  p_csb_id text,
  p_name text default null
)
returns public.fields
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id uuid := (select auth.uid());
  source_field public.csb_fields%rowtype;
  claimed_field public.fields%rowtype;
begin
  if caller_id is null then
    raise exception 'Not authenticated'
      using errcode = '42501';
  end if;

  select c.*
  into source_field
  from public.csb_fields as c
  where c.csb_id = p_csb_id;

  if not found then
    raise exception 'CSB boundary % not found', p_csb_id
      using errcode = 'P0002';
  end if;

  insert into public.fields (
    farmer_id,
    name,
    boundary,
    boundary_points,
    current_crop_id,
    current_crop_name,
    source,
    csb_id,
    acres,
    visibility
  )
  values (
    caller_id,
    coalesce(nullif(trim(p_name), ''), 'Field ' || left(p_csb_id, 6)),
    source_field.boundary,
    source_field.boundary_points,
    source_field.predicted_crop_id,
    (
      select c.name
      from public.crops as c
      where c.id = source_field.predicted_crop_id
    ),
    'csb',
    source_field.csb_id,
    source_field.acres,
    'anonymous'
  )
  returning *
  into claimed_field;

  return claimed_field;
exception
  when unique_violation then
    raise exception 'Field % has already been claimed', p_csb_id
      using errcode = '23505';
end;
$$;

create table public.field_crop_seasons (
  id uuid primary key default gen_random_uuid(),
  field_id uuid not null references public.fields(id) on delete cascade,
  crop_id text references public.crops(id) on delete set null,
  crop_name text,
  season_year integer not null
    check (season_year between 1900 and 2200),
  season_label text,
  planting_date date,
  expected_harvest_date date,
  growth_stage text,
  is_active boolean not null default true,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (field_id, season_year, season_label)
);

create index field_crop_seasons_field_id_idx
  on public.field_crop_seasons (field_id);
create index field_crop_seasons_crop_id_idx
  on public.field_crop_seasons (crop_id);
create index field_crop_seasons_field_year_idx
  on public.field_crop_seasons (field_id, season_year desc);
create unique index field_crop_seasons_one_active_idx
  on public.field_crop_seasons (field_id)
  where is_active = true;

create trigger field_crop_seasons_set_updated_at
  before update on public.field_crop_seasons
  for each row execute function private.set_updated_at();

alter table public.csb_fields enable row level security;
alter table public.field_crop_seasons enable row level security;

create policy csb_fields_read
  on public.csb_fields
  for select
  to authenticated
  using (true);

create policy field_crop_seasons_select_own
  on public.field_crop_seasons
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.fields as f
      where f.id = field_id
        and f.farmer_id = (select auth.uid())
    )
  );

create policy field_crop_seasons_insert_own
  on public.field_crop_seasons
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.fields as f
      where f.id = field_id
        and f.farmer_id = (select auth.uid())
    )
  );

create policy field_crop_seasons_update_own
  on public.field_crop_seasons
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.fields as f
      where f.id = field_id
        and f.farmer_id = (select auth.uid())
    )
  )
  with check (
    exists (
      select 1
      from public.fields as f
      where f.id = field_id
        and f.farmer_id = (select auth.uid())
    )
  );

create policy field_crop_seasons_delete_own
  on public.field_crop_seasons
  for delete
  to authenticated
  using (
    exists (
      select 1
      from public.fields as f
      where f.id = field_id
        and f.farmer_id = (select auth.uid())
    )
  );

revoke all on table public.csb_fields from anon, authenticated;
revoke all on table public.field_crop_seasons from anon, authenticated;

grant select on table public.csb_fields to authenticated;
grant select, insert, update, delete
  on table public.field_crop_seasons
  to authenticated;

grant all privileges on table public.csb_fields to service_role;
grant all privileges on table public.field_crop_seasons to service_role;

revoke all on function public.csb_fields_near(
  double precision,
  double precision,
  double precision
) from public, anon;
revoke all on function public.claim_csb_field(text, text)
  from public, anon;

grant execute on function public.csb_fields_near(
  double precision,
  double precision,
  double precision
) to authenticated, service_role;
grant execute on function public.claim_csb_field(text, text)
  to authenticated, service_role;

commit;
