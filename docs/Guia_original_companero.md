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

# 🚀 Guía de instalación paso a paso

> Esta guía está escrita para que **cualquier persona** pueda ejecutar el proyecto, aunque nunca haya usado Flutter ni Supabase. Sigue los pasos **en orden** y marca cada casilla ✅. No te saltes ninguno.
>
> ⏱️ Tiempo estimado: **45 a 60 minutos** la primera vez (la mayor parte es esperar descargas).

## Mapa general: qué vas a hacer

```
 PASO 0   Instalar herramientas (Flutter + Android Studio + emulador)
    ↓
 PASO 1   Armar la carpeta del proyecto Flutter (aquí van lib/, supabase/, env…)
    ↓
 PASO 2   Instalar las dependencias (3 paquetes)
    ↓
 PASO 3   Crear tu proyecto en Supabase (la base de datos en la nube)
    ↓
 PASO 4   Crear las tablas (pegar 2 archivos SQL en Supabase)
    ↓
 PASO 5   Configurar el inicio de sesión (desactivar "Confirm email")
    ↓
 PASO 6   Conectar la app con Supabase (crear el archivo env.json)
    ↓
 PASO 7   Ejecutar la app en el emulador
    ↓
 PASO 8   Probar que todo funciona (recorrido de prueba)
```

### ¿Dónde se hace cada cosa? (para no perderte)

| Lugar | Para qué se usa | Pasos |
|---|---|---|
| 🌐 **Navegador** (página de Supabase) | Crear el proyecto, las tablas, el login, copiar las claves | 3, 4, 5, 6 |
| 💻 **Android Studio** | Abrir el proyecto, ver archivos, ejecutar la app, usar la terminal | 0, 1, 2, 6, 7 |
| 📁 **Explorador de archivos** (Windows) / **Finder** (Mac) | Copiar carpetas y archivos del paquete al proyecto | 1 |
| 📱 **Emulador Android** | Ver y probar la app | 7, 8 |

### Palabras que vas a ver

| Palabra | Qué significa |
|---|---|
| **Flutter** | La herramienta con la que está hecha la app. |
| **Supabase** | Servicio gratuito en internet donde se guardan los datos (usuarios, productos, ventas). |
| **SQL** | Un lenguaje para crear tablas. Tú solo **copias y pegas** los archivos, no necesitas entenderlo. |
| **Emulador** | Un celular "virtual" que corre dentro de tu computadora. |
| **Terminal** | Una ventana negra donde se escriben comandos. En Android Studio está abajo, en la pestaña **Terminal**. |
| **Raíz del proyecto** | La carpeta principal `kipuvoz/`, donde está el archivo `pubspec.yaml`. |

---

## PASO 0 · Instalar las herramientas

Necesitas tener instalado:

| Herramienta | Versión | Dónde conseguirla |
|---|---|---|
| **Flutter SDK** | **3.27 o superior** | https://docs.flutter.dev/get-started/install |
| **Android Studio** | Probado con Rabbit 2 | https://developer.android.com/studio |
| **Git** | Cualquiera | https://git-scm.com/downloads |
| **Cuenta de Supabase** | Plan gratuito | https://supabase.com (se crea en el Paso 3) |

### 0.1 Instalar los plugins de Flutter y Dart en Android Studio

1. Abre **Android Studio**.
2. Ve a **File → Settings → Plugins** (en Mac: **Android Studio → Settings → Plugins**).
3. En la pestaña **Marketplace** busca **Flutter** y toca **Install** (acepta instalar también **Dart**).
4. Reinicia Android Studio cuando te lo pida.

### 0.2 Verificar la instalación

Abre una terminal (en Android Studio: pestaña **Terminal**, abajo) y escribe:

```bash
flutter --version
flutter doctor
```

- `flutter --version` debe mostrar **3.27 o más**. Si muestra una versión menor, actualiza con `flutter upgrade`.
- `flutter doctor` revisa todo. Lo importante es que aparezcan ✅ en **Flutter**, **Android toolchain** y **Android Studio**. Si dice que faltan licencias de Android, ejecuta:

```bash
flutter doctor --android-licenses
```
y responde `y` a todo.

### 0.3 Crear el emulador

1. En Android Studio abre **Tools → Device Manager**.
2. Toca **Create Device** (o el botón **+**).
3. Elige un teléfono (por ejemplo **Pixel 10**), toca **Next**.
4. Elige una imagen de sistema (por ejemplo **Android 17**; si no está descargada, toca **Download** y espera), toca **Next → Finish**.
5. Toca el botón ▶ junto al emulador para **encenderlo**. Espera a que aparezca la pantalla de inicio del celular virtual.
6. Dentro del emulador, abre el navegador (Chrome) y entra a cualquier página para **confirmar que tiene internet**. La app lo necesita.

✅ **Casilla del Paso 0:** `flutter doctor` sin errores graves y el emulador enciende con internet.

---

## PASO 1 · Armar la carpeta del proyecto Flutter

Este paquete **no incluye** las carpetas `android/`, `ios/` ni el archivo `pubspec.yaml` (los crea Flutter). Solo trae las partes propias de KipuVoz. Por eso hay que combinarlas con un proyecto Flutter.

### Qué trae este paquete y a dónde va cada cosa

| Del paquete (lo que recibiste) | Se copia a... |
|---|---|
| carpeta `lib/` | `kipuvoz/lib/` (**reemplaza** la que ya existe) |
| carpeta `supabase/` | `kipuvoz/supabase/` (al lado de `pubspec.yaml`) |
| archivo `env.example.json` | `kipuvoz/env.example.json` (al lado de `pubspec.yaml`) |
| archivo `gitignore_agregar.txt` | solo se lee (indica qué agregar a `.gitignore`) |
| archivo `README.md` | `kipuvoz/README.md` (opcional) |

### Opción A · Ya tienes el proyecto del Sprint 1 (recomendada)

1. Abre tu proyecto `kipuvoz` en Android Studio (**File → Open** y elige la carpeta `kipuvoz`).
2. En el explorador de archivos de tu computadora, **borra** la carpeta `lib/` del proyecto y **pega** en su lugar la `lib/` de este paquete. (Es decir: la `lib/` vieja se **reemplaza completa**.)
3. **Copia** la carpeta `supabase/` y el archivo `env.example.json` a la raíz del proyecto.
4. Elimina el archivo `test/widget_test.dart` si existe (hacía referencia a la app de ejemplo y ya no sirve; si lo dejas, la compilación de pruebas falla).

### Opción B · Proyecto nuevo desde cero

1. Abre una terminal **fuera** de cualquier proyecto, en la carpeta donde quieras guardarlo (por ejemplo `Documentos`), y ejecuta:

```bash
flutter create kipuvoz
```

2. En Android Studio: **File → Open** y elige la carpeta `kipuvoz` que se acaba de crear.
3. En el explorador de archivos, **borra** la carpeta `lib/` que trae Flutter y **pega** la `lib/` de este paquete.
4. **Copia** `supabase/` y `env.example.json` a la raíz (como en la Opción A).
5. Elimina `test/widget_test.dart`.

### Cómo debe quedar (compruébalo antes de seguir)

En Android Studio, en el panel izquierdo (**Project**), la raíz debe verse así:

```
kipuvoz/
├── android/              ← lo creó Flutter
├── ios/                  ← lo creó Flutter
├── lib/                  ← la del paquete (main.dart, core/, data/, features/ …)
├── supabase/             ← schema.sql, migracion_02_categoria.sql, datos_prueba.sql
├── env.example.json      ← plantilla (en el Paso 6 crearás env.json)
├── pubspec.yaml          ← lo creó Flutter
└── README.md
```

> ⚠️ **Error común:** que quede `kipuvoz/lib/lib/main.dart` (carpeta dentro de carpeta). El archivo debe estar en **`kipuvoz/lib/main.dart`**.

✅ **Casilla del Paso 1:** existe `lib/main.dart` y la carpeta `supabase/` está al lado de `pubspec.yaml`.

---

## PASO 2 · Instalar las dependencias

Las dependencias son 3 paquetes que la app necesita. En la **terminal de Android Studio** (abierta en la raíz del proyecto, donde está `pubspec.yaml`) ejecuta:

```bash
flutter pub add go_router supabase_flutter flutter_riverpod
flutter pub get
```

| Paquete | Para qué se usa |
|---|---|
| `go_router` | Navegación, pestañas y protección de pantallas según la sesión |
| `supabase_flutter` | Autenticación, base de datos y funciones de Supabase |
| `flutter_riverpod` | Manejo de estado (sesión, negocio, productos y movimientos) |

**Cómo comprobar que funcionó:** abre `pubspec.yaml`; en la sección `dependencies:` deben aparecer las tres líneas (`go_router`, `supabase_flutter`, `flutter_riverpod`). Los errores en rojo que se veían en `lib/` deben desaparecer en un minuto.

> Si algo falla por versiones, ejecuta `flutter upgrade` y luego `flutter pub upgrade`.

✅ **Casilla del Paso 2:** las 3 dependencias aparecen en `pubspec.yaml` y `flutter pub get` terminó sin errores.

---

## PASO 3 · Crear el proyecto en Supabase

> 🌐 Todo este paso se hace en el **navegador**.

1. Entra a **https://supabase.com** y toca **Start your project** (o **Sign in** si ya tienes cuenta). Puedes registrarte con GitHub o con correo.
2. Una vez dentro, toca **New project** (si te pide, primero crea una **Organization**: ponle cualquier nombre, tipo *Personal*, plan *Free*).
3. Completa el formulario:

| Campo | Qué poner |
|---|---|
| **Name** | `kipuvoz` |
| **Database Password** | Una contraseña segura. Usa el botón **Generate a password** y **guárdala en un lugar seguro** (no la volverás a ver completa). |
| **Region** | **South America (São Paulo)** (la más cercana a Bolivia) |
| **Plan** | **Free** (gratis) |

4. Toca **Create new project**.
5. **Espera 1 o 2 minutos** mientras Supabase prepara todo (verás una pantalla de "Setting up your project"). No cierres la pestaña. Cuando termine, verás el panel principal con el menú a la izquierda.

✅ **Casilla del Paso 3:** ves el panel (Dashboard) de tu proyecto `kipuvoz` con el menú lateral izquierdo.

---

## PASO 4 · Crear las tablas (SQL)

> 🌐 Todo este paso se hace en el **navegador**, en el panel de Supabase. Vas a **copiar el contenido de los archivos** de la carpeta `supabase/` y pegarlo en Supabase.

### Los archivos y en qué orden se ejecutan

| Orden | Archivo | Qué hace | ¿Obligatorio? |
|---|---|---|---|
| **1** | `supabase/schema.sql` | Crea las 4 tablas (`negocios`, `productos`, `movimientos`, `movimiento_items`), la función `registrar_movimiento`, los disparadores y las políticas de seguridad (RLS). | ✅ **Sí** |
| **2** | `supabase/migracion_02_categoria.sql` | Agrega la columna `categoria` a productos (no borra datos). | ✅ Sí, para poder usar categorías |
| 3 | `supabase/datos_prueba.sql` | Carga un negocio de ejemplo con 4 productos y 3 movimientos. | ⬜ Opcional (ver Paso 4.5) |

### 4.1 Ejecutar `schema.sql` (primer archivo)

1. En el menú izquierdo de Supabase toca **SQL Editor** (ícono `>_`).
2. Toca **New query** (o el botón **+**). Se abre un cuadro de texto vacío.
3. En **Android Studio** (o el bloc de notas), abre el archivo **`supabase/schema.sql`**, presiona **Ctrl + A** (seleccionar todo) y **Ctrl + C** (copiar). *(Mac: Cmd en vez de Ctrl.)*
4. Vuelve al navegador, haz clic dentro del cuadro de texto del SQL Editor y presiona **Ctrl + V** (pegar). Debe pegarse **todo** el archivo (unas 228 líneas).
5. Toca el botón verde **Run** (o presiona **Ctrl + Enter**).
6. Debes ver abajo el mensaje **`Success. No rows returned`**. ✅

> Si Supabase muestra una ventana de advertencia sobre "potential destructive operations" o sobre RLS, revisa que sea el archivo correcto y toca **Run this query**. Este script solo **crea** cosas, no borra nada existente.

### 4.2 Ejecutar `migracion_02_categoria.sql` (segundo archivo)

1. Toca **New query** otra vez (para no mezclar con el anterior).
2. Copia el contenido de **`supabase/migracion_02_categoria.sql`** (son solo 5 líneas) y pégalo.
3. Toca **Run**. Debe decir **`Success. No rows returned`**.

> 💡 **Importante:** ejecuta siempre el `schema.sql` **primero**. Si ejecutas la migración antes, dará error porque la tabla `productos` aún no existe.

### 4.3 Verificar que las tablas existen

1. En el menú izquierdo toca **Table Editor**.
2. Deben aparecer 4 tablas: **`negocios`**, **`productos`**, **`movimientos`**, **`movimiento_items`**.
3. Cada una debe mostrar la etiqueta **RLS enabled** (seguridad activa). Si ves **RLS disabled**, el script no se ejecutó completo: repite el 4.1 (ver "Reiniciar la base" en Solución de problemas).
4. Abre la tabla `productos`: debe tener una columna **`categoria`**.

### 4.4 ¿Qué pasa si me equivoco?

- **"relation already exists"** → ya ejecutaste ese script antes. No pasa nada; no lo ejecutes de nuevo.
- Si el script se ejecutó a medias y quedó roto, mira la sección **"Reiniciar la base de datos"** al final.

### 4.5 (Opcional) Cargar datos de prueba

`datos_prueba.sql` crea un negocio **"Tienda Doña Rosa"** con 4 productos (Arroz, Azúcar, Aceite, Fideo) y 3 movimientos, para el usuario `prueba@kipuvoz.com`.

**Condiciones para que funcione:**
1. Primero debes **registrar ese usuario desde la app** (Paso 8, con el correo exacto `prueba@kipuvoz.com`).
2. **No debes haber configurado todavía el negocio** de ese usuario en la app. Si ya lo hiciste, el script fallará porque cada usuario solo puede tener un negocio.

Si se cumplen, ejecútalo igual que los anteriores (New query → pegar → Run).

> Si no quieres complicarte, **sáltate este paso**: puedes crear tus propios productos desde la app.

✅ **Casilla del Paso 4:** ves las 4 tablas con RLS activo y `productos` tiene la columna `categoria`.

---

## PASO 5 · Configurar el inicio de sesión

> 🌐 En el navegador, panel de Supabase.

1. En el menú izquierdo toca **Authentication**.
2. Entra a **Sign In / Providers** (en versiones anteriores del panel aparece como **Providers**).
3. Verifica que **Email** esté **habilitado** (viene así por defecto).
4. Dentro de la configuración de **Email**, busca la opción **"Confirm email"** y **desactívala**. Toca **Save**.

> **¿Por qué?** Si "Confirm email" queda activado, al registrarte Supabase envía un correo y no podrás entrar hasta confirmarlo. Para desarrollo y para la demo es más cómodo desactivarlo: la cuenta queda activa al instante.
> Si prefieres dejarlo activado, la app funciona igual, pero debes **confirmar el correo** (revisa también la carpeta de spam) antes de iniciar sesión.

5. Más adelante, cada usuario que se registre desde la app aparecerá en **Authentication → Users**.

✅ **Casilla del Paso 5:** Email habilitado y "Confirm email" desactivado (o sabes que debes confirmar el correo).

---

## PASO 6 · Conectar la app con Supabase (el archivo `env.json`)

Este es el paso donde más gente se equivoca, así que va con todo el detalle. La app necesita **2 datos** de tu proyecto de Supabase: la **URL** y la **clave pública**. Los vas a guardar en un archivo llamado **`env.json`**.

### 6.1 Copiar la URL y la clave pública desde Supabase

> 🌐 En el navegador, panel de tu proyecto.

1. Abre **Project Settings** (el ícono de engranaje ⚙️ abajo a la izquierda).
2. Entra a la sección **API Keys** (o **API**, según la versión del panel). 
   - También puedes usar el botón **Connect** que aparece arriba en el panel del proyecto.
3. Copia estos dos datos:

| Dato | Cómo se ve | Dónde está |
|---|---|---|
| **Project URL** | `https://abcdefghij.supabase.co` | En **Project Settings → API** (o en **Data API**) como *Project URL* / *API URL*. |
| **Clave pública** | `sb_publishable_xxxxxxxx…` **o** `eyJhbGciOi…` (muy larga) | En **API Keys**: la llamada **publishable key** (`sb_publishable_…`) o la **anon key** (`eyJ…`, pestaña *Legacy API Keys*). **Cualquiera de las dos sirve.** |

> ⚠️ **NUNCA uses ni compartas la clave secreta** (llamada `service_role` o `secret`, `sb_secret_…`). Esa clave da control total sobre la base de datos. La app **solo** usa la clave **pública**; la seguridad la garantizan las políticas RLS.

> ⚠️ La URL debe ser **solo** `https://xxxx.supabase.co`. **No** le agregues `/rest/v1/` ni `/` al final.

### 6.2 Crear el archivo `env.json`

> 💻 En Android Studio, en el proyecto.

1. En el panel **Project** (izquierda), haz clic derecho sobre el archivo **`env.example.json`** → **Copy** → luego clic derecho sobre la carpeta raíz **`kipuvoz`** → **Paste**. Te pedirá un nombre: escribe **`env.json`** y acepta.
   - Otra forma: clic derecho en la raíz → **New → File** → escribe `env.json`.
2. Abre `env.json` y reemplaza los valores por los tuyos. Debe quedar **exactamente** con este formato:

```json
{
  "SUPABASE_URL": "https://abcdefghij.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_tu_clave_aqui"
}
```

**Reglas para que no falle:**

- ✅ Las comillas `" "` son **obligatorias** (comillas rectas normales, no “curvas”).
- ✅ Hay una **coma** al final de la primera línea y **ninguna** coma después de la última.
- ✅ Sin espacios dentro de la clave, sin saltos de línea dentro de la clave.
- ✅ Los nombres `SUPABASE_URL` y `SUPABASE_ANON_KEY` se escriben **exactamente así** (mayúsculas y guion bajo). No los cambies.
- ✅ El archivo se llama **`env.json`** (no `env.json.txt`, no `env.example.json`).
- ✅ Está en la **raíz** del proyecto, **al lado de `pubspec.yaml`**, no dentro de `lib/`.

### 6.3 Evitar que `env.json` se suba a GitHub

1. Abre el archivo **`.gitignore`** (en la raíz del proyecto; lo creó Flutter).
2. Ve al final del archivo y agrega una línea nueva con:

```
env.json
```

3. Guarda. (Así tu clave nunca se publica en el repositorio.)

> Si ya habías hecho `git add` de `env.json` por error, quítalo con: `git rm --cached env.json`.

✅ **Casilla del Paso 6:** existe `env.json` en la raíz con tu URL y tu clave pública, y está en `.gitignore`.

---

## PASO 7 · Ejecutar la app en el emulador

> Recuerda: el emulador debe estar **encendido** (Paso 0.3).

### Opción A · Configuración de ejecución en Android Studio (recomendada)

Se hace **una sola vez** y después solo tocas ▶.

1. Arriba, junto al botón ▶, abre el menú de configuraciones y elige **Edit Configurations…** (o menú **Run → Edit Configurations…**).
2. En la izquierda, bajo **Flutter**, selecciona la configuración **`main.dart`**. Si no existe, toca **+ → Flutter** y en **Dart entrypoint** elige `lib/main.dart`.
3. En el campo **Additional run args** escribe **exactamente**:

```
--dart-define-from-file=env.json
```

4. Toca **Apply → OK**.
5. Arriba, en el selector de dispositivos, elige tu **emulador** y toca **Run ▶**.

### Opción B · Desde la terminal

En la terminal de Android Studio, estando en la raíz del proyecto:

```bash
flutter run --dart-define-from-file=env.json
```

### Qué esperar

- La **primera vez** tarda varios minutos (descarga componentes de Android/Gradle). Es normal. Las siguientes veces será rápido.
- Verás la pantalla de **Bienvenida** de KipuVoz con 3 pantallas deslizables.

### ⚠️ Si ves "Falta configurar Supabase"

Es el aviso de que la app **no encontró** tu `env.json`. Revisa:
1. El campo **Additional run args** tiene `--dart-define-from-file=env.json` (Paso 7, Opción A).
2. `env.json` está en la raíz, junto a `pubspec.yaml`.
3. El JSON está bien escrito (Paso 6.2).

> 🔁 **Cada vez que cambies `env.json` debes DETENER la app (botón ■) y ejecutarla de nuevo.** El *hot reload* (⚡) y el *hot restart* **no** recargan ese archivo.

### Generar un APK de prueba (opcional)

Para instalar la app en un celular real, agrega el permiso de internet en `android/app/src/main/AndroidManifest.xml`, **dentro de `<manifest>` y antes de `<application>`** (en modo debug ya viene incluido, pero en el APK final no):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Luego, en la terminal:

```bash
flutter build apk --dart-define-from-file=env.json
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.

✅ **Casilla del Paso 7:** la app abre en el emulador y muestra la pantalla de Bienvenida.

---

## PASO 8 · Recorrido de prueba (cada criterio de aceptación)

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

**Cómo comprobar que los datos están de verdad en la nube:** en Supabase abre **Table Editor → productos** (y `movimientos`). Las filas que creaste en la app deben aparecer ahí. Y en **Authentication → Users** verás tu correo.

Para la prueba de seguridad entre usuarios (SE-01), crea una segunda cuenta y comprueba que no ve los datos de la primera.

> 💡 **Prueba de migración (CP-06):** para demostrar que la migración no borra datos, carga primero tus datos (paso 4.1 y datos de prueba) y ejecuta `migracion_02_categoria.sql` **después**. La app funciona sin la migración; solo las categorías la necesitan.

---

## ✅ Lista de verificación final

Si todo esto está marcado, el Sprint 2 está funcionando:

- [ ] `flutter doctor` sin errores graves y emulador con internet
- [ ] `lib/main.dart` y `supabase/` al lado de `pubspec.yaml`
- [ ] 3 dependencias en `pubspec.yaml` (`go_router`, `supabase_flutter`, `flutter_riverpod`)
- [ ] Proyecto de Supabase creado (región São Paulo)
- [ ] `schema.sql` y `migracion_02_categoria.sql` ejecutados con `Success`
- [ ] 4 tablas con RLS activo en **Table Editor**
- [ ] "Confirm email" desactivado en **Authentication**
- [ ] `env.json` en la raíz con URL y clave **pública**, y agregado a `.gitignore`
- [ ] La app se ejecuta con `--dart-define-from-file=env.json`
- [ ] Puedo registrarme, crear negocio, productos y una venta, y el stock baja

---

## Solución de problemas

| Problema | Causa y solución |
|---|---|
| Pantalla **"Falta configurar Supabase"** | No se pasó `env.json`. Revisa el Paso 6 y el argumento `--dart-define-from-file=env.json` (Paso 7). |
| **"Faltan las tablas en Supabase"** | No se ejecutó `schema.sql`. Ejecútalo en el SQL Editor (Paso 4.1). |
| **"Falta aplicar la migración 02"** | Elegiste una categoría sin ejecutar `migracion_02_categoria.sql`. Ejecútalo (Paso 4.2). |
| **"No hay conexión…"** en el emulador | El emulador no tiene internet o el proyecto de Supabase está **pausado** (el plan gratuito pausa tras una semana sin actividad; reactívalo desde el panel con **Restore project**). También revisa que la URL de `env.json` esté bien escrita. |
| **"Correo o contraseña incorrectos"** tras registrarte | Si tienes activa la confirmación de correo, confirma el correo primero o desactiva "Confirm email" (Paso 5). |
| **"Este correo ya está registrado"** | Ese correo ya existe. Inicia sesión o usa otro. Puedes ver los usuarios en **Authentication → Users**. |
| **"No tienes permiso…"** | El usuario no tiene negocio configurado o intentó un `DELETE`. Es el comportamiento esperado de RLS. |
| Cambié `env.json` y no pasa nada | Detén la app (■) y ejecútala de nuevo (reinicio completo). |
| Errores de compilación por versiones | Ejecuta `flutter upgrade` y `flutter pub upgrade`. Requiere Flutter 3.27 o superior. |
| Errores en rojo en `lib/` (paquete no encontrado) | Faltan las dependencias: ejecuta `flutter pub get` (Paso 2). |
| La compilación se queda "Running Gradle task…" mucho tiempo | Es normal la primera vez (varios minutos). Verifica tu internet. |
| `datos_prueba.sql` dice *"Primero registra el usuario prueba@kipuvoz.com"* | Registra ese correo en la app antes (Paso 4.5). |
| `datos_prueba.sql` da error de clave duplicada | Ese usuario ya configuró su negocio. Usa un usuario nuevo o simplemente no cargues los datos de prueba. |
| Error de `test/widget_test.dart` | Elimina ese archivo (Paso 1). |
| Pantalla en blanco o la app se cierra al abrir | Mira la pestaña **Run** de Android Studio: el mensaje en rojo indica la causa. Casi siempre es `env.json` mal escrito. |

### Reiniciar la base de datos (solo en desarrollo)

> ⚠️ **Esto BORRA todos los datos del proyecto.** Úsalo únicamente si ejecutaste el SQL a medias y quedó roto, y solo en tu proyecto de pruebas. Es la **única** excepción a la regla "nunca se borra información" y se hace manualmente desde el SQL Editor, nunca desde la app.

En **SQL Editor → New query**, pega, ejecuta (**Run**) y luego repite el Paso 4.1 y 4.2:

```sql
drop table if exists public.movimiento_items cascade;
drop table if exists public.movimientos cascade;
drop table if exists public.productos cascade;
drop table if exists public.negocios cascade;
drop function if exists public.registrar_movimiento(text, jsonb, text, numeric, text, text);
drop function if exists public.mi_negocio_id();
drop function if exists public.set_actualizado_en();
```

---

# 📚 Referencia del proyecto

## Navegación

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

## Seguridad

- Las 4 tablas tienen **Row Level Security**: cada usuario solo ve y modifica los datos de su negocio.
- **No existe ninguna política de DELETE** y se retiró el permiso de borrado a nivel de tabla.
- El rol anónimo (sin sesión) no tiene acceso a las tablas.
- Los movimientos solo permiten cambiar `concepto` y `estado` (anular); los ítems no se modifican.
- Registrar un movimiento ocurre en **una sola transacción** (función `registrar_movimiento`), validando el stock.
- La app solo contiene la clave **pública**. `env.json` está en `.gitignore`.

## Estructura del proyecto

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

## Credenciales de prueba

| Dato | Valor |
|---|---|
| Usuario de prueba | `prueba@kipuvoz.com` |
| Contraseña | _completar con la que definan al registrarlo_ |
| URL del proyecto Supabase | _completar_ |

> No publiques en el repositorio la clave de Supabase ni contraseñas reales.

## Equipo

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
