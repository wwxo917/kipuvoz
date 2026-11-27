-- Migración 02 · Categoría de producto (mejora derivada del feedback del Sprint 1)
-- No borra ni modifica los datos existentes.
alter table public.productos
  add column if not exists categoria text
  check (categoria is null or char_length(btrim(categoria)) between 1 and 30);
