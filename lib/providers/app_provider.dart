import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gerobak_model.dart';
import '../models/menu_model.dart';
import '../models/pesanan_model.dart';
import '../models/user_model.dart';
import '../services/kopi_ajoe_service.dart';

class AppProvider extends ChangeNotifier {
  final KopiAjoeService _service = KopiAjoeService();

  UserModel? _currentUser;
  GerobakModel? _selectedGerobak;
  final List<DetailPesananModel> _cart = [];
  String _promoCode = '';
  double _diskonPromo = 0;
  bool _isLoadingAuth = false;

  UserModel? get currentUser => _currentUser;
  GerobakModel? get selectedGerobak => _selectedGerobak;
  List<DetailPesananModel> get cart => List.unmodifiable(_cart);
  double get diskonPromo => _diskonPromo;
  bool get isLoadingAuth => _isLoadingAuth;

  List<GerobakModel> get daftarGerobak => _service.getAllGerobak();
  List<MenuModel> get masterMenu => _service.getAllMasterMenu();
  List<PesananModel> get semuaPesanan => _service.getAllPesanan();

  List<MenuGerobakItem> get menuGerobakTerpilih {
    if (_selectedGerobak == null) return [];
    return _service.getMenuByGerobak(_selectedGerobak!.idGerobak);
  }

  double get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  double get cartGrandTotal => (cartSubtotal - _diskonPromo).clamp(0, double.infinity);
  int get totalCartItems => _cart.fold(0, (sum, item) => sum + item.jumlah);

  Future<String?> login(String email, String password) async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final user = await _service.loginWithSupabase(email, password);
      _currentUser = user;
      if (user.role == UserRole.pelanggan) {
        final buka = daftarGerobak.where((g) => g.statusBuka);
        if (buka.isNotEmpty) _selectedGerobak = buka.first;
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String nama,
    required String email,
    required String password,
    required String noHp,
    required String alamat,
  }) async {
    _isLoadingAuth = true;
    notifyListeners();
    try {
      final user = await _service.registerWithSupabase(
        email: email,
        password: password,
        nama: nama,
        noHp: noHp,
        alamat: alamat,
      );

      if (user == null) {
        return 'Akun berhasil dibuat di Supabase! Silakan konfirmasi email atau matikan Confirm Email di dashboard Supabase, lalu login.';
      }

      _currentUser = user;
      final buka = daftarGerobak.where((g) => g.statusBuka);
      if (buka.isNotEmpty) _selectedGerobak = buka.first;
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  void loginDemo(String email) {
    final user = _service.loginDemo(email);
    if (user != null) {
      _currentUser = user;
      if (user.role == UserRole.pelanggan) {
        final buka = daftarGerobak.where((g) => g.statusBuka);
        if (buka.isNotEmpty) _selectedGerobak = buka.first;
      }
      notifyListeners();
    }
  }

  void logout() {
    _service.logout();
    _currentUser = null;
    _selectedGerobak = null;
    _cart.clear();
    _diskonPromo = 0;
    _promoCode = '';
    notifyListeners();
  }

  String? pilihGerobak(GerobakModel gerobak) {
    if (!gerobak.statusBuka) {
      return 'Gerobak sedang tutup. Silakan pilih gerobak lain.';
    }
    if (_selectedGerobak?.idGerobak != gerobak.idGerobak) {
      _cart.clear();
      _diskonPromo = 0;
      _promoCode = '';
    }
    _selectedGerobak = gerobak;
    notifyListeners();
    return null;
  }

  String? tambahKeKeranjang(MenuGerobakItem item, {String catatan = ''}) {
    if (_selectedGerobak == null || !_selectedGerobak!.statusBuka) {
      return 'Gerobak sedang tutup';
    }
    final existingIdx = _cart.indexWhere((c) => c.menu.idMenu == item.menu.idMenu);
    final currentQty = existingIdx != -1 ? _cart[existingIdx].jumlah : 0;

    if (currentQty + 1 > item.stok.jumlahStok) {
      return 'Stok tidak mencukupi (tersisa ${item.stok.jumlahStok})';
    }

    if (existingIdx != -1) {
      _cart[existingIdx].jumlah += 1;
    } else {
      _cart.add(DetailPesananModel(
        idDetail: 'DTL-${DateTime.now().microsecondsSinceEpoch}',
        menu: item.menu,
        jumlah: 1,
        hargaSatuan: item.menu.harga,
        catatanItem: catatan,
      ));
    }
    notifyListeners();
    return null;
  }

  void kurangiItemKeranjang(String idMenu) {
    final idx = _cart.indexWhere((c) => c.menu.idMenu == idMenu);
    if (idx != -1) {
      if (_cart[idx].jumlah > 1) {
        _cart[idx].jumlah -= 1;
      } else {
        _cart.removeAt(idx);
      }
      notifyListeners();
    }
  }

  String terapkanKodePromo(String kode) {
    final clean = kode.trim().toUpperCase();
    if (clean == 'AJOEBENGKULU' || clean == 'NGOPI10') {
      _promoCode = clean;
      _diskonPromo = 3000;
      notifyListeners();
      return 'Kode promo $clean berhasil! Potongan Rp 3.000';
    }
    _diskonPromo = 0;
    notifyListeners();
    return 'Kode promo tidak valid';
  }

  PesananModel checkoutDanBayar({
    required String metodeAmbil,
    required String metodeBayar,
    String catatan = '',
  }) {
    final pesanan = _service.buatPesanan(
      pelanggan: _currentUser!,
      gerobak: _selectedGerobak!,
      items: List.from(_cart),
      metodeAmbil: metodeAmbil,
      catatan: catatan,
      diskonPromo: _diskonPromo,
    );
    _service.prosesPembayaran(pesanan.idPesanan, metodeBayar);
    _cart.clear();
    _diskonPromo = 0;
    notifyListeners();
    return pesanan;
  }

  void toggleStatusGerobak(String idGerobak, bool buka) {
    _service.toggleStatusGerobak(idGerobak, buka);
    notifyListeners();
  }

  void updateStokGerobak(String idGerobak, String idMenu, int stokBaru) {
    _service.updateStokMenu(idGerobak, idMenu, stokBaru);
    notifyListeners();
  }

  List<MenuGerobakItem> getMenuUntukOperator(String idGerobak) {
    return _service.getMenuByGerobak(idGerobak);
  }

  void updateStatusPesanan(String idPesanan, StatusPesanan statusBaru) {
    _service.updateStatusPesanan(idPesanan, statusBaru);
    notifyListeners();
  }

  void tambahGerobakBaru(GerobakModel gerobak) {
    _service.tambahGerobak(gerobak);
    notifyListeners();
  }

  void tambahMenuBaru(MenuModel menu) {
    _service.tambahMasterMenu(menu);
    notifyListeners();
  }
}
