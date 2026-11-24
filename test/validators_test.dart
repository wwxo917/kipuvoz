import 'package:flutter_test/flutter_test.dart';
import 'package:kipuvoz/core/utils/validators.dart';

void main() {
  group('Validacion de formularios', () {
    test('correo y contrasena', () {
      expect(Validators.correo('prueba@kipuvoz.com'), isNull);
      expect(Validators.correo('sin-arroba'), isNotNull);
      expect(Validators.contrasena('123456'), isNull);
      expect(Validators.contrasena('123'), isNotNull);
    });

    test('cantidades y precios deben ser positivos', () {
      expect(Validators.decimal('0', campo: 'cantidad', positivo: true), isNotNull);
      expect(Validators.decimal('-1', campo: 'cantidad', positivo: true), isNotNull);
      expect(Validators.decimal('3,50', campo: 'cantidad', positivo: true), isNull);
      expect(Validators.decimal('0', campo: 'stock'), isNull);
      expect(Validators.decimal('-2', campo: 'stock'), isNotNull);
    });

    test('no acepta numeros no finitos', () {
      expect(Validators.decimal('NaN', campo: 'el precio'), isNotNull);
      expect(Validators.decimal('Infinity', campo: 'el precio'), isNotNull);
    });

    test('nombre de negocio maximo 40 caracteres', () {
      expect(Validators.texto(' ', vacio: 'Obligatorio', max: 40, campo: 'nombre'), isNotNull);
      expect(Validators.texto(List.filled(41, 'A').join(), vacio: 'Obligatorio', max: 40, campo: 'nombre'), isNotNull);
      expect(Validators.texto('Mi tienda', vacio: 'Obligatorio', max: 40, campo: 'nombre'), isNull);
    });
  });
}
