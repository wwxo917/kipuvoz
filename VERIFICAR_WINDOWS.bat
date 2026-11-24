@echo off
setlocal
cd /d "%~dp0"
echo [1/2] Analisis de codigo Dart...
flutter analyze
if errorlevel 1 goto failed
echo [2/2] Pruebas de Flutter...
flutter test
if errorlevel 1 goto failed
echo Las comprobaciones automaticas pasaron. Faltan pruebas funcionales con Supabase.
pause
exit /b 0
:failed
echo Se encontraron problemas. Revisa el error anterior.
pause
exit /b 1
