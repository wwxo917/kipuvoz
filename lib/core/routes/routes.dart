/// Rutas de la app (ver mapa de navegación del documento del Sprint 2).
abstract class Routes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const loading = '/loading';
  static const setup = '/setup';
  static const settings = '/settings';
  static const home = '/home';
  static const confirmation = '/confirmation';
  static const inventory = '/inventory';
  static const history = '/history';
  static const reports = '/reports';
  static const entry = '/entry/new';
  static const movementEdit = '/entry/correct';
  static const productNew = '/product/new';
  static const productPattern = '/product/:id';

  static String productEdit(String id) => '/product/$id';
}
