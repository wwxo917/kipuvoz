# KipuVoz

**Asistente de voz con inteligencia artificial para pequeños comerciantes de Bolivia.**

> *"Habla, y tus cuentas se anotan solas."*

KipuVoz es una aplicación móvil hecha con **Flutter** para que tiendas de barrio, puestos de mercado y emprendedores registren ventas, compras y gastos, controlen su inventario y conozcan su ganancia. Proyecto académico de la **Universidad Privada Domingo Savio (UPDS)**, materia **Aplicaciones Móviles I (SIS-0180)**, desarrollado con **Scrum**.

---

## Estado del proyecto

| Sprint | Enfoque | Estado |
|---|---|---|
| Sprint 1 | Pantallas, diseño y navegación | ✅ Completado |
| **Sprint 2** | **Base de datos con Supabase, inicio de sesión y CRUD** | ✅ Implementado (esta versión) |
| Sprint 3 | Historial completo, reportes con datos reales y servicio de IA | ⏳ Pendiente |
| Sprint 4 | Micrófono e inteligencia artificial | ⏳ Pendiente |

### Qué incluye el Sprint 2

| Historia | Qué hace |
|---|---|
| **HU-12** Inicio de sesión y nube | Registro, inicio y cierre de sesión con correo y contraseña (Supabase Auth). Los datos se guardan en la nube y se recuperan en cualquier dispositivo. |
| **HU-09** Productos en la base de datos | Los productos y su stock se guardan en PostgreSQL (Supabase). Migración de ejemplo que no borra datos. |
| **HU-08** Gestión de productos y stock | Crear, editar y **archivar** productos. Una venta descuenta el stock y una compra lo suma. Alerta de stock bajo. |
| **HU-05** Registro manual | Registrar ventas, compras y gastos con total automático y validaciones. Aparecen en el Historial. |
| **HU-02** Configuración del negocio | Nombre, tipo y moneda del negocio; el nombre se ve en Inicio. |
| Mejoras del feedback (FB-01 a FB-06) | Contraste, letra más grande, botones de 56 dp, textos de ayuda, ganancia más notoria y categorías de productos. |

> **Regla del proyecto: nunca se borra información.** Los productos se **archivan** (`activo = false`) y los movimientos se **anulan**. La base de datos rechaza cualquier `DELETE`.

Siguen con datos de ejemplo hasta los próximos sprints: el resumen de **Inicio** y **Reportes** (Sprint 3) y la pantalla de **Confirmación** del micrófono (Sprint 4).

---

## 1. Requisitos

- **Android Studio** (probado con Rabbit 2) con los plugins de **Flutter** y **Dart**.
- **Flutter SDK 3.27 o superior** (verifica con `flutter --version`; actualiza con `flutter upgrade`).
- Un **emulador Android** (por ejemplo, Pixel 10 con Android 17) con acceso a internet.
- Una cuenta gratuita en **[Supabase](https://supabase.com)**.
- Git.

Comprueba tu instalación:

```bash
flutter doctor
```

---

## 2. Preparar el proyecto Flutter

### Opción A: partes de tu proyecto del Sprint 1 (recomendada)

1. Abre tu proyecto `kipuvoz` en Android Studio.
2. **Reemplaza** la carpeta `lib/` completa por la `lib/` de este paquete.
3. Copia al proyecto las carpetas/archivos `supabase/` y `env.example.json` (al lado de `pubspec.yaml`).
4. Elimina el archivo `test/widget_test.dart` (hacía referencia a la app de ejemplo de Flutter y ya no aplica).

### Opción B: proyecto nuevo

```bash
flutter create kipuvoz
cd kipuvoz
```

y luego copia `lib/`, `supabase/` y `env.example.json` como en la opción A.

### Dependencias

Desde la terminal de Android Studio, en la carpeta del proyecto:

```bash
flutter pub add go_router supabase_flutter flutter_riverpod
flutter pub get
```

| Paquete | Para qué se usa |
|---|---|
| `go_router` | Navegación, pestañas y protección de pantallas según la sesión |
| `supabase_flutter` | Autenticación, base de datos y funciones de Supabase |
| `flutter_riverpod` | Manejo de estado (sesión, negocio, productos y movimientos) |

---

## 3. Configurar Supabase (base de datos)

### 3.1 Crear el proyecto

1. Entra a [supabase.com](https://supabase.com), inicia sesión y toca **New project**.
2. Escribe un nombre (por ejemplo, `kipuvoz`) y una **contraseña de base de datos** (guárdala).
3. En **Region** elige la más cercana: **South America (São Paulo)**.
4. Plan **Free** y toca **Create new project**. Espera a que termine de crearse.

### 3.2 Obtener la URL y la clave pública

En el panel del proyecto abre **Project Settings → API** (o **API Keys**):

- **Project URL**: algo como `https://abcdefgh.supabase.co`.
- **Clave pública**: la **publishable key** (`sb_publishable_…`) o la **anon key** (`eyJ…`). Cualquiera de las dos sirve.

> ⚠️ **Nunca uses ni compartas la clave secreta** (`service_role` / `secret`). La app solo usa la clave pública; la seguridad la garantizan las políticas RLS.

### 3.3 Crear las tablas (SQL)

En el panel abre **SQL Editor → New query**, pega el contenido del archivo y toca **Run**. Ejecuta los scripts de la carpeta `supabase/` en este orden:

| Orden | Archivo | Qué hace |
|---|---|---|
| 1 | `supabase/schema.sql` | Crea las 4 tablas, la función `registrar_movimiento`, los disparadores y las políticas de seguridad (RLS). **Obligatorio.** |
| 2 | `supabase/migracion_02_categoria.sql` | Agrega la columna `categoria` a productos (no borra datos). Necesario para usar categorías. |
| 3 | `supabase/datos_prueba.sql` | *(Opcional)* Carga un negocio, 4 productos y 3 movimientos de ejemplo para el usuario `prueba@kipuvoz.com`. Requiere registrar antes ese usuario desde la app. |

Verifica en **Table Editor** que existan `negocios`, `productos`, `movimientos` y `movimiento_items`, todas con RLS activo.

> 💡 **Prueba de migración (CP-06):** carga primero tus datos (paso 1 y datos de prueba) y ejecuta la migración 02 después. La app funciona sin la migración; solo las categorías la necesitan.

### 3.4 Configurar el inicio de sesión

1. Abre **Authentication → Sign In / Providers** (en versiones anteriores: *Authentication → Providers*).
2. Verifica que **Email** esté habilitado.
3. Para desarrollo y demo, **desactiva "Confirm email"** (así la cuenta queda activa al instante). Si lo dejas activado, tras registrarte debes confirmar el correo antes de iniciar sesión.
4. Después de registrar usuarios desde la app, aparecen en **Authentication → Users**.

---

## 4. Conectar la app con Supabase

1. En la raíz del proyecto, **copia** `env.example.json` como `env.json` y completa tus datos:

```json
{
  "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
  "SUPABASE_ANON_KEY": "TU-CLAVE-PUBLICA"
}
```

2. **Agrega `env.json` al `.gitignore`** para que nunca se suba a GitHub (ver `gitignore_agregar.txt`):

```
env.json
```

> Si olvidas configurarlo, la app abre una pantalla que dice **"Falta configurar Supabase"** con estas mismas instrucciones.

---

## 5. Ejecutar en el emulador (Android Studio)

### Opción A: configuración de ejecución (recomendada)

1. Inicia tu emulador (Device Manager → ▶).
2. Menú **Run → Edit Configurations…** y selecciona tu configuración `main.dart`.
3. En **Additional run args** escribe:

```
--dart-define-from-file=env.json
```

4. Toca **Apply → OK** y luego **Run ▶**.

### Opción B: terminal

```bash
flutter run --dart-define-from-file=env.json
```

> Si cambias `env.json`, **detén la app y vuelve a ejecutarla** (no basta con hot reload).

### Para generar un APK de prueba

Agrega el permiso de internet en `android/app/src/main/AndroidManifest.xml` (dentro de `<manifest>`, antes de `<application>`); en modo debug ya viene incluido:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

```bash
flutter build apk --dart-define-from-file=env.json
```

---

## 6. Recorrido de prueba (cada criterio de aceptación)

Sigue este orden en el emulador:

| Paso | Qué hacer | Criterio que verifica |
|---|---|---|
| 1 | Bienvenida → **Comenzar** → **Crear cuenta** con un correo nuevo y contraseña de 6+ caracteres | HU-12 · 1 |
| 2 | Cierra sesión (Inicio → avatar → **Cerrar sesión**) e inicia sesión de nuevo | HU-12 · 1 |
| 3 | En **Configurar negocio**: deja el nombre vacío y toca Guardar (debe mostrar error); luego escribe un nombre, elige el tipo y guarda | HU-02 · 1, 2 |
| 4 | En **Inicio**, el nombre del negocio aparece arriba | HU-02 · 3 |
| 5 | **Inventario → +**: crea productos (por ejemplo, Arroz, bolsa, Bs 40, stock 12, mínimo 5) | HU-08 · 1, HU-09 · 1 |
| 6 | Toca un producto, cambia el precio y guarda; luego **Archivar producto** (desaparece de la lista, no se borra) | HU-08 · 1 |
| 7 | Deja un producto con stock menor o igual al mínimo: aparece en rojo con "Stock bajo" | HU-08 · 3 |
| 8 | **Inicio → Registrar sin voz** (o **Historial → +**): elige Venta, un producto, cantidad y precio; el total se calcula solo. Prueba cantidad 0 o negativa (se rechaza) | HU-05 · 1, 2 |
| 9 | Guarda la venta: aparece en **Historial** y el stock del producto baja | HU-05 · 3, HU-08 · 2 |
| 10 | Registra una **Compra** del mismo producto: el stock sube | HU-08 · 2 |
| 11 | Registra una venta mayor al stock: se rechaza con "Solo hay…" / "Stock insuficiente" | Seguridad |
| 12 | Cierra y reabre la app, o inicia sesión en otro emulador: los datos siguen ahí | HU-12 · 3, HU-09 |
| 13 | Apaga el internet del emulador y abre Inventario: aparece "No hay conexión" con **Reintentar** | HU-12 · 2 |

Para la prueba de seguridad entre usuarios (SE-01), crea una segunda cuenta y comprueba que no ve los datos de la primera.

---

## 7. Navegación

| Ruta | Pantalla | Acceso |
|---|---|---|
| `/welcome` | Bienvenida (3 pantallas deslizables) | Al abrir sin sesión |
| `/login` · `/register` | Iniciar sesión · Crear cuenta | Botón "Comenzar" |
| `/setup` | Configurar o editar negocio | Primera vez, o Ajustes → Editar negocio |
| `/home` | Inicio | Pestaña Inicio |
| `/inventory` | Inventario | Pestaña Inventario |
| `/product/new` · `/product/:id` | Crear / editar producto | Botón + o tocar un producto |
| `/entry/new` | Registro manual | Inicio → Registrar sin voz, o Historial → + |
| `/history` | Historial | Pestaña Historial |
| `/reports` | Reportes (datos de ejemplo) | Pestaña Reportes |
| `/settings` | Cuenta y negocio | Inicio → avatar |
| `/confirmation` | Confirmación (maqueta) | Inicio → micrófono |

**Protección de pantallas:** sin sesión solo se ve Bienvenida, Inicio de sesión y Registro; con sesión y sin negocio se va a Configurar negocio; con sesión y negocio no se vuelve a las pantallas de acceso.

---

## 8. Seguridad

- Las 4 tablas tienen **Row Level Security**: cada usuario solo ve y modifica los datos de su negocio.
- **No existe ninguna política de DELETE** y se retiró el permiso de borrado a nivel de tabla.
- El rol anónimo (sin sesión) no tiene acceso a las tablas.
- Los movimientos solo permiten cambiar `concepto` y `estado` (anular); los ítems no se modifican.
- Registrar un movimiento ocurre en **una sola transacción** (función `registrar_movimiento`), validando el stock.
- La app solo contiene la clave **pública**. `env.json` está en `.gitignore`.

---

## 9. Estructura del proyecto

```
kipuvoz/
├── env.example.json           # Plantilla de claves (env.json no se sube a Git)
├── supabase/                  # schema.sql, migracion_02_categoria.sql, datos_prueba.sql
└── lib/
    ├── main.dart              # Inicializa Supabase y Riverpod
    ├── core/
    │   ├── config/            # env.dart y pantalla "Falta configurar Supabase"
    │   ├── theme/             # app_colors.dart, app_theme.dart (tema único Kipu)
    │   ├── routes/            # routes.dart, app_router.dart (redirect por sesión)
    │   ├── errors/            # app_error.dart (mensajes claros para el usuario)
    │   ├── utils/             # format.dart, validators.dart, async_x.dart
    │   └── data/              # sample_data.dart (solo Confirmación)
    ├── data/
    │   ├── models/            # negocio, producto, movimiento
    │   └── repositories/      # auth, negocio, producto, movimiento
    ├── providers/             # sesión, negocio, productos, movimientos (Riverpod)
    ├── shared/                # widgets, estados (cargando/vacío/error), campos, barra inferior
    └── features/
        ├── welcome/  auth/  business/  settings/
        ├── home/  inventory/  entry/  history/  reports/  confirmation/
```

---

## 10. Solución de problemas

| Problema | Causa y solución |
|---|---|
| Pantalla **"Falta configurar Supabase"** | No se pasó `env.json`. Revisa el paso 4 y el argumento `--dart-define-from-file=env.json`. |
| **"Faltan las tablas en Supabase"** | No se ejecutó `schema.sql`. Ejecútalo en el SQL Editor. |
| **"Falta aplicar la migración 02"** | Elegiste una categoría sin ejecutar `migracion_02_categoria.sql`. Ejecútalo. |
| **"No hay conexión…"** en el emulador | El emulador no tiene internet o el proyecto de Supabase está pausado (el plan gratuito pausa tras una semana sin actividad; reactívalo desde el panel). |
| **"Correo o contraseña incorrectos"** tras registrarte | Si tienes activa la confirmación de correo, confirma el correo primero o desactiva "Confirm email". |
| **"No tienes permiso…"** | El usuario no tiene negocio configurado o intentó un `DELETE`. Es el comportamiento esperado de RLS. |
| Cambié `env.json` y no pasa nada | Detén la app y ejecútala de nuevo (reinicio completo). |
| Errores de compilación por versiones | Ejecuta `flutter upgrade` y `flutter pub upgrade`. Requiere Flutter 3.27 o superior. |

---

## 11. Credenciales de prueba

| Dato | Valor |
|---|---|
| Usuario de prueba | `prueba@kipuvoz.com` |
| Contraseña | _completar con la que definan al registrarlo_ |
| URL del proyecto Supabase | _completar_ |

> No publiques en el repositorio la clave de Supabase ni contraseñas reales.

---

## 12. Equipo

| Integrante | Rol |
|---|---|
| Lic. Rosalia Lopez M. | Product Owner |
| Jorge Mercado Yepez | Scrum Master y desarrollador |
| Henry Maydana Vallejos | Desarrollador |
| Adrian Vargas Vega | Desarrollador |
| Jonathan Cordon Iglesias | Desarrollador |

**Universidad:** Universidad Privada Domingo Savio (UPDS) · **Materia:** Aplicaciones Móviles I (SIS-0180)

## Licencia

Proyecto con fines académicos.
