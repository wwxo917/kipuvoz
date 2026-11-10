/// Formatea montos en bolivianos: 2090 -> "Bs 2.090", sign:true -> "+Bs 236".
String bs(num value, {bool sign = false}) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  final prefix = negative ? '−' : (sign ? '+' : '');
  return '${prefix}Bs $buffer';
}
