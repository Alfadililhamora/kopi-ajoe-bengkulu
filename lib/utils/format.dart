import 'package:intl/intl.dart';

String rupiah(num nilai) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(nilai);
