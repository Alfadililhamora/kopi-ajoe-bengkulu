import 'menu_model.dart';

enum StatusPesanan {
  dibuat('Dibuat (Menunggu Bayar)'),
  dibayar('Dibayar'),
  diproses('Diproses Barista'),
  siapDiambilDiantar('Siap Diambil / Diantar'),
  selesai('Selesai'),
  dibatalkan('Dibatalkan');

  final String label;
  const StatusPesanan(this.label);
}

class DetailPesananModel {
  final String idDetail;
  final MenuModel menu;
  int jumlah;
  final double hargaSatuan;
  String catatanItem;

  DetailPesananModel({
    required this.idDetail,
    required this.menu,
    required this.jumlah,
    required this.hargaSatuan,
    this.catatanItem = '',
  });

  double get subtotal => jumlah * hargaSatuan;
}

class PembayaranModel {
  final String idPembayaran;
  final String metode;
  final double jumlah;
  final String statusBayar;
  final DateTime waktuBayar;

  PembayaranModel({
    required this.idPembayaran,
    required this.metode,
    required this.jumlah,
    required this.statusBayar,
    required this.waktuBayar,
  });
}

class PesananModel {
  final String idPesanan;
  final String idPelanggan;
  final String namaPelanggan;
  final String idGerobak;
  final String namaGerobak;
  final DateTime tanggalPesanan;
  final List<DetailPesananModel> items;
  final double totalHarga;
  final double diskonPromo;
  StatusPesanan status;
  final String metodeAmbil;
  final String catatan;
  PembayaranModel? pembayaran;

  PesananModel({
    required this.idPesanan,
    required this.idPelanggan,
    required this.namaPelanggan,
    required this.idGerobak,
    required this.namaGerobak,
    required this.tanggalPesanan,
    required this.items,
    required this.totalHarga,
    this.diskonPromo = 0,
    required this.status,
    required this.metodeAmbil,
    this.catatan = '',
    this.pembayaran,
  });

  double get grandTotal => (totalHarga - diskonPromo).clamp(0, double.infinity);
}
