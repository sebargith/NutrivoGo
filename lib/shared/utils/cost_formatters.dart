String formatClp(double? value, {String unknownLabel = 'Sin precio'}) {
  if (value == null) {
    return unknownLabel;
  }
  final rounded = value.round();
  final raw = rounded.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < raw.length; index++) {
    final remaining = raw.length - index;
    buffer.write(raw[index]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return '\$${buffer.toString()}';
}
