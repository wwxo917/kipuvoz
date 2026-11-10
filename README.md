# KipuVoz

**Asistente de voz con inteligencia artificial para pequeños comerciantes de Bolivia.**

> *"Habla, y tus cuentas se anotan solas."*

KipuVoz es una aplicación móvil desarrollada con **Flutter** que permitirá a tiendas de barrio, puestos de mercado y emprendedores registrar ventas, compras y gastos hablando, controlar su inventario y conocer su ganancia sin llevar cuentas a mano. El nombre hace referencia al *kipu* (quipu), el sistema de cuerdas y nudos que las culturas andinas usaban para llevar cuentas.

Proyecto académico desarrollado en la **Universidad Privada Domingo Savio (UPDS)** bajo la metodología **Scrum**.

---

## Estado del proyecto

| Sprint | Enfoque | Estado |
|---|---|---|
| **Sprint 1** | Pantallas, diseño y navegación (sin funcionalidad) | ✅ Completado |
| Sprint 2 | Funcionalidades (registro manual, productos y stock, resúmenes) | ⏳ Pendiente |
| Sprint 3 | Base de datos local y respaldo en la nube | ⏳ Pendiente |
| Sprint 4 | Micrófono, API de IA y servicios | ⏳ Pendiente |

> En el Sprint 1 todas las pantallas usan **datos de ejemplo**. Todavía no hay base de datos, voz ni inteligencia artificial.

---

## Pantallas del Sprint 1

| Bienvenida | Inicio | Confirmación |
|---|---|---|
| ![Bienvenida](docs/screenshots/bienvenida.png) | ![Inicio](docs/screenshots/inicio.png) | ![Confirmación](docs/screenshots/confirmacion.png) |

| Inventario | Historial | Reportes |
|---|---|---|
| ![Inventario](docs/screenshots/inventario.png) | ![Historial](docs/screenshots/historial.png) | ![Reportes](docs/screenshots/reportes.png) |

> Las imágenes se guardan en la carpeta `docs/screenshots/`.

### Qué incluye cada pantalla

- **Bienvenida:** logotipo, nombre, eslogan y 3 pantallas deslizables de presentación, con el botón "Comenzar".
- **Inicio:** ganancia del día, tarjetas de ventas y gastos, botón grande de micrófono y últimos movimientos.
- **Confirmación:** frase escuchada, lista de ítems (producto, cantidad, precio unitario y subtotal), total y botones Confirmar, Editar y Cancelar.
- **Inventario:** búsqueda, filtro de stock bajo y lista de productos con indicador de nivel de stock.
- **Historial:** filtros por tipo y movimientos agrupados por día, con tipo, fecha y monto.
- **Reportes:** selector Día / Semana / Mes, ganancia, gráfico de barras y productos más vendidos.

---

## Tecnologías

| Tecnología | Uso |
|---|---|
| [Flutter](https://flutter.dev) y Dart | Framework y lenguaje de la aplicación |
| Material 3 | Sistema de diseño y tema |
| [go_router](https://pub.dev/packages/go_router) | Navegación con rutas y pestañas que conservan su estado |
| Android Studio | Entorno de desarrollo y emulador |
| Git y GitHub | Control de versiones |
| Trello | Tablero Kanban del sprint |

**Planificado para sprints posteriores:** Riverpod o Bloc (estado), Isar o Drift (base de datos local), Supabase o Firebase (nube), `speech_to_text` y `flutter_tts` (voz) y una API de IA con un backend intermedio.

---

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.27 o superior** (incluye Dart).
- [Android Studio](https://developer.android.com/studio) con el plugin de Flutter y un emulador Android configurado (o un dispositivo físico).
- Git.

Verifica tu instalación con:

```bash
flutter --version
flutter doctor
```

---

## Instalación y ejecución

```bash
# 1. Clonar el repositorio
git clone <URL-del-repositorio>
cd kipuvoz

# 2. Descargar las dependencias
flutter pub get

# 3. Iniciar un emulador Android (o conectar un dispositivo) y ejecutar
flutter run
```

**Credenciales de acceso:** no aplica en el Sprint 1 (la aplicación todavía no tiene inicio de sesión).

### Si partes de un proyecto nuevo

```bash
flutter create kipuvoz
cd kipuvoz
flutter pub add go_router
# Reemplaza la carpeta lib/ por la de este repositorio
flutter pub get
flutter run
```

---

## Navegación

La app usa `go_router`. Las cuatro pestañas principales se definen con `StatefulShellRoute`, por lo que cada una conserva su estado al cambiar de pestaña.

| Ruta | Pantalla | Cómo se accede |
|---|---|---|
| `/welcome` | Bienvenida | Al abrir la aplicación |
| `/home` | Inicio | Botón "Comenzar" o pestaña Inicio |
| `/confirmation` | Confirmación | Botón de micrófono en Inicio |
| `/inventory` | Inventario | Pestaña Inventario |
| `/history` | Historial | Pestaña Historial |
| `/reports` | Reportes | Pestaña Reportes |

**Reglas de navegación:**

- La barra inferior se muestra en las 4 pestañas y se oculta en Bienvenida y Confirmación.
- El botón atrás desde cualquier pestaña regresa a Inicio; desde Inicio, sale de la aplicación.
- En Confirmación, "Confirmar y guardar" y "Cancelar" regresan a Inicio.

---

## Diseño

Tema único basado en la paleta **Kipu**, inspirada en los colores de Bolivia:

| Uso | Color | Código |
|---|---|---|
| Primario | Verde profundo | `#1B5E3F` |
| Acento y micrófono | Ámbar | `#F2A900` |
| Alerta y stock bajo | Rojo | `#C62828` |
| Fondo | Crema claro | `#FAF7F0` |
| Texto principal | Gris casi negro | `#1F2933` |

**Criterios de usabilidad aplicados:** zonas táctiles de al menos 48 dp (micrófono de 88 dp), contraste de texto de al menos 4.5:1, estados comunicados con color, texto y forma, y acciones principales al alcance del pulgar. El diseño se basa en las heurísticas de Nielsen y en las guías de accesibilidad de Material Design.

---

## Estructura del proyecto

```
kipuvoz/
├── android/ · ios/            # Proyectos nativos generados por Flutter
├── test/                      # Pruebas automatizadas
├── pubspec.yaml               # Dependencias y configuración
└── lib/
    ├── main.dart              # Punto de entrada de la aplicación
    ├── core/
    │   ├── theme/             # Colores y tema Material 3
    │   ├── routes/            # Rutas y configuración de go_router
    │   ├── utils/             # Utilidades (formato de montos en Bs)
    │   └── data/              # Datos de ejemplo
    ├── shared/                # Widgets reutilizables y barra de navegación inferior
    └── features/
        ├── welcome/           # Bienvenida
        ├── home/              # Inicio
        ├── confirmation/      # Confirmación de registro
        ├── inventory/         # Inventario
        ├── history/           # Historial
        └── reports/           # Reportes
```

---

## Flujo de trabajo con Git

- `main`: versión estable (se actualiza al cerrar cada sprint).
- `develop`: integración del trabajo del sprint.
- `feature/nombre-de-la-tarea`: una rama por tarea o pantalla.
- Los cambios se integran mediante **Pull Requests** revisados por al menos otro integrante.
- Mensajes de commit descriptivos, por ejemplo: `feat: agrega pantalla de bienvenida`.

---

## Equipo

| Integrante | Rol |
|---|---|
| Lic. Rosalia Lopez M. | Product Owner |
| Jorge Mercado Yepez | Scrum Master y desarrollador |
| Henry Maydana Vallejos | Desarrollador |
| Adrian Vargas Vega | Desarrollador |
| Jonathan Cordon Iglesias | Desarrollador |

**Universidad:** Universidad Privada Domingo Savio (UPDS)
**Materia / Docente:** _completar_

---

## Licencia

Proyecto con fines académicos.
