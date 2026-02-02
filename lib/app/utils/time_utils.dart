import 'package:intl/intl.dart';

String _normalizeSpace(String s) =>
    s.replaceAll(RegExp(r'[\u00A0\u202F\s]+'), ' ').trim();

/// Parse a time string robustly into a DateTime (today's date + time).
DateTime parseTimeString(String raw) {
  final s = _normalizeSpace(raw);
  final now = DateTime.now();

  try {
    if (RegExp(r'\b(am|pm)\b', caseSensitive: false).hasMatch(s)) {
      final d = DateFormat.jm().parse(s);
      return DateTime(now.year, now.month, now.day, d.hour, d.minute);
    }

    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s);
    if (m != null) {
      final h = int.parse(m.group(1)!);
      final min = int.parse(m.group(2)!);
      return DateTime(now.year, now.month, now.day, h, min);
    }

    final d = DateFormat.jm().parse(s);
    return DateTime(now.year, now.month, now.day, d.hour, d.minute);
  } catch (_) {
    return now;
  }
}
