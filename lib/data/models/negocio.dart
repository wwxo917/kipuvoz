class Negocio {
  const Negocio({required this.id, required this.nombre, required this.tipo, required this.moneda});

  final String id;
  final String nombre;
  final String tipo;
  final String moneda;

  /// Valores de la columna tipo y su etiqueta visible.
  static const tipos = <String, String>{
    'tienda_barrio': 'Tienda de barrio',
    'mercado': 'Mercado',
    'comida': 'Comida',
    'otro': 'Otro',
  };

  String get tipoLabel => tipos[tipo] ?? tipo;

  factory Negocio.fromMap(Map<String, dynamic> m) => Negocio(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        tipo: m['tipo'] as String,
        moneda: (m['moneda'] as String?) ?? 'Bs',
      );
}
