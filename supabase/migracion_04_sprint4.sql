-- KipuVoz Sprint 4. Ejecutar UNA SOLA VEZ en SQL Editor después de Sprint 2.
-- Conserva todos los movimientos: la corrección anula el original y crea uno nuevo.
-- Hacer respaldo antes de aplicar en un proyecto con datos.
begin;

alter table public.negocios add column if not exists latitud numeric(9,6);
alter table public.negocios add column if not exists longitud numeric(9,6);
alter table public.negocios add column if not exists direccion text;
-- Limitaciones geográficas (si se repite la migración, no duplicar constraints).
do $$ begin
  if not exists(select 1 from pg_constraint where conname='negocios_latitud_rango') then
    alter table public.negocios add constraint negocios_latitud_rango
      check (latitud is null or latitud between -90 and 90);
  end if;
  if not exists(select 1 from pg_constraint where conname='negocios_longitud_rango') then
    alter table public.negocios add constraint negocios_longitud_rango
      check (longitud is null or longitud between -180 and 180);
  end if;
end $$;

alter table public.movimientos add column if not exists anulado_en timestamptz;
alter table public.movimientos add column if not exists motivo_anulacion text;
alter table public.movimientos add column if not exists reemplaza_id uuid references public.movimientos(id) on delete restrict;
create unique index if not exists movimientos_reemplaza_unico
  on public.movimientos(reemplaza_id) where reemplaza_id is not null;

-- Anulación atómica. Reversión exacta de stock; jamás eliminar filas financieras.
create or replace function public.anular_movimiento(
  p_movimiento_id uuid,
  p_motivo text default 'Anulación solicitada por el comerciante'
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_negocio uuid := public.mi_negocio_id();
  v_mov public.movimientos%rowtype;
  v_item record;
  v_stock numeric;
begin
  if auth.uid() is null or v_negocio is null then
    raise exception 'Debes iniciar sesión y configurar tu negocio';
  end if;
  select * into v_mov from public.movimientos
  where id = p_movimiento_id and negocio_id = v_negocio for update;
  if not found then raise exception 'Movimiento no encontrado'; end if;
  if v_mov.estado <> 'activo' then raise exception 'El movimiento ya está anulado'; end if;

  if v_mov.tipo in ('venta','compra') then
    for v_item in
      select i.producto_id, sum(i.cantidad) as cantidad
      from public.movimiento_items i
      where i.movimiento_id = p_movimiento_id
      group by i.producto_id order by i.producto_id
    loop
      select stock into v_stock from public.productos
      where id = v_item.producto_id and negocio_id = v_negocio for update;
      if not found then raise exception 'Producto del movimiento no encontrado'; end if;
      if v_mov.tipo = 'compra' and v_stock < v_item.cantidad then
        raise exception 'No se puede anular esta compra: el stock actual es insuficiente';
      end if;
      update public.productos
      set stock = case when v_mov.tipo = 'venta' then stock + v_item.cantidad
                       else stock - v_item.cantidad end
      where id = v_item.producto_id;
    end loop;
  end if;

  update public.movimientos set estado = 'anulado', anulado_en = now(),
    motivo_anulacion = nullif(btrim(coalesce(p_motivo, '')), '')
    where id = v_mov.id;
  return v_mov.id;
end;
$$;

-- Corrección sin borrar registros: anular movimiento, registrar sustituto y vincularlos.
-- Si cualquier comprobación falla, PostgreSQL revierte TODA la operación.
create or replace function public.corregir_movimiento(
  p_movimiento_id uuid,
  p_items jsonb default '[]'::jsonb,
  p_concepto text default null,
  p_total numeric default null,
  p_motivo text default 'Corrección del registro'
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_negocio uuid := public.mi_negocio_id();
  v_original public.movimientos%rowtype;
  v_nuevo uuid;
begin
  if auth.uid() is null or v_negocio is null then raise exception 'Debes iniciar sesión'; end if;
  select * into v_original from public.movimientos
    where id = p_movimiento_id and negocio_id = v_negocio for update;
  if not found then raise exception 'Movimiento no encontrado'; end if;
  if v_original.estado <> 'activo' then raise exception 'El movimiento ya está anulado'; end if;

  perform public.anular_movimiento(v_original.id, coalesce(p_motivo, 'Corrección'));
  if v_original.tipo = 'gasto' then
    v_nuevo := public.registrar_movimiento('gasto', '[]'::jsonb,
                    p_concepto, p_total, 'manual', null);
  else
    v_nuevo := public.registrar_movimiento(v_original.tipo, p_items,
                    null, null, v_original.origen, v_original.texto_original);
  end if;
  update public.movimientos set reemplaza_id = v_original.id where id = v_nuevo;
  return v_nuevo;
end;
$$;

-- Elimina bypass de actualizaciones directas al estado de movimientos del Sprint 2.
revoke update on public.movimientos from authenticated;
revoke update(concepto, estado) on public.movimientos from authenticated;
-- Acceso autorizado a las nuevas funciones para usuarios autenticados solamente.
revoke execute on function public.anular_movimiento(uuid, text) from public, anon;
revoke execute on function public.corregir_movimiento(uuid, jsonb, text, numeric, text) from public, anon;
grant execute on function public.anular_movimiento(uuid, text) to authenticated;
grant execute on function public.corregir_movimiento(uuid, jsonb, text, numeric, text) to authenticated;

commit;
