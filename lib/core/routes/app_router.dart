import 'package:go_router/go_router.dart';

import '../../features/confirmation/confirmation_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../shared/main_shell.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.welcome,
  routes: [
    // Pantallas sin barra inferior
    GoRoute(path: Routes.welcome, builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: Routes.confirmation, builder: (context, state) => const ConfirmationScreen()),

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
