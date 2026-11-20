class MenuModel {
  final String idMenu;
  final String namaMenu;
  final String kategori;
  final double harga;
  final String deskripsi;
  final String fotoUrl;

  MenuModel({
    required this.idMenu,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    required this.deskripsi,
    required this.fotoUrl,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      idMenu: map['idMenu'] ?? '',
      namaMenu: map['namaMenu'] ?? '',
      kategori: map['kategori'] ?? 'Kopi',
      harga: (map['harga'] ?? 0).toDouble(),
      deskripsi: map['deskripsi'] ?? '',
      fotoUrl: map['fotoUrl'] ?? '',
    );
  }
}

class StokMenuModel {
  final String idStok;
  final String idGerobak;
  final String idMenu;
  int jumlahStok;

  StokMenuModel({
    required this.idStok,
    required this.idGerobak,
    required this.idMenu,
    required this.jumlahStok,
  });

  bool get tersedia => jumlahStok > 0;
}

class MenuGerobakItem {
  final MenuModel menu;
  final StokMenuModel stok;

  MenuGerobakItem({required this.menu, required this.stok});
}
