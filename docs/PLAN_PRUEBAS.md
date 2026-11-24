# Plan y registro de pruebas - Sprint 2

**Procedimiento**: crear Supabase de pruebas, instalar KipuVoz, crear dos usuarios diferentes (A y B) y registrar inventario de ejemplo. Anotar en cada ejecución fecha, dispositivo, resultado, responsable y ubicacion de captura. Ningun caso está marcado como aprobado por adelantado.

**Precondicion**: ejecutar `supabase/verificar_instalacion.sql` y confirmar RLS. Para probar que 10 operaciones ajustan el stock, parte de un producto con stock conocido y registra las operaciones una a una, comparando con la suma algebraica en cada paso.

| ID | Escenario a verificar | Historia | Resultado | Evidencia |
|---|---|---|---|---|
| CP-01 | Registrar, cerrar e iniciar sesión | HU-12 | Pendiente | Captura pendiente |
| CP-02 | Guardar conectado y recuperar de error sin internet | HU-12 | Pendiente | Captura pendiente |
| CP-03 | Recuperar datos desde otro dispositivo | HU-12 | Pendiente | Captura pendiente |
| CP-04 | Persistir productos y stock en Supabase | HU-09 | Pendiente | Captura pendiente |
| CP-05 | Comparar stock tras 10 ventas/compras | HU-09 | Pendiente | Captura pendiente |
| CP-06 | Aplicar migracion 02 sin perder registros | HU-09 | Pendiente | Captura pendiente |
| CP-07 | Crear, editar y archivar producto | HU-08 | Pendiente | Captura pendiente |
| CP-08 | Venta -3 y compra +5 sobre stock inicial 12 | HU-08 | Pendiente | Captura pendiente |
| CP-09 | Mostrar alerta con stock menor o igual al mínimo | HU-08 | Pendiente | Captura pendiente |
| CP-10 | Formulario permite tipo, producto, cantidad y precio | HU-05 | Pendiente | Captura pendiente |
| CP-11 | Bloquear datos invalidos y calcular subtotal | HU-05 | Pendiente | Captura pendiente |
| CP-12 | Guardar movimiento y verlo en Historial | HU-05 | Pendiente | Captura pendiente |
| CP-13 | Formulario de nombre, tipo y moneda Bs | HU-02 | Pendiente | Captura pendiente |
| CP-14 | Bloquear nombre vacio o de 41 caracteres | HU-02 | Pendiente | Captura pendiente |
| CP-15 | Mostrar nombre del negocio en Inicio | HU-02 | Pendiente | Captura pendiente |
| CP-16 | Contraste y simbolos para ingresos y gastos | FB-01 | Pendiente | Captura pendiente |
| CP-17 | Legibilidad al ampliar fuente 130 % | FB-02 | Pendiente | Captura pendiente |
| CP-18 | Botones de accion de al menos 56 dp | FB-03 | Pendiente | Captura pendiente |
| CP-19 | Ayudas en formularios y pantallas vacias | FB-04 | Pendiente | Captura pendiente |
| CP-20 | Ganancia de ejemplo destacada a 44 sp | FB-05 | Pendiente | Captura pendiente |
| CP-21 | categoría y filtrado de inventario | FB-06 | Pendiente | Captura pendiente |

## Conexion

| ID | Escenario a verificar | Resultado | Evidencia |
|---|---|---|---|
| CN-01 | Conexion correcta con URL y clave pública | Pendiente | Captura pendiente |
| CN-02 | Clave pública incorrecta: error controlado | Pendiente | Captura pendiente |
| CN-03 | Sin internet y reintento tras reconectar | Pendiente | Captura pendiente |
| CN-04 | Persistencia tras cerrar y reabrir aplicación | Pendiente | Captura pendiente |

## CRUD

| ID | Escenario a verificar | Resultado | Evidencia |
|---|---|---|---|
| CR-01 | CREATE de producto | Pendiente | Captura pendiente |
| CR-02 | READ de inventario solo del usuario | Pendiente | Captura pendiente |
| CR-03 | UPDATE de precio y stock mínimo | Pendiente | Captura pendiente |
| CR-04 | Archivado y reutilizacion del nombre | Pendiente | Captura pendiente |
| CR-05 | DELETE rechazado usando rol autenticado | Pendiente | Captura pendiente |
| CR-06 | Venta con dos productos, items y stock | Pendiente | Captura pendiente |
| CR-07 | Historial ordenado por fecha | Pendiente | Captura pendiente |
| CR-08 | Crear y actualizar negocio desde Ajustes | Pendiente | Captura pendiente |

## Auth

| ID | Escenario a verificar | Resultado | Evidencia |
|---|---|---|---|
| AU-01 | Crear usuario con contraseña valida | Pendiente | Captura pendiente |
| AU-02 | Correo ya registrado | Pendiente | Captura pendiente |
| AU-03 | contraseña menor de 6 caracteres | Pendiente | Captura pendiente |
| AU-04 | Confirmacion de contraseña distinta | Pendiente | Captura pendiente |
| AU-05 | Credenciales incorrectas | Pendiente | Captura pendiente |
| AU-06 | Cerrar sesión y proteger rutas privadas | Pendiente | Captura pendiente |
| AU-07 | sesión persistente al reiniciar | Pendiente | Captura pendiente |
| AU-08 | Cuenta sin negocio redirige a configuración | Pendiente | Captura pendiente |

## Seguridad

| ID | Escenario a verificar | Resultado | Evidencia |
|---|---|---|---|
| SE-01 | Usuario B no consulta productos de A | Pendiente | Captura pendiente |
| SE-02 | Usuario B no modifica productos de A | Pendiente | Captura pendiente |
| SE-03 | Consultas anonimas rechazadas | Pendiente | Captura pendiente |
| SE-04 | DELETE rechazado por privilegios | Pendiente | Captura pendiente |
| SE-05 | Intento de editar total de movimiento rechazado | Pendiente | Captura pendiente |
| SE-06 | Intento de venta con producto de otra cuenta rechazado | Pendiente | Captura pendiente |
| SE-07 | Venta con stock insuficiente se revierte | Pendiente | Captura pendiente |
| SE-08 | No existen claves secretas en el repositorio | Pendiente | Captura pendiente |

## Datos sugeridos para la demostracion

- Usuario A: crear desde la app con un correo real de pruebas; configurar negocio A.
- Producto Arroz: unidad bolsa, precio Bs 40, stock 12, mínimo 5.
- Venta de 3 arroz: stock 12 -> 9; compra de 5 arroz: stock 9 -> 14.
- Intentar vender 15 arroz: rechazo, stock debe continuar en 14; no debe aparecer una venta fallida en Historial.
- Archivar otro producto: no debe aparecer en Inventario, pero debe conservar sus datos en Supabase.
- Usuario B: nueva cuenta, su inventario debe empezar vacio y no poder leer ni modificar productos de A.

## Resultado final

| Tipo | Casos | Aprobados | Fallidos | Pendientes |
|---|---:|---:|---:|---:|
| Criterios (CP) | 21 | 0 | 0 | 21 |
| Conexion (CN) | 4 | 0 | 0 | 4 |
| CRUD (CR) | 8 | 0 | 0 | 8 |
| autenticación (AU) | 8 | 0 | 0 | 8 |
| Seguridad (SE) | 8 | 0 | 0 | 8 |
| **TOTAL** | **49** | **0** | **0** | **49** |

*Actualizar estos valores al ejecutar las pruebas reales.*
