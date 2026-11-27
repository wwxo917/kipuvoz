import 'package:flutter_test/flutter_test.dart';
import 'package:kipuvoz/core/utils/format.dart';

void main() {
  test('formato de bolivianos y decimales', () {
    expect(bs(236), 'Bs 236');
    expect(bs(1234.5), 'Bs 1.234,50');
    expect(bs(-15), '−Bs 15');
    expect(bs(236, sign: true), '+Bs 236');
  });

  test('cantidad, fecha y hora', () {
    expect(qty(2.0), '2');
    expect(qty(2.5), '2.5');
    expect(dateLabel(DateTime(2026, 11, 17)), '17/11/2026');
    expect(timeLabel(DateTime(2026, 11, 17, 9, 8)), '09:08');
  });
}
