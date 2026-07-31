begin;

alter table public.crop_duster_services
  add column service_type text not null default 'ag_air'
  constraint crop_duster_services_service_type_check
  check (service_type in ('drone', 'ag_air', 'co_op'));

create index crop_duster_services_active_type_name_idx
  on public.crop_duster_services (service_type, name)
  where is_active = true;

commit;
