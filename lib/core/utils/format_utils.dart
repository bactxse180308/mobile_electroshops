String formatVND(int n) {
  final str = n.toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
    count++;
  }
  return '${String.fromCharCodes(buffer.toString().codeUnits.reversed)} ₫';
}

String formatVNDShort(int n) {
  if (n >= 1000000) {
    final v = n / 1000000;
    if (v == v.floorToDouble()) return '${v.toInt()}tr ₫';
    String s = v.toStringAsFixed(2);
    if (s.endsWith('0')) s = s.substring(0, s.length - 1);
    return '$s tr ₫';
  }
  if (n >= 1000) return '${(n / 1000).round()}k ₫';
  return '$n ₫';
}

String formatSold(int sold) {
  if (sold > 1000) return '${(sold / 1000).toStringAsFixed(1)}k';
  return sold.toString();
}
