@echo off
setlocal
cd /d "%~dp0"
if not exist env.json (
  echo ERROR: Primero ejecuta PREPARAR_WINDOWS.bat y edita env.json.
  pause
  exit /b 1
)
echo Verifica que el emulador Android este encendido.
flutter run --dart-define-from-file=env.json
pause
