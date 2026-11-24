# Estado de validación del paquete KipuVoz (Sprint 2)

## Estado al entregar el ZIP

- Revisado el contenido del ZIP original y el documento técnico de 59 paginas.
- Incorporados el `pubspec.yaml`, scripts de preparación, dependencias declaradas, pruebas unitarias/widget y un proceso de CI opcional.
- Revisados los imports relativos Dart y la presencia de los componentes de las cinco historias HU-02, HU-05, HU-08, HU-09 y HU-12.
- Preparada una correccion de permisos SQL y un script de migracion no destructiva para instalaciones anteriores.
- Ajustados los datos de prueba para que el stock coincida con la compra/venta precargadas.

## Pruebas pendientes (deben ejecutarse en un entorno real)

- `flutter pub get`: NO EJECUTADO en la preparación (Flutter SDK no disponible aqui).
- `flutter analyze`: NO EJECUTADO en la preparación.
- `flutter test`: NO EJECUTADO en la preparación.
- `flutter build apk` / `flutter build web`: NO EJECUTADOS en la preparación.
- Emulador Android y creación de proyecto Supabase: NO EJECUTADOS en la preparación.
- 49 casos del Sprint 2: PENDIENTES DE RESULTADOS Y EVIDENCIAS.

## Criterio para aprobar el incremento

Una historia de usuario solo pasa a 'Terminada' cuando: la app compila sin errores, la base de datos está conectada, todos sus criterios de aceptacion funcionan, cada caso correspondiente fue ejecutado y documentado y otro integrante reviso el cambio.

## Como registrar la evidencia

1. Abre `docs/PLAN_PRUEBAS.md`.
2. Ejecuta cada caso en Android Studio y Supabase, anotando fecha, plataforma, usuario de prueba, resultado y captura.
3. Marca solo los casos verdaderamente aprobados.
4. Adjunta capturas a la seccion 9 del informe original para completar la entrega Scrum.
5. Si falla alguno, registra incidencia, causa, archivo de código o SQL implicado y nueva prueba de regresion.

## Importante

Este archivo no certifica que la app este desplegada o libre de errores: el proyecto es un paquete fuente preparado para ejecutar y comprobar. Se necesita una cuenta Supabase propia y el Flutter SDK del equipo.
