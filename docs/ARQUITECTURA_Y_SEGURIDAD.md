# arquitectura y seguridad de KipuVoz - Sprint 2

## Objetivo y alcance

Los usuarios son comerciantes que necesitan registrar sus negocios, productos y movimientos. En el Sprint 1 se prepararon pantallas y navegacion. El Sprint 2 incorpora persistencia en Supabase y las historias HU-02, HU-05, HU-08, HU-09 y HU-12. El resumen con ganancias reales, los reportes y el procesamiento de voz se difieren a los sprints siguientes.

## Capas

```text
Pantallas Flutter (features/) / Material 3
               |
Navegacion protegida (go_router) + Estado (Riverpod/providers/)
               |
Repositorios (data/repositories/)
               |
Cliente de Supabase / Auth con JWT / RPC
               |
PostgreSQL: negocios -> productos, movimientos -> movimiento_items
             + Politicas RLS por auth.uid()
```

- `lib/main.dart` valida variables y arranca Supabase y el ProviderScope.
- `lib/core/routes/app_router.dart` redirige a bienvenida, configuración o inicio segun la sesión y el negocio.
- `lib/providers/` conserva y refresca el estado. Se verifican generacion y usuario al completar solicitudes asincronas para no publicar datos viejos tras un cambio de cuenta.
- `lib/data/repositories/` aisla el CRUD de la interfaz; las pantallas no realizan consultas SQL directas.
- `lib/core/errors/` transforma errores tecnicos en textos comprensibles.

## Modelo de datos

- `auth.users`: usuarios (gestionados por Supabase).
- `negocios`: cuenta del negocio, identificada por `user_id` unico; nombre, tipo y moneda.
- `productos`: negocio, nombre, unidad, precio de venta, stock, mínimo, categoría y `activo`.
- `movimientos`: negocio, tipo venta/compra/gasto, concepto, total, estado, origen y fecha.
- `movimiento_items`: líneas de venta/compra con producto, cantidad, precio y subtotal.

Relaciones: usuario 1:1 negocio; negocio 1:N productos y movimientos; movimiento 1:N items para ventas/compras; producto 1:N items. Gasto no exige items.

## Regla "no se borra"

`productos.activo=false` archiva sin perder el historial. `movimientos.estado='anulado'` está previsto para el Sprint 3; NO se habilita aún la anulacion de interfaz en Sprint 2. No se otorga permiso `DELETE` a usuarios autenticados y cada clave externa tiene `ON DELETE RESTRICT`.

## Registro atomico de stock

1. El usuario llena un formulario manual de venta, compra o gasto.
2. `MovimientoRepository.registrar()` llama a `public.registrar_movimiento` mediante RPC.
3. La funcion identifica el negocio desde `auth.uid()`, valida cantidades/precios y verifica que los productos sean activos y pertenezcan al negocio.
4. Bloquea filas relevantes (`FOR UPDATE`), inserta un movimiento y sus items, y resta o suma las unidades segun el tipo.
5. Si falla una validación (stock insuficiente, producto ajeno, etc.), PostgreSQL revierte toda la transacción.
6. Se refresca Historial y luego Inventario mediante los providers.

## Controles de acceso

- RLS habilitado en las cuatro tablas; cada consulta solo devuelve el negocio del usuario autenticado.
- Los usuarios no pueden crear movimientos/items directamente: deben ejecutar la funcion transaccional. La funcion `SECURITY DEFINER` posee privilegios elevados, pero valida explicitamente la sesión y la propiedad del producto; por eso está restringida a usuarios `authenticated`.
- La app solo usa clave pública, nunca service_role o una clave secreta.
- Las cuentas deben probarse con usuarios A y B diferentes, verificando que no se mezclen inventarios.

## Dependencias fijadas

Flutter SDK >=3.27 (Dart >=3.6), go_router 14.8.1, flutter_riverpod 2.6.1, supabase_flutter 2.10.2 y flutter_lints 5.x. `pubspec.lock` se crea al ejecutar `flutter pub get` en tu entorno; se recomienda conservarlo en un repositorio para builds reproducibles una vez comprobada la compilacion.

## límites deliberados del Sprint 2

- Inicio y Reportes aún muestran un resumen de ejemplo identificado como tal.
- El boton de microfono va a una maqueta; no hay captura de audio ni IA integrada.
- La lectura de historial es básica; los filtros avanzados y anulaciones pertenecen al Sprint 3.
- No hay cache local sin conexion; se muestra un error y opción de reintentar.
