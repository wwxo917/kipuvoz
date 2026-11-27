class Negocio {
  const Negocio({
    required this.id, required this.nombre, required this.tipo, required this.moneda,
    this.latitud, this.longitud, this.direccion,
  });

  final String id;
  final String nombre;
  final String tipo;
  final String moneda;
  final double? latitud;
  final double? longitud;
  final String? direccion;
  bool get tieneUbicacion => latitud != null && longitud != null;

  static const tipos = <String, String>{
    'tienda_barrio': 'Tienda de barrio',
    'mercado': 'Mercado',
    'comida': 'Comida',
    'otro': 'Otro',
  };

  String get tipoLabel => tipos[tipo] ?? tipo;

  factory Negocio.fromMap(Map<String, dynamic> map) => Negocio(
        id: map['id'] as String,
        nombre: map['nombre'] as String,
        tipo: map['tipo'] as String,
        moneda: (map['moneda'] as String?) ?? 'Bs',
        latitud: (map['latitud'] as num?)?.toDouble(),
        longitud: (map['longitud'] as num?)?.toDouble(),
        direccion: map['direccion'] as String?,
      );
}
