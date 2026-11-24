-- =====================================================================
-- KipuVoz · Sprint 2 · Base de datos en Supabase (PostgreSQL)
-- Ejecutar en: Supabase > SQL Editor
-- Regla de diseño: nunca se borran registros (sin DELETE). Los productos
-- se archivan (activo = false) y los movimientos se anulan (estado).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABLAS
-- ---------------------------------------------------------------------
create table public.negocios (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null unique default auth.uid()
                  references auth.users (id) on delete restrict,
  nombre          text not null check (char_length(btrim(nombre)) between 1 and 40),
  tipo            text not null default 'tienda_barrio'
                  check (tipo in ('tienda_barrio', 'mercado', 'comida', 'otro')),
  moneda          text not null default 'Bs',
  creado_en       timestamptz not null default now(),
  actualizado_en  timestamptz not null default now()
);

-- Devuelve el negocio del usuario autenticado (se usa en valores por defecto y políticas)
create function public.mi_negocio_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select id from public.negocios where user_id = auth.uid()
$$;

create table public.productos (
  id              uuid primary key default gen_random_uuid(),
  negocio_id      uuid not null default public.mi_negocio_id()
                  references public.negocios (id) on delete restrict,
  nombre          text not null check (char_length(btrim(nombre)) between 1 and 60),
  unidad          text not null default 'unidad',
  precio_venta    numeric(12,2) not null check (precio_venta >= 0),
  stock           numeric(12,2) not null default 0 check (stock >= 0),
  stock_minimo    numeric(12,2) not null default 0 check (stock_minimo >= 0),
  activo          boolean not null default true,
  creado_en       timestamptz not null default now(),
  actualizado_en  timestamptz not null default now()
);
-- No permite dos productos activos con el mismo nombre en un negocio
create unique index productos_nombre_activo_uq
  on public.productos (negocio_id, lower(btrim(nombre))) where activo;

create table public.movimientos (
  id              uuid primary key default gen_random_uuid(),
  negocio_id      uuid not null default public.mi_negocio_id()
                  references public.negocios (id) on delete restrict,
  tipo            text not null check (tipo in ('venta', 'compra', 'gasto')),
  concepto        text,
  total           numeric(12,2) not null default 0 check (total >= 0),
  estado          text not null default 'activo' check (estado in ('activo', 'anulado')),
  origen          text not null default 'manual' check (origen in ('manual', 'voz')),
  texto_original  text,
  fecha           timestamptz not null default now(),
  creado_en       timestamptz not null default now()
);
create index movimientos_negocio_fecha_idx on public.movimientos (negocio_id, fecha desc);

create table public.movimiento_items (
  id               uuid primary key default gen_random_uuid(),
  movimiento_id    uuid not null references public.movimientos (id) on delete restrict,
  producto_id      uuid not null references public.productos (id) on delete restrict,
  cantidad         numeric(12,2) not null check (cantidad > 0),
  precio_unitario  numeric(12,2) not null check (precio_unitario >= 0),
  subtotal         numeric(12,2) generated always as (cantidad * precio_unitario) stored
);
create index movimiento_items_mov_idx on public.movimiento_items (movimiento_id);

-- ---------------------------------------------------------------------
-- 2. FECHA DE ACTUALIZACIÓN AUTOMÁTICA
-- ---------------------------------------------------------------------
create function public.set_actualizado_en()
returns trigger
language plpgsql
as $$
begin
  new.actualizado_en := now();
  return new;
end;
$$;

create trigger negocios_actualizado before update on public.negocios
  for each row execute function public.set_actualizado_en();
create trigger productos_actualizado before update on public.productos
  for each row execute function public.set_actualizado_en();

-- ---------------------------------------------------------------------
-- 3. REGISTRO DE MOVIMIENTOS (una sola transacción: movimiento + ítems + stock)
-- ---------------------------------------------------------------------
create function public.registrar_movimiento(
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

-- ---------------------------------------------------------------------
-- 4. SEGURIDAD: RLS (cada usuario solo ve y modifica lo de su negocio)
-- ---------------------------------------------------------------------
alter table public.negocios         enable row level security;
alter table public.productos        enable row level security;
alter table public.movimientos      enable row level security;
alter table public.movimiento_items enable row level security;

create policy negocios_select on public.negocios for select to authenticated
  using (user_id = auth.uid());
create policy negocios_insert on public.negocios for insert to authenticated
  with check (user_id = auth.uid());
create policy negocios_update on public.negocios for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy productos_select on public.productos for select to authenticated
  using (negocio_id = public.mi_negocio_id());
create policy productos_insert on public.productos for insert to authenticated
  with check (negocio_id = public.mi_negocio_id());
create policy productos_update on public.productos for update to authenticated
  using (negocio_id = public.mi_negocio_id()) with check (negocio_id = public.mi_negocio_id());

create policy movimientos_select on public.movimientos for select to authenticated
  using (negocio_id = public.mi_negocio_id());
create policy movimientos_update on public.movimientos for update to authenticated
  using (negocio_id = public.mi_negocio_id()) with check (negocio_id = public.mi_negocio_id());

create policy items_select on public.movimiento_items for select to authenticated
  using (exists (select 1 from public.movimientos m
                  where m.id = movimiento_id and m.negocio_id = public.mi_negocio_id()));

-- Sin políticas de DELETE: además se retira el permiso a nivel de tabla
revoke all on public.negocios, public.productos, public.movimientos, public.movimiento_items from anon;
-- Explicit CRUD privileges: role setup is not dependent on default grants.
grant select, insert, update on public.negocios, public.productos to authenticated;
grant select on public.movimientos, public.movimiento_items to authenticated;
revoke delete on public.negocios, public.productos, public.movimientos, public.movimiento_items from public, anon, authenticated;
-- All inserts of financial movements must pass the validated transaction/RPC.
-- The function runs with the schema owner's rights and checks auth.uid() and ownership.
revoke insert on public.movimientos, public.movimiento_items from public, anon, authenticated;
-- Los movimientos solo permiten cambiar el concepto y el estado (anular)
revoke update on public.movimientos from authenticated;
grant update (concepto, estado) on public.movimientos to authenticated;
-- Los ítems nunca se modifican
revoke update on public.movimiento_items from authenticated;

revoke execute on function public.registrar_movimiento(text, jsonb, text, numeric, text, text) from public, anon;
grant  execute on function public.registrar_movimiento(text, jsonb, text, numeric, text, text) to authenticated;
revoke execute on function public.mi_negocio_id() from public, anon;
grant  execute on function public.mi_negocio_id() to authenticated;
