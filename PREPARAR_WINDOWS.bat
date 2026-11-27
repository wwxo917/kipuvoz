@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter no se encontro en PATH. Instala Flutter y abre una nueva terminal.
  pause
  exit /b 1
)
echo [1/3] Generando las carpetas nativas Android y Web con tu SDK...
flutter create --project-name kipuvoz --platforms=android,web .
if errorlevel 1 goto failed
echo [2/3] Instalando dependencias...
flutter pub get
if errorlevel 1 goto failed
echo [3/3] Verificando la configuracion...
if not exist env.json (
  copy /y env.example.json env.json >nul
  echo IMPORTANTE: Abre env.json y sustituye la URL y la clave publica por las de TU Supabase.
)
echo.
echo Preparacion finalizada. Abre esta carpeta en Android Studio.
echo Ejecuta flutter run --dart-define-from-file=env.json
pause
exit /b 0
:failed
echo ERROR: Revisa la salida anterior y la instalacion de Flutter.
pause
exit /b 1
