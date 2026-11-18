import '../../core/utils/format.dart';

class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.precioVenta,
    required this.stock,
    required this.stockMinimo,
    this.categoria,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final String unidad;
  final double precioVenta;
  final double stock;
  final double stockMinimo;
  final String? categoria;
  final bool activo;

  static const unidades = <String>['unidad', 'bolsa', 'kg', 'litro', 'paquete', 'caja'];
  static const categorias = <String>['Abarrotes', 'Bebidas', 'Lácteos', 'Limpieza', 'Otros'];

  /// Alerta de stock bajo: stock menor o igual al mínimo (HU-08, criterio 3).
  bool get stockBajo => stock <= stockMinimo;

  String unidadPara(double n) {
    if (unidad == 'kg') return 'kg';
    if (n == 1) return unidad;
    return unidad == 'unidad' ? 'unidades' : '${unidad}s';
  }

  String get stockLabel => '${qty(stock)} ${unidadPara(stock)}';

  String get precioLabel => '${bs(precioVenta)} / $unidad';

  factory Producto.fromMap(Map<String, dynamic> m) => Producto(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        unidad: (m['unidad'] as String?) ?? 'unidad',
        precioVenta: (m['precio_venta'] as num).toDouble(),
        stock: (m['stock'] as num).toDouble(),
        stockMinimo: (m['stock_minimo'] as num).toDouble(),
        categoria: m['categoria'] as String?,
        activo: (m['activo'] as bool?) ?? true,
      );

  /// La categoría solo se envía cuando hace falta: así la app también funciona
  /// antes de aplicar la migración 02 (que crea esa columna).
  Map<String, dynamic> toMap({bool incluirCategoria = false}) => {
        'nombre': nombre.trim(),
        'unidad': unidad,
        'precio_venta': precioVenta,
        'stock': stock,
        'stock_minimo': stockMinimo,
        if (incluirCategoria) 'categoria': categoria,
      };
}
