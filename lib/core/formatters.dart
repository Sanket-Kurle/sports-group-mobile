import 'package:intl/intl.dart';

final compactDate = DateFormat('EEE, d MMM');
final fullDate = DateFormat('EEEE, d MMMM');
final timeOnly = DateFormat('h:mm a');

String money(double value, {String currency = '₹', bool signed = false}) {
  final amount = NumberFormat('#,##0', 'en_IN').format(value.abs());
  if (!signed) return '$currency$amount';
  return '${value >= 0 ? '+' : '−'}$currency$amount';
}
