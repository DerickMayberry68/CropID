begin;

-- The auth trigger only handles users created after the baseline migration.
-- Backfill users that already existed when public.profiles was introduced.
insert into public.profiles (
  id,
  email,
  full_name,
  phone_number,
  farm_name,
  created_at
)
select
  auth_user.id,
  coalesce(auth_user.email, ''),
  coalesce(
    nullif(auth_user.raw_user_meta_data ->> 'full_name', ''),
    nullif(split_part(coalesce(auth_user.email, ''), '@', 1), ''),
    'Farmer'
  ),
  coalesce(
    nullif(auth_user.raw_user_meta_data ->> 'phone_number', ''),
    nullif(auth_user.phone, '')
  ),
  nullif(auth_user.raw_user_meta_data ->> 'farm_name', ''),
  coalesce(auth_user.created_at, now())
from auth.users as auth_user
on conflict (id) do nothing;

commit;
