#!/bin/sh
set -eu
cd "$(dirname "$0")"
flutter create --project-name kipuvoz --platforms=android,web .
flutter pub get
if [ ! -f env.json ]; then
  cp env.example.json env.json
  echo 'IMPORTANTE: completa env.json con tu URL y clave publica de Supabase.'
fi
printf '%s\n' 'Preparacion lista. flutter run --dart-define-from-file=env.json'
