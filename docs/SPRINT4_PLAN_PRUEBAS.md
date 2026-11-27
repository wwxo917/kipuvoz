# Sprint 4 — Matriz de pruebas funcionales

**Estado:** Casos diseñados, **pendientes de ejecución en tu equipo**. Guardar capturas y resultados reales al ejecutarlos.

| Caso | HU | Acción | Resultado esperado |
|---|---|---|---|
| S4-01 | 02,18 | Abrir negocio nuevo, seleccionar punto en La Paz, guardar | Latitud/longitud en `negocios` para el usuario |
| S4-02 | 18 | Cambiar marcador de tienda | Coordenadas actualizadas; no aparecen en otra cuenta |
| S4-03 | 18 | Nominatim no disponible | Coordenadas se guardan aun sin dirección |
| S4-04 | 06 | Crear venta/compra/gasto y filtrar por tipo | Historial refleja tipo correctamente |
| S4-05 | 06 | Filtrar fechas de un día | Solo operaciones del período indicado |
| S4-06 | 06 | Abrir detalle del historial | Muestra productos, cantidades, precios y fecha |
| S4-07 | 10 | Anular venta Aceite ×5 con stock 15 | Stock sube a 20, registro `anulado` |
| S4-08 | 10 | Anular compra cuyo stock ya se consumió | RPC rechaza sin modificar historial o stock |
| S4-09 | 10 | Corregir venta Aceite ×5 por ×3 | Original anulado, nuevo activo; stock adecuado |
| S4-10 | 10 | Corregir gasto Bs 10 a Bs 7 | Original anulado, sustituto activo, saldo actualizado |
| S4-11 | 10 | Intentar anular registro de otra cuenta | Rechazado por ID y negocio |
| S4-12 | 11 | Generar reportes sin movimientos | Montos 0, gráfico sin cifras ficticias |
| S4-13 | 11 | Crear venta 90, compra 40, gasto 10 | Saldo neto 40 Bs |
| S4-14 | 11 | Anular esa venta 90 | Reportes dejan de incluirla |
| S4-15 | 11 | Ventas de distintos días | Barras día/semana/mes correctas |
| S4-16 | 14,15 | Desplegar IA, frase válida | JSON del producto existente, borrador editable |
| S4-17 | 14,15 | Sin secreto IA o sin función | Aparece aviso de interpretación local |
| S4-18 | 15 | Comando sin tipo o sin cantidad | Se rechaza; no hay registro ni cambios de stock |
| S4-19 | 13,15 | Permiso micrófono denegado | Aparece error y alternativa escrita |
| S4-20 | 04,15 | Interpretar frase y cancelar confirmación | Ningún movimiento nuevo |
| S4-21 | 04 | Confirmar operación dictada | `origen=voz`, `texto_original` guardados |
| S4-22 | 16 | Preguntar "cuánto vendí hoy" | Texto y TTS con datos reales |
| S4-23 | 16 | Preguntar "stock de aceite" | Respuesta con stock del inventario actual |
| S4-24 | 17 | Convertir USD con API disponible | Importe en Bs, tasa y fecha visibles |
| S4-25 | 17 | Desconectar tras consultar tasa una vez | Se indica "tasa guardada" y fecha anterior |
| S4-26 | 17 | Sin red y sin tasa guardada | No se inventa tasa; se impide continuar |
| S4-27 | 12 | Cerrar sesión, entrar como otro usuario | RLS no filtra ni revela registros ajenos |
| S4-28 | Todas | Ejecutar `flutter analyze`, `flutter test` y `flutter build apk` | Sin errores; documentar salida |

**Notas:** Se permiten datos de prueba en Supabase solo si el equipo conoce su impacto. La corrección de una compra se bloquea si revertir su stock impediría mantener cantidades no negativas. Las consultas con IA externa tienen costo potencial y requieren un token de usuario válido.
