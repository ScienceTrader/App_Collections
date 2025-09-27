import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 30) {
      return 'Agora';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s atrás';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem atrás';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mês atrás';
    } else {
      return '${(difference.inDays / 365).floor()}ano atrás';
    }
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDateLong(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(dateTime);
  }

  static String formatRelativeDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final difference = today.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference == -1) {
      return 'Amanhã';
    } else if (difference > 1 && difference < 7) {
      return '$difference dias atrás';
    } else if (difference < -1 && difference > -7) {
      return 'Em ${-difference} dias';
    } else {
      return formatDate(dateTime);
    }
  }
}
