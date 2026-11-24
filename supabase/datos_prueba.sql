-- Datos de prueba · se ejecutan con el rol postgres (SQL Editor), después de
-- registrar en la app el usuario de prueba prueba@kipuvoz.com
do $$
declare
  v_user  uuid;
  v_neg   uuid;
  v_arroz uuid; v_azucar uuid; v_aceite uuid;
  v_mov   uuid;
begin
  select id into v_user from auth.users where email = 'prueba@kipuvoz.com';
  if v_user is null then
    raise exception 'Primero registra el usuario prueba@kipuvoz.com en la app';
  end if;

  insert into public.negocios (user_id, nombre, tipo)
  values (v_user, 'Tienda Doña Rosa', 'tienda_barrio')
  returning id into v_neg;

  insert into public.productos (negocio_id, nombre, unidad, precio_venta, stock, stock_minimo) values
    (v_neg, 'Arroz',  'bolsa',   40, 12, 5),
    (v_neg, 'Azúcar', 'kg',       8,  3, 5),
    (v_neg, 'Aceite', 'unidad',  18, 25, 5),
    (v_neg, 'Fideo',  'paquete',  6, 40, 10);

  select id into v_arroz  from public.productos where negocio_id = v_neg and nombre = 'Arroz';
  select id into v_azucar from public.productos where negocio_id = v_neg and nombre = 'Azúcar';
  select id into v_aceite from public.productos where negocio_id = v_neg and nombre = 'Aceite';

  insert into public.movimientos (negocio_id, tipo, total, origen)
  values (v_neg, 'venta', 236, 'manual') returning id into v_mov;
  insert into public.movimiento_items (movimiento_id, producto_id, cantidad, precio_unitario) values
    (v_mov, v_arroz, 5, 40), (v_mov, v_aceite, 2, 18);

  insert into public.movimientos (negocio_id, tipo, total, origen)
  values (v_neg, 'compra', 120, 'manual') returning id into v_mov;
  insert into public.movimiento_items (movimiento_id, producto_id, cantidad, precio_unitario)
  values (v_mov, v_azucar, 20, 6);

  insert into public.movimientos (negocio_id, tipo, concepto, total, origen)
  values (v_neg, 'gasto', 'Transporte', 15, 'manual');

  -- The items above are seeded directly as an administrator. Reconcile stock
  -- so the test database represents the resulting inventory (unlike the source seed).
  update public.productos set stock = stock - 5 where id = v_arroz;
  update public.productos set stock = stock - 2 where id = v_aceite;
  update public.productos set stock = stock + 20 where id = v_azucar;
end $$;
