String _dosDigitos(int n) => n.toString().padLeft(2, '0');

/// Formatea montos en bolivianos: 2090 -> "Bs 2.090", 12.5 -> "Bs 12,50", sign:true -> "+Bs 236".
String bs(num value, {bool sign = false}) {
  final negative = value < 0;
  final cents = (value.abs() * 100).round();
  final whole = (cents ~/ 100).toString();
  final fraction = cents % 100;
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
    buffer.write(whole[i]);
  }
  final decimals = fraction == 0 ? '' : ',${_dosDigitos(fraction)}';
  final prefix = negative ? '−' : (sign ? '+' : '');
  return '${prefix}Bs $buffer$decimals';
}

/// Cantidad sin ceros sobrantes: 5.0 -> "5", 2.5 -> "2.5".
String qty(num value) {
  final r = (value * 100).round() / 100;
  return r == r.roundToDouble() ? r.round().toString() : r.toString();
}

String dateLabel(DateTime d) => '${_dosDigitos(d.day)}/${_dosDigitos(d.month)}/${d.year}';

String timeLabel(DateTime d) => '${_dosDigitos(d.hour)}:${_dosDigitos(d.minute)}';

/// Título de grupo del historial: "HOY · 09/11/2026", "AYER · 08/11/2026" o la fecha.
String dayTitle(DateTime d) {
  final now = DateTime.now();
  final hoy = DateTime(now.year, now.month, now.day);
  final dia = DateTime(d.year, d.month, d.day);
  final diff = hoy.difference(dia).inDays;
  if (diff == 0) return 'HOY · ${dateLabel(d)}';
  if (diff == 1) return 'AYER · ${dateLabel(d)}';
  return dateLabel(d);
}
