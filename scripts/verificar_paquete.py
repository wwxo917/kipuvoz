#!/usr/bin/env python3
"""Structural-only check; it does NOT replace flutter analyze or real integration tests."""
from pathlib import Path
import re, sys, json, zipfile
try:
    import yaml
except ImportError:
    yaml = None
ROOT = Path(__file__).resolve().parent.parent
REQUIRED = [
 'pubspec.yaml','analysis_options.yaml','.gitignore','env.example.json',
 'lib/main.dart','lib/core/routes/app_router.dart',
 'lib/data/repositories/movimiento_repository.dart',
 'lib/providers/auth_provider.dart','supabase/schema.sql',
 'supabase/migracion_02_categoria.sql','supabase/migracion_03_seguridad.sql',
 'supabase/verificar_instalacion.sql',
 'docs/PLAN_PRUEBAS.md','docs/Guia_tecnica_y_pruebas_KipuVoz.docx',
 'test/widget_test.dart','PREPARAR_WINDOWS.bat']
problems=[]
for f in REQUIRED:
    if not (ROOT/f).is_file(): problems.append('Missing '+f)
if (ROOT/'env.json').exists(): problems.append('env.json must never be shipped')
for dart in (ROOT/'lib').rglob('*.dart'):
    content=dart.read_text(encoding='utf8')
    for imp in re.findall(r"^import\s+['\"]([^'\"]+)['\"];",content,re.M):
        if imp.startswith('package:') or imp.startswith('dart:'):continue
        if not (dart.parent/imp).resolve().is_file():
            problems.append(f'Broken import: {dart.relative_to(ROOT)} -> {imp}')
if yaml is not None:
    with (ROOT/'pubspec.yaml').open(encoding='utf8') as f:
        pub=yaml.safe_load(f)
    for package in ('go_router','supabase_flutter','flutter_riverpod'):
        if package not in pub.get('dependencies',{}):problems.append('No dependency '+package)
for doc in (ROOT/'docs').glob('*.docx'):
    try:
        with zipfile.ZipFile(doc) as z:
            bad=z.testzip()
            if bad:problems.append('Invalid docx '+str(doc))
    except Exception as e:problems.append(str(e))
text=(ROOT/'supabase/schema.sql').read_text(encoding='utf8')
for label,condition in [
    ('Missing RLS',sum(text.count('enable row level security') for _ in [0]) < 4),
    ('Missing transaction RPC','create function public.registrar_movimiento(' not in text),
    ('Missing definer rights','security definer' not in text),
    ('Missing finance insert restrictions','revoke insert on public.movimientos, public.movimiento_items from public, anon, authenticated' not in text),
    ('Delete accidentally granted','grant delete on' in text.lower()),
]:
    if condition:problems.append(label)
plan=(ROOT/'docs/PLAN_PRUEBAS.md').read_text(encoding='utf8')
ids=set(re.findall(r'\b(?:CP|CN|CR|AU|SE)-\d{2}\b',plan))
if len(ids)!=49:problems.append(f'Expected 49 test cases, found {len(ids)}')
print('Dart files:',len(list((ROOT/'lib').rglob('*.dart'))))
print('SQL files:',len(list((ROOT/'supabase').glob('*.sql'))))
print('Test cases:',len(ids))
print('Structural checks:', 'FAILED' if problems else 'PASS')
for p in problems:print('ERROR:',p)
sys.exit(1 if problems else 0)
