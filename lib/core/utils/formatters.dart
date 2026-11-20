import 'package:intl/intl.dart';

class Formatters {
  // 25000 -> "Rp 25.000"
  static String rupiah(num value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);

  static String tanggal(DateTime date) =>
      DateFormat('dd MMM yyyy, HH:mm').format(date);
}
