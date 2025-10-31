import 'package:intl/intl.dart';

class DateFormatter {
  // Format: 27 ต.ค. 2568
  static String formatDateThai(DateTime date) {
    final thaiMonths = {
      1: 'ม.ค.', 2: 'ก.พ.', 3: 'มี.ค.', 4: 'เม.ย.',
      5: 'พ.ค.', 6: 'มิ.ย.', 7: 'ก.ค.', 8: 'ส.ค.',
      9: 'ก.ย.', 10: 'ต.ค.', 11: 'พ.ย.', 12: 'ธ.ค.',
    };
    
    final day = date.day;
    final month = thaiMonths[date.month];
    final year = date.year + 543;
    
    return '$day $month $year';
  }

  // Format: 27 ตุลาคม 2568
  static String formatDateThaiLong(DateTime date) {
    final thaiMonths = {
      1: 'มกราคม', 2: 'กุมภาพันธ์', 3: 'มีนาคม', 4: 'เมษายน',
      5: 'พฤษภาคม', 6: 'มิถุนายน', 7: 'กรกฎาคม', 8: 'สิงหาคม',
      9: 'กันยายน', 10: 'ตุลาคม', 11: 'พฤศจิกายน', 12: 'ธันวาคม',
    };
    
    final day = date.day;
    final month = thaiMonths[date.month];
    final year = date.year + 543;
    
    return '$day $month $year';
  }

  // Format: 14:30 น.
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date) + ' น.';
  }

  // Format: 27 ต.ค. 2568 14:30 น.
  static String formatDateTime(DateTime date) {
    return '${formatDateThai(date)} ${formatTime(date)}';
  }

  // Format: วันนี้, เมื่อวาน, 27 ต.ค. 2568
  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'วันนี้';
    } else if (dateOnly == yesterday) {
      return 'เมื่อวาน';
    } else {
      return formatDateThai(date);
    }
  }

  // Parse string to DateTime
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  // Get time ago (เมื่อ 5 นาทีที่แล้ว)
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'เมื่อสักครู่';
    } else if (difference.inMinutes < 60) {
      return 'เมื่อ ${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return 'เมื่อ ${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return 'เมื่อ ${difference.inDays} วันที่แล้ว';
    } else {
      return formatDateThai(dateTime);
    }
  }
}