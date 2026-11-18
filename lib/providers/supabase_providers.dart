import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/movimiento_repository.dart';
import '../data/repositories/negocio_repository.dart';
import '../data/repositories/producto_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(supabaseClientProvider)));

final negocioRepositoryProvider =
    Provider<NegocioRepository>((ref) => NegocioRepository(ref.watch(supabaseClientProvider)));

final productoRepositoryProvider =
    Provider<ProductoRepository>((ref) => ProductoRepository(ref.watch(supabaseClientProvider)));

final movimientoRepositoryProvider =
    Provider<MovimientoRepository>((ref) => MovimientoRepository(ref.watch(supabaseClientProvider)));
