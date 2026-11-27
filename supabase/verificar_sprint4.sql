-- Comprobación visual de la migración 04. Ejecutar en Supabase SQL Editor.
select table_name, column_name from information_schema.columns
 where table_schema = 'public'
 and ((table_name='negocios' and column_name in ('latitud','longitud','direccion'))
   or (table_name='movimientos' and column_name in ('reemplaza_id','anulado_en','motivo_anulacion')))
 order by table_name,column_name;

select proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
 where n.nspname='public' and proname in ('anular_movimiento','corregir_movimiento','registrar_movimiento');

-- Los usuarios autenticados NO pueden actualizar ni borrar movimientos directamente.
select has_table_privilege('authenticated', 'public.movimientos', 'UPDATE') as no_update_directo,
       has_table_privilege('authenticated', 'public.movimientos', 'DELETE') as no_delete_directo;
-- Ambas expresiones deben devolver false.
