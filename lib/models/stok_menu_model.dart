import 'menu_model.dart';

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

  Map<String, dynamic> toMap() => {
        'idStok': idStok,
        'idGerobak': idGerobak,
        'idMenu': idMenu,
        'jumlahStok': jumlahStok,
      };

  factory StokMenuModel.fromMap(Map<String, dynamic> map) => StokMenuModel(
        idStok: map['idStok'] ?? '',
        idGerobak: map['idGerobak'] ?? '',
        idMenu: map['idMenu'] ?? '',
        jumlahStok: map['jumlahStok'] ?? 0,
      );
}

class MenuGerobakItem {
  final MenuModel menu;
  final StokMenuModel stok;

  MenuGerobakItem({
    required this.menu,
    required this.stok,
  });
}
