/// Calendar-date helpers for values that must not move between time zones.
///
/// Dates are represented at local midnight for SQLite. Their year/month/day
/// components are never converted between zones; only the explicit
/// `YYYY-MM-DD` representation is sent to Supabase.
DateTime calendarDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool isSameCalendarDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String calendarDateToStorage(DateTime value) {
  final date = calendarDate(value);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime calendarDateFromStorage(Object? value, {required DateTime fallback}) {
  if (value is DateTime) {
    return calendarDate(value);
  }
  if (value is String) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }
  }
  return calendarDate(fallback);
}
