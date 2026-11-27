# Sprint 4 — Cambios y decisiones técnicas

## Historias concluidas a nivel de código

- **HU-06**: repositorio `MovimientoRepository.listar()` pagina los movimientos sin el límite antiguo de 200; el historial permite filtrar tipo y fechas y consultar precio, cantidades y origen.
- **HU-10**: `anular_movimiento()` revierte stock de forma atómica; `corregir_movimiento()` anula el registro anterior e inserta uno sustituto con `reemplaza_id`. Nunca se borran movimientos financieros. No se permite actualizar directamente estado desde un cliente de Supabase.
- **HU-11**: `ResumenFinanciero.calcular()` agrupa por día, semana y mes; calcula ventas, compras y gastos. Los reportes y la pantalla Inicio ya no usan montos de muestra. Se llama `saldo neto`, no beneficio, porque el esquema no tiene costo de ventas.
- **HU-14**: función server-side `supabase/functions/interpretar-comando` autentica el JWT, consulta los productos de ese usuario con RLS y, si se configuró `OPENAI_API_KEY` en Supabase, solicita extracción estructurada. Sin desplegar/configurar la función, **no hay IA externa** y se ejecuta el intérprete local.
- **HU-15**: se comprueban operación, producto, cantidad, precio y moneda; sin coincidencia o datos esenciales se informa error. La voz jamás guarda sin confirmación.
- **HU-16**: consultas del tipo "¿cuánto vendí hoy?", "¿qué stock tengo de arroz?" y "¿cuál es mi saldo?" usando registros del usuario en memoria y lectura con `flutter_tts`.
- **HU-17**: se elimina la tasa fija de emergencia. La única tasa sin conexión es la consultada previamente en ExchangeRate-API, guardada con su fecha; en confirmación se muestra desglosada en USD y BOB.
- **HU-18**: `flutter_map` + teselas OpenStreetMap; consulta Nominatim solo cuando se confirma un punto y guarda latitud/longitud/dirección en tabla `negocios`.

## Seguridad y transparencia

- El usuario de la app solamente posee la clave **pública** de Supabase.
- Los RPCs son `SECURITY DEFINER`, pero verifican `auth.uid()` y propiedad del negocio; no se conceden privilegios directos de modificación de movimientos.
- La anulación de compra se rechaza si la reversión deja stock negativo.
- Las peticiones a Nominatim envían coordenadas que el comerciante selecciona manualmente. Aplican las políticas públicas de Nominatim/OSM.
- La IA externa no es obligatoria para usar la app: sin clave en servidor el intérprete local da servicio básico. Esta distinción se comunica en la confirmación.

## Elementos no verificados por ejecución desde este entorno

`flutter pub get`, `flutter analyze`, `flutter test`, compilación Android, SQL aplicado en proyecto real, motor TTS real, geocodificación con internet y funcionamiento de Edge Functions. Se proporcionan pruebas y pasos de validación; no se afirma que pasaron.

## Requerimientos externos para ponerlo en marcha

1. Instalar Flutter SDK y resolver dependencias.
2. Crear `env.json` con URL y clave pública de Supabase.
3. Aplicar `migracion_04_sprint4.sql` al proyecto de datos.
4. Para IA externa, desplegar la Edge Function y configurar `OPENAI_API_KEY` como secreto.
5. Ejecutar tests en emulador/tablet y cerrar incidencias antes de distribuir el APK.
