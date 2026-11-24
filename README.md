# KipuVoz - Proyecto integral del Sprint 2

KipuVoz es una aplicación Flutter de apoyo a comerciantes de Bolivia. Permite crear una cuenta, configurar el negocio, administrar un inventario y registrar ventas, compras y gastos en Supabase. Fue desarrollado como proyecto académico de aplicaciones móviles I (UPDS), con Scrum.

> Alcance: Sprint 2. Los paneles de resumen de Inicio y Reportes conservan datos demostrativos; el microfono y la confirmacion por voz son una maqueta. **No equivalen a la IA final prevista para Sprint 4.**

## 1. Abrirlo en Windows (Android Studio)

**Requisitos**: Android Studio con plugins Flutter y Dart, Flutter SDK 3.27 o superior, Android SDK, emulador Android con internet, Git y cuenta de Supabase. Los comandos deben ejecutarse en la carpeta que contiene `pubspec.yaml`.

1. Descomprime este ZIP y abre la carpeta `kipuvoz` en Android Studio.
2. Haz doble clic en **`PREPARAR_WINDOWS.bat`**. El script ejecuta `flutter create --project-name kipuvoz --platforms=android,web .` (genera las carpetas Android y Web propias de TU versión de Flutter) y `flutter pub get`, sin reemplazar la carpeta `lib`.
3. Si aún no existe, el script crea `env.json` desde `env.example.json`. **Edita** `env.json` y coloca la URL del proyecto y su clave **pública** de Supabase. Nunca uses una `service_role` o `sb_secret`.
4. Prepara las tablas y la autenticación en Supabase segun la seccion 2.
5. Enciende un emulador desde **Tools > Device Manager** y ejecuta `EJECUTAR_ANDROID.bat`, o en la terminal:

```bash
flutter run --dart-define-from-file=env.json
```

Para ejecutar en Microsoft Edge:

```bash
flutter run -d edge --dart-define-from-file=env.json
```

también puedes editar **Run > Edit Configurations > Additional run args** en Android Studio y agregar `--dart-define-from-file=env.json` para usar el boton Run.

En macOS/Linux, usa `sh preparar_unix.sh`; luego inicia con el mismo comando `flutter run`.

**Por que se generan las carpetas de plataforma**: el ZIP original de Sprint 2 contenia solo el código `lib`, sin `pubspec.yaml` ni los proyectos Android/Web. Este paquete incorpora el archivo de dependencias, scripts y pruebas; `flutter create` genera el código nativo oficial compatible con la versión instalada en tu equipo. No hace falta reutilizar Sprint 1.

## 2. Configurar Supabase

1. Ve a https://supabase.com, crea un proyecto nuevo (puedes elegir la region de Sao Paulo) y abre **SQL Editor**.
2. **Proyecto NUEVO**: ejecuta `supabase/schema.sql` y despues `supabase/migracion_02_categoria.sql` (en ese orden). No es necesario ejecutar la migracion 03, porque el esquema nuevo ya contiene las mejoras de seguridad.
3. **Proyecto EXISTENTE basado en el esquema antiguo de Sprint 2**: **NO repitas `schema.sql` ni borres tablas**. Ejecuta `supabase/migracion_02_categoria.sql` si falta la categoría, y despues `supabase/migracion_03_seguridad.sql` para aplicar la correccion de permisos, preservando tus registros. Antes de migrar una base con datos reales, crea un respaldo.
4. En **Table Editor** comprueba las tablas `negocios`, `productos`, `movimientos`, `movimiento_items` y sus etiquetas **RLS enabled**.
5. En **Authentication > Providers > Email**, revisa que el proveedor Email este habilitado. Puedes desactivar la confirmacion de correo solo para pruebas o confirmar la cuenta por email si está activada.
6. En **Project Settings > API** (o **API Keys**) copia `Project URL` y la **publishable key** (o anon key) en `env.json`:

```json
{
  "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
  "SUPABASE_ANON_KEY": "TU-CLAVE-PUBLICA"
}
```

7. En SQL Editor ejecuta **`supabase/verificar_instalacion.sql`**: las 4 tablas deben tener RLS activo y las tres comprobaciones de permisos finales deben dar `false` (no INSERT directo a movimientos/items ni DELETE de productos).

**Datos de prueba opcionales**: `supabase/datos_prueba.sql` necesita que antes exista en Auth el usuario `prueba@kipuvoz.com`, sin negocio ya creado. Genera una tienda y tres movimientos; las existencias resultantes son Arroz 7, Azucar 23, Aceite 23, Fideo 40. No cargues datos de prueba sobre un negocio existente.

## 3. Ejecutar verificaciones en tu computadora

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=env.json
```

Para un APK de distribucion, verifica que `android/app/src/main/AndroidManifest.xml` incluya `<uses-permission android:name="android.permission.INTERNET"/>` antes de `<application>`. Despues ejecuta:

```bash
flutter build apk --dart-define-from-file=env.json
```

La compilacion no se ejecuta aqui porque este entorno de preparación no tiene Flutter SDK ni acceso a la base Supabase. Los tests, el analisis y la demostracion real deben comprobarse en Android Studio; **no están marcados artificialmente como aprobados**.

## 4. Flujo funcional del Sprint 2

1. Bienvenida > Crear cuenta > Configurar negocio (nombre y tipo, moneda Bs).
2. Inventario > agregar producto con stock, stock mínimo y categoría.
3. Tocar un producto para editar; Archivar conserva el registro, pero lo oculta del listado.
4. Inicio > Registrar sin voz: venta, compra o gasto. Una venta resta existencias y una compra las suma.
5. Historial consulta movimientos almacenados en la nube.
6. Cerrar sesión e iniciar de nuevo: deben recuperarse el negocio, los productos y el historial.
7. Con otra cuenta, debe mantenerse el aislamiento de datos (RLS).

## 5. Estructura principal

```text
kipuvoz/
  lib/
    main.dart                Arranque y Supabase
    core/                   Tema, rutas, validación, errores y utilidades
    data/models/            Negocio, Producto, Movimiento
    data/repositories/      Acceso a datos y autenticación
    providers/              Estado reactivo con Riverpod
    features/               Pantallas de la aplicación
    shared/                 Widgets reutilizables
  supabase/                 Esquema, migraciones y comprobaciones SQL
  test/                     Pruebas de formato, validación, modelo y UI básica
  docs/                     documentación para el equipo y el docente
  pubspec.yaml              Dependencias y versión del proyecto
  env.example.json          Plantilla de configuración
  PREPARAR_WINDOWS.bat       preparación automatizada en Windows
```

## 6. Historial de cambios respecto del paquete recibido

- Se agregaron `pubspec.yaml`, `.gitignore`, pruebas de Flutter, herramientas de preparación, documentación y un flujo CI opcional.
- El código ya existente de las pantallas, modelos, temas y repositorios se conserva como base.
- Se mejoro el tratamiento de errores de red sin importar `dart:io` directamente (compatibilidad con Web).
- Los providers descartan respuestas asincronas que pertenezcan a una sesión anterior.
- La funcion SQL `registrar_movimiento` valida los valores, confirma el producto y el negocio, y actualiza el stock en una transacción; se deshabilito el INSERT financiero directo para clientes autenticados.
- Se corrigio la carga de datos de prueba para que el stock coincida con las operaciones de ejemplo.

## 7. Problemas habituales

| síntoma | Revision sugerida |
|---|---|
| `flutter` no se reconoce | Instala Flutter y reinicia Android Studio o la terminal. |
| No existe `android/` | Ejecuta `PREPARAR_WINDOWS.bat` o `flutter create --project-name kipuvoz --platforms=android,web .`. |
| Falta configurar Supabase | Comprueba `env.json`, su ubicacion y el argumento `--dart-define-from-file=env.json`. |
| No hay internet / Network error | Revisa emulador, URL y estado del proyecto Supabase. |
| Faltan las tablas | Ejecuta `schema.sql` solamente en un proyecto nuevo. |
| Falta categoría | Ejecuta `migracion_02_categoria.sql`. |
| No permite borrar registros | Es intencional: la regla de negocio es archivar, no borrar. |
| `widget_test.dart` falla | Asegurate de usar el archivo de pruebas incluido en este paquete. |

## documentación

- `docs/Guia_tecnica_y_pruebas_KipuVoz.docx`: manual preparado para explicar, instalar y validar el sprint.
- `docs/PLAN_PRUEBAS.md`: seguimiento de las 49 pruebas del documento original.
- `docs/ARQUITECTURA_Y_SEGURIDAD.md`: componentes, rutas, modelo de datos y decisiones de seguridad.
- `docs/ESTADO_DE_VALIDACION.md`: lo que se verifico y lo que falta ejecutar en el emulador.
- `docs/Documento_original_Sprint2_KipuVoz.docx`: informe de 59 paginas recibido, sin alteraciones.
- `docs/Guia_original_companero.md` y `docs/README_original_companero.md`: instrucciones originales como referencia.

Proyecto académico UPDS. No se incluyen credenciales reales.
