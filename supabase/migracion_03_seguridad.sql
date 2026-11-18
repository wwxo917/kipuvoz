-- KipuVoz / Security correction for databases already created from the original package.
-- Non-destructive: does not drop tables or delete data.
-- Run as a Supabase SQL Editor administrator AFTER schema.sql.
begin;

create or replace function public.registrar_movimiento(
  p_tipo            text,
  p_items           jsonb   default '[]'::jsonb,
  p_concepto        text    default null,
  p_total           numeric default null,
  p_origen          text    default 'manual',
  p_texto_original  text    default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_negocio  uuid := public.mi_negocio_id();
  v_mov      uuid;
  v_total    numeric(12,2) := 0;
  v_item     jsonb;
  v_prod     uuid;
  v_cant     numeric;
  v_precio   numeric;
  v_nombre   text;
  v_stock    numeric;
begin
  if auth.uid() is null then
    raise exception 'Se requiere iniciar sesión' using errcode = '28000';
  end if;
  if v_negocio is null then
    raise exception 'Primero configura tu negocio';
  end if;
  if p_tipo is null or p_tipo not in ('venta', 'compra', 'gasto') then
    raise exception 'Tipo de movimiento inválido';
  end if;

  if p_tipo = 'gasto' then
    if p_total is null or p_total <= 0 or p_total > 9999999999.99 then
      raise exception 'El monto del gasto debe ser mayor a 0';
    end if;
    v_total := p_total;
  else
    if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
      raise exception 'Agrega al menos un producto';
    end if;
    -- El total se calcula antes de insertar (los movimientos no admiten UPDATE del total)
    select coalesce(sum((e ->> 'cantidad')::numeric * (e ->> 'precio_unitario')::numeric), 0)
      into v_total
      from jsonb_array_elements(p_items) e;
  end if;

  insert into public.movimientos (negocio_id, tipo, concepto, total, origen, texto_original)
  values (v_negocio, p_tipo, p_concepto, v_total, p_origen, p_texto_original)
  returning id into v_mov;

  if p_tipo <> 'gasto' then
    for v_item in select * from jsonb_array_elements(p_items) loop
      v_prod   := (v_item ->> 'producto_id')::uuid;
      v_cant   := (v_item ->> 'cantidad')::numeric;
      v_precio := (v_item ->> 'precio_unitario')::numeric;
      if v_prod is null or v_cant is null or v_precio is null
         or v_cant <= 0 or v_precio <= 0 then
        raise exception 'La cantidad y el precio deben ser mayores a 0';
      end if;

      select nombre, stock into v_nombre, v_stock
        from public.productos
       where id = v_prod and negocio_id = v_negocio and activo
         for update;
      if not found then
        raise exception 'Producto no disponible';
      end if;
      if p_tipo = 'venta' and v_stock < v_cant then
        raise exception 'Stock insuficiente de %', v_nombre;
      end if;

      insert into public.movimiento_items (movimiento_id, producto_id, cantidad, precio_unitario)
      values (v_mov, v_prod, v_cant, v_precio);

      update public.productos
         set stock = case when p_tipo = 'venta' then stock - v_cant else stock + v_cant end
       where id = v_prod;
    end loop;
  end if;

  return v_mov;
end;
$$;

-- A logged-in client can read its rows, but cannot bypass the stock transaction.
grant select, insert, update on public.negocios, public.productos to authenticated;
grant select on public.movimientos, public.movimiento_items to authenticated;
drop policy if exists movimientos_insert on public.movimientos;
drop policy if exists items_insert on public.movimiento_items;
revoke insert on public.movimientos, public.movimiento_items from public, anon, authenticated;
-- Direct DELETE remains prohibited.
revoke delete on public.negocios, public.productos, public.movimientos, public.movimiento_items from public, anon, authenticated;
revoke execute on function public.registrar_movimiento(text, jsonb, text, numeric, text, text) from public, anon;
grant execute on function public.registrar_movimiento(text, jsonb, text, numeric, text, text) to authenticated;
commit;
