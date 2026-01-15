import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateFormatter {
  static bool _initialized = false;
  static DateFormat? _dayMonthYear;
  static DateFormat? _fullDate;
  static DateFormat? _monthYear;
  static DateFormat? _shortDate;

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initializeDateFormatting('id_ID', null);
      _dayMonthYear = DateFormat('dd MMM yyyy', 'id_ID');
      _fullDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
      _monthYear = DateFormat('MMMM yyyy', 'id_ID');
      _shortDate = DateFormat('dd/MM/yyyy');
      _initialized = true;
    }
  }

  static String formatDayMonthYear(DateTime date) {
    if (!_initialized) {
      // Fallback to simple format if not initialized
      return '${date.day}/${date.month}/${date.year}';
    }
    return _dayMonthYear!.format(date);
  }

  static String formatFullDate(DateTime date) {
    if (!_initialized) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return _fullDate!.format(date);
  }

  static String formatMonthYear(DateTime date) {
    if (!_initialized) {
      final months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${months[date.month]} ${date.year}';
    }
    return _monthYear!.format(date);
  }

  static String formatShortDate(DateTime date) {
    if (!_initialized) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return _shortDate!.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else {
      return formatDayMonthYear(date);
    }
  }

  // Call this in main() to initialize
  static Future<void> initialize() async {
    await _ensureInitialized();
  }
}
