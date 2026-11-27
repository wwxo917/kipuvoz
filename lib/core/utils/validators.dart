/// Reglas de validación de los formularios (se repiten en la base de datos como restricciones CHECK).
class Validators {
  Validators._();

  static final _correo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static double? parseNumero(String? value) {
    if (value == null) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String? requerido(String? value, String mensaje) =>
      (value == null || value.trim().isEmpty) ? mensaje : null;

  static String? correo(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu correo.';
    if (!_correo.hasMatch(value.trim())) return 'Ingresa un correo válido.';
    return null;
  }

  static String? contrasena(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
    return null;
  }

  static String? texto(String? value, {required String vacio, required int max, required String campo}) {
    if (value == null || value.trim().isEmpty) return vacio;
    if (value.trim().length > max) return '${_cap(campo)} no puede superar $max caracteres.';
    return null;
  }

  /// Número decimal. positivo=true exige mayor que 0; si no, acepta 0 pero no negativos.
  static String? decimal(String? value, {required String campo, bool positivo = false}) {
    if (value == null || value.trim().isEmpty) return 'Ingresa $campo.';
    final n = parseNumero(value);
    if (n == null || !n.isFinite) return '${_cap(campo)} debe ser un número.';
    if (positivo && n <= 0) return '${_cap(campo)} debe ser mayor que 0.';
    if (!positivo && n < 0) return '${_cap(campo)} no puede ser negativo.';
    if (n > 9999999) return '${_cap(campo)} es demasiado grande.';
    return null;
  }
}
