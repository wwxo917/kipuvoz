import 'package:flutter_test/flutter_test.dart';
import 'package:kipuvoz/data/models/producto.dart';

void main() {
  test('stock bajo incluye el valor minimo', () {
    const p = Producto(id: '1', nombre: 'Arroz', unidad: 'bolsa',
        precioVenta: 40, stock: 5, stockMinimo: 5);
    expect(p.stockBajo, isTrue);
    expect(p.stockLabel, '5 bolsas');
  });

  test('serializa el producto con categoria opcional', () {
    const p = Producto(id: '', nombre: '  Azucar  ', unidad: 'kg',
        precioVenta: 8, stock: 3, stockMinimo: 5, categoria: 'Abarrotes');
    expect(p.toMap()['nombre'], 'Azucar');
    expect(p.toMap().containsKey('categoria'), isFalse);
    expect(p.toMap(incluirCategoria: true)['categoria'], 'Abarrotes');
  });
}
