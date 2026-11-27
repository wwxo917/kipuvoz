# KipuVoz — entrega técnica Sprint 4

Aplicación Flutter para comerciantes bolivianos: inventario, ventas/compras/gastos, consulta de historial, registro por voz, tipo de cambio USD→BOB, reportes reales y ubicación del negocio en un mapa. El **ZIP contiene el código fuente completo a partir del Sprint 3**, no un APK listo para instalar.

> **Antes de ejecutar:** la aplicación necesita un proyecto Supabase configurado, su URL y su clave **pública** en `env.json`, además de ejecutar la migración SQL del Sprint 4. La función de interpretación con **IA externa** requiere desplegar su función en Supabase y configurar una clave privada en el servidor. **No se incluye** una clave de IA ni el proyecto de datos del equipo.

## 1. Estado de las 18 historias

| Historia | Desarrollo incluido | Qué se debe verificar externamente |
| --- | --- | --- |
| HU-01 Bienvenida | Conservado Sprint 1 | Prueba de navegación |
| HU-02 Negocio | Conservado; incluye ubicación HU-18 | CRUD con RLS |
| HU-03 Inicio | Sustituidos datos de ejemplo por valores reales | Cargar movimientos |
| HU-04 Confirmación | Guarda origen `voz` y transcripción | RPC, stock, cancelación |
| HU-05 Registro manual | Conservado | Venta, compra, gasto |
| HU-06 Persistencia y consulta | Historial completo paginado, fechas y detalle | Supabase y filtros |
| HU-07 Pantallas | Conservadas; reportes reales | UI/Android |
| HU-08 Productos y stock | Conservado | Inventario y alertas |
| HU-09 Persistencia de inventario | Conservada | RLS y cierre de sesión |
| HU-10 Corregir/anular | SQL atómico, registro de corrección, edición en UI | **Migración 04** y reversión de stock |
| HU-11 Reportes reales | Día/semana/mes, barras y productos más vendidos | Datos de Supabase |
| HU-12 Auth y nube | Conservado | Restauración tras iniciar sesión |
| HU-13 Dictado | Conservado con manejo de errores | Permisos en dispositivo |
| HU-14 Servicio seguro IA | Edge Function con autenticación y clave solo en servidor | **Desplegar función y configurar clave** |
| HU-15 Interpretación | IA cuando esté activa; fallback local que no inventa datos | Pruebas con frases variadas |
| HU-16 Consultas habladas | Reconocimiento + preguntas sobre datos reales + TTS | Voz y TTS del dispositivo |
| HU-17 USD→BOB | API, fecha, tasa verificada o caché persistente identificada; sin tasa inventada | API en línea y sin conexión |
| HU-18 Mapa de tienda | OpenStreetMap, Nominatim y coordenadas en Supabase | **Migración 04** y red |

**Nota de honestidad técnica:** este paquete se ha preparado revisando el código, pero no se ha podido ejecutar `flutter analyze`, `flutter test` ni `flutter build` en este entorno porque aquí no está instalado Flutter SDK ni hay acceso a tu Supabase. Las pruebas de integración de la sección 6 y la ejecución del APK quedan a cargo del equipo, sin marcar resultados inventados.

## 2. Requisitos

- **Flutter estable compatible con Dart ≥3.6**, por ejemplo Flutter 3.27.4 o posterior.
- Android Studio / VS Code con SDK de Android, o navegador compatible para pruebas web.
- Un proyecto Supabase propio o acceso autorizado al proyecto del equipo.
- Internet para Supabase, tipo de cambio y mapa; un micrófono y motor TTS para las pruebas de voz.
- Para HU-14 IA externa: Supabase CLI y cuenta/proveedor de IA con una clave propia (puede requerir costos).

## 3. Instalación en Windows

1. Extraer este ZIP; abrir la carpeta **`kipuvoz-sprint-4`** en Android Studio o VS Code, donde está `pubspec.yaml`.
2. En la terminal:

   ```powershell
   flutter doctor
   flutter pub get
   flutter devices
   ```

3. Crear `env.json` copiando `env.example.json`:

   ```powershell
   Copy-Item env.example.json env.json
   ```

4. Editar `env.json` con **URL y clave pública** de Supabase:

   ```json
   {
     "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
     "SUPABASE_ANON_KEY": "TU-CLAVE-PUBLICA"
   }
   ```

   **Nunca** subir `env.json` al repositorio, ni colocar `service_role`, `sb_secret_` o una clave de IA en la app.

5. **Aplicar las migraciones en Supabase (sección 4)**; después ejecutar:

   ```powershell
   flutter run --dart-define-from-file=env.json
   # o, en Edge:
   flutter run -d edge --dart-define-from-file=env.json
   ```

6. Para compilar el APK después de las pruebas:

   ```powershell
   flutter build apk --release --dart-define-from-file=env.json
   ```

   Archivo esperado: `build/app/outputs/flutter-apk/app-release.apk`. El proyecto de Android heredado aún configura una firma **debug para el tipo release**, apta solo para demostración académica, no para distribuir en Google Play. Para una tienda de aplicaciones hay que preparar la firma de producción y revisar la identidad del paquete.

## 4. Supabase: pasos obligatorios

### Proyecto que ya ejecuta el Sprint 3

1. En **SQL Editor**, hacer un respaldo de la base de datos.
2. Ejecutar **solo** `supabase/migracion_04_sprint4.sql` en tu proyecto existente. **NO** volver a ejecutar `schema.sql` ni eliminar tablas.
3. Ejecutar `supabase/verificar_sprint4.sql`. Confirmar las seis columnas nuevas, las funciones RPC y permisos de actualización/borrado directos en `false`.
4. En Table Editor verificar que en `negocios` aparezcan `latitud`, `longitud` y `direccion`; en `movimientos`, `reemplaza_id`, `anulado_en` y `motivo_anulacion`.

### Proyecto Supabase completamente nuevo

Ejecutar en orden: `supabase/schema.sql`, `supabase/migracion_02_categoria.sql`, `supabase/migracion_04_sprint4.sql`. El esquema base ya incorpora la seguridad de la migración 03. Activar Auth por correo, y comprobar RLS en las cuatro tablas.

**Anulación y corrección:** el cliente no tiene permiso para actualizar o borrar directamente movimientos. Las funciones SQL `anular_movimiento` y `corregir_movimiento` realizan la operación validando `auth.uid()` y el negocio. Una corrección deja el movimiento original **anulado**, crea uno sustituto y enlaza ambos con `reemplaza_id`; si falla el stock, la transacción se revierte completa. No se borran filas originales.

**Limitación por integridad:** una compra no se puede anular si sus unidades ya fueron vendidas y el stock actual no alcanza para revertirla. La aplicación muestra el error para evitar stock negativo.

### Activar la IA segura (HU-14 y HU-15)

La app funciona **sin la IA externa** mediante un intérprete local de frases simples. Para usar interpretación por IA real, desde tu equipo:

1. Instalar **Supabase CLI** e iniciar sesión: `supabase login`.
2. Vincular tu proyecto: `supabase link --project-ref TU-PROJECT-REF`.
3. Configurar **en Supabase**, NO en Flutter, el secreto `OPENAI_API_KEY` desde el panel de funciones o la CLI (`supabase secrets set OPENAI_API_KEY=...`). No lo copies a un chat ni lo subas a GitHub.
4. Desplegar la función con `supabase functions deploy interpretar-comando --no-verify-jwt`. La función valida el token por `auth.getUser` antes de consultar el inventario con RLS.
5. La función solicita al proveedor un JSON con tipo, producto del inventario del usuario, cantidad, precio y moneda. Flutter vuelve a validar el resultado y **siempre exige confirmación** antes de guardar.
6. Si no se configura la clave o falla la función, el cliente muestra una advertencia y usa un intérprete local limitado, sin fingir que se utilizó una IA.

**Costos:** usar IA externa puede tener tarifas propias del proveedor. `supabase/functions/interpretar-comando/index.ts` usa el endpoint de Chat Completions; si cambias de proveedor, debes adaptar esa función únicamente en el servidor.

## 5. APIs e integraciones demostrables

1. **Reconocimiento de voz del dispositivo:** `speech_to_text` con permisos de micrófono. Es una integración nativa, **no** una API HTTP pública.
2. **ExchangeRate-API:** consulta `https://open.er-api.com/v6/latest/USD` para USD→BOB. Guarda la última tasa consultada y su fecha; si falla la red, marca la tasa **guardada**. Si nunca hubo una tasa verificada, rechaza convertir: no utiliza un valor inventado.
3. **OpenStreetMap + Nominatim:** mapa interactivo con tiles de OSM y consulta de geocodificación inversa `https://nominatim.openstreetmap.org/reverse` una sola vez al confirmar un marcador. La dirección es orientativa; las coordenadas se guardan en Supabase incluso cuando Nominatim no responde.
4. **Supabase Auth/PostgREST/RPC y Edge Function**: autenticación, datos del negocio con RLS, operaciones atómicas y procesamiento opcional de IA.
5. **Respuesta hablada:** `flutter_tts` convierte en audio respuestas calculadas localmente a partir de las consultas de Supabase.

**Uso responsable:** la demostración de mapas debe ser ligera. Las APIs públicas de OSM/Nominatim tienen políticas de atribución, identificación y límites; no usarlas para consultas masivas ni precarga. En una versión comercial grande sería recomendable contratar un proveedor de tiles/geocodificación con SLA.

## 6. Demostración paso a paso (pruebas de integración pendientes)

1. Crear cuenta e iniciar sesión; crear negocio y abrir **Seleccionar en el mapa**. Marcar la tienda y guardar. Comprobar coordenadas en la tabla `negocios`.
2. Registrar productos Aceite (precio 18 Bs, stock 20) y Azúcar (precio 6 Bs, stock 12).
3. Dictar “Vendí 5 aceite a 18”; revisar la confirmación y guardar. Verificar total **Bs 90**, stock Aceite **15**, origen `voz` y `texto_original` en `movimientos`.
4. Entrar al historial, filtrar por fechas y abrir el detalle. **Corregir** a 3 unidades: el original permanece anulado y el sustituto activo; stock Aceite debe quedar **17** (suponiendo que no hubo otros cambios).
5. **Anular** el movimiento corregido: Aceite regresa a **20**. Verificar que no aparecen las ventas anuladas en los totales de reportes.
6. Registrar compra por Bs 20 y gasto de Bs 5. Revisar que reportes de día/semana/mes muestren ventas/compras/gastos y saldo reales.
7. En Inicio, pulsar **Consultar mis ventas por voz**, preguntar “¿Cuánto vendí hoy?” y luego “¿Cuánto stock tengo de aceite?”. Escuchar la respuesta con TTS; probar alternativa escrita.
8. Dictar “Compré 2 azúcar a 3 dólares”: consultar tasa; revisar fecha, importe USD y total Bs antes de guardar. Desactivar conexión después de haber consultado previamente una tasa y verificar aviso “tasa guardada”. Sin tasa guardada, comprobar que se bloquea la conversión.
9. Si desplegaste HU-14 con una clave de IA, probar frases variadas y confirmar el registro. Sin función activa, verificar mensaje de modo local.
10. Con un segundo usuario distinto verificar que las operaciones, productos y coordenadas de otro negocio **no son visibles** gracias a RLS.

Guía más exhaustiva en `docs/SPRINT4_PLAN_PRUEBAS.md`. No hay conexión real a tu Supabase ni APK validado desde este entorno; los resultados deben registrarse por el equipo.

## 7. Estructura importante

```text
lib/
  data/models/                negocio, producto, movimiento con detalle
  data/repositories/          lecturas y RPCs de Supabase
  data/analytics/             resumen financiero calculado
  data/services/              voz, consulta hablada, divisas, cliente IA
  features/business/          selección de ubicación en mapa
  features/history/           filtros, detalle, correcciones, anulaciones
  features/reports/           gráficos y totales reales
  features/voice/             consulta por voz y TTS
  features/confirmation/      validación previa y auditoría de origen
  providers/                  Riverpod
supabase/
  migracion_04_sprint4.sql    esquema y RPCs del Sprint 4
  verificar_sprint4.sql       comprobaciones de instalación
  functions/interpretar-comando/index.ts   IA protegida en Edge Functions
  config.toml                 verificación manual de JWT en la función
test/                       pruebas existentes y nuevas del Sprint 4
docs/                       originales de Sprints 1-3 y guías finales
```

## 8. Verificación antes de la entrega académica

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=env.json
```

Si `flutter pub get` actualiza `pubspec.lock`, incluir el lockfile actualizado en Git. No publicar contraseñas, claves privadas, APK con datos de usuario ni un `env.json` real.

> **Proyecto académico UPDS.** Mantiene la arquitectura e informes del Sprint 2/3; añade funcionalidades del Sprint 4 sin borrar la base de datos anterior. 
