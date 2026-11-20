class DetailPesanan {
  final String idMenu;
  final String namaMenu;
  final int jumlah;
  final int hargaSatuan;
  final String catatanItem;

  DetailPesanan({
    required this.idMenu,
    required this.namaMenu,
    required this.jumlah,
    required this.hargaSatuan,
    this.catatanItem = '',
  });

  int get subtotal => jumlah * hargaSatuan;

  factory DetailPesanan.fromMap(Map<String, dynamic> map) => DetailPesanan(
        idMenu: map['idMenu'] ?? '',
        namaMenu: map['namaMenu'] ?? '',
        jumlah: (map['jumlah'] ?? 0).toInt(),
        hargaSatuan: (map['hargaSatuan'] ?? 0).toInt(),
        catatanItem: map['catatanItem'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'idMenu': idMenu,
        'namaMenu': namaMenu,
        'jumlah': jumlah,
        'hargaSatuan': hargaSatuan,
        'subtotal': subtotal,
        'catatanItem': catatanItem,
      };
}fl