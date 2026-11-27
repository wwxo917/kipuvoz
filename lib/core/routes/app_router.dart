import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/negocio.dart';
import '../../data/models/movimiento.dart';
import '../../data/services/voice_command_service.dart';
import '../../features/auth/loading_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/business/setup_screen.dart';
import '../../features/confirmation/confirmation_screen.dart';
import '../../features/entry/manual_entry_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/inventory/product_form_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/negocio_provider.dart';
import '../../shared/main_shell.dart';
import 'routes.dart';

/// Avisa a go_router cuando cambia la sesión o el negocio, para volver a evaluar las redirecciones.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen<String?>(userIdProvider, (previous, next) => notifyListeners());
    ref.listen<AsyncValue<Negocio?>>(negocioProvider, (previous, next) => notifyListeners());
  }
}

/// Reglas de protección de pantallas (sección 7.6 del documento):
/// - Sin sesión: solo Bienvenida, Inicio de sesión y Registro.
/// - Con sesión y sin negocio: solo Configurar negocio.
/// - Con sesión y negocio: no se vuelve a las pantallas de acceso.
String? _redirect(Ref ref, GoRouterState state) {
  final loc = state.matchedLocation;
  final userId = ref.read(userIdProvider);
  final esAcceso = loc == Routes.welcome || loc == Routes.login || loc == Routes.register;

  if (userId == null) return esAcceso ? null : Routes.welcome;

  final negocio = ref.read(negocioProvider);
  if (!negocio.hasValue) {
    // Cargando el negocio (o error de conexión): pantalla de carga con opción de reintentar.
    return loc == Routes.loading ? null : Routes.loading;
  }

  final tieneNegocio = negocio.requireValue != null;
  if (!tieneNegocio) return loc == Routes.setup ? null : Routes.setup;
  if (esAcceso || loc == Routes.loading) return Routes.home;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: Routes.welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: Routes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: Routes.loading, builder: (context, state) => const LoadingScreen()),
      GoRoute(path: Routes.setup, builder: (context, state) => const SetupScreen()),
      GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: Routes.confirmation,
        builder: (context, state) => ConfirmationScreen(
          borradorInicial: state.extra as BorradorComandoVoz?,
        ),
      ),
      GoRoute(path: Routes.entry, builder: (context, state) => const ManualEntryScreen()),
      GoRoute(path: Routes.movementEdit,
          builder: (context, state) => ManualEntryScreen(
              aCorregir: state.extra as Movimiento?)),
      // '/product/new' debe ir antes de '/product/:id'
      GoRoute(path: Routes.productNew, builder: (context, state) => const ProductFormScreen()),
      GoRoute(
        path: Routes.productPattern,
        builder: (context, state) => ProductFormScreen(productoId: state.pathParameters['id']),
      ),

      // Las 4 pestañas principales: cada una conserva su estado al cambiar de pestaña
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.inventory, builder: (context, state) => const InventoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.history, builder: (context, state) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.reports, builder: (context, state) => const ReportsScreen()),
          ]),
        ],
      ),
    ],
  );
});