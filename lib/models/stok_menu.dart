class StokMenu {
  final String idMenu; // sama dengan id dokumen di gerobak/{id}/stok/{idMenu}
  final int jumlahStok;
  final bool tersedia;

  StokMenu({
    required this.idMenu,
    required this.jumlahStok,
    required this.tersedia,
  });

  factory StokMenu.fromMap(String idMenu, Map<String, dynamic> map) => StokMenu(
        idMenu: idMenu,
        jumlahStok: (map['jumlahStok'] ?? 0).toInt(),
        tersedia: map['tersedia'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'jumlahStok': jumlahStok,
        'tersedia': tersedia,
      };
}
