-- Read-only checks. Run in the Supabase SQL Editor after applying the schema.
select t.table_name, c.relrowsecurity as rls_activo
from information_schema.tables t
join pg_class c on c.relname = t.table_name
join pg_namespace n on n.oid = c.relnamespace and n.nspname = 'public'
where t.table_schema = 'public'
  and t.table_name in ('negocios','productos','movimientos','movimiento_items')
order by t.table_name;

select table_name, privilege_type
from information_schema.role_table_grants
where grantee = 'authenticated'
  and table_schema='public'
  and table_name in ('negocios','productos','movimientos','movimiento_items')
order by table_name, privilege_type;

select count(*) as total_negocios from public.negocios;
select count(*) as total_productos from public.productos;
select count(*) as total_movimientos from public.movimientos;
select count(*) as total_items from public.movimiento_items;

-- These should be FALSE after migration 03:
select has_table_privilege('authenticated','public.movimientos','INSERT') as permite_insert_movimiento_directo,
       has_table_privilege('authenticated','public.movimiento_items','INSERT') as permite_insert_item_directo,
       has_table_privilege('authenticated','public.productos','DELETE') as permite_delete_producto;
